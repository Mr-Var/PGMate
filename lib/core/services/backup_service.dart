import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../database/rules.dart';
import 'file_store.dart';

class BackupManifest {
  const BackupManifest({
    required this.format,
    required this.schemaVersion,
    required this.createdAt,
    required this.pgName,
    required this.tenants,
    required this.payments,
    required this.files,
  });

  final int format;
  final int schemaVersion;
  final DateTime createdAt;
  final String pgName;
  final int tenants;
  final int payments;
  final int files;

  Map<String, Object> toJson() => {
    'app': 'PG Manager',
    'format': format,
    'schemaVersion': schemaVersion,
    'createdAt': createdAt.toIso8601String(),
    'pgName': pgName,
    'tenants': tenants,
    'payments': payments,
    'files': files,
  };

  factory BackupManifest.fromJson(Map<String, dynamic> j) => BackupManifest(
    format: j['format'] as int,
    schemaVersion: j['schemaVersion'] as int,
    createdAt: DateTime.parse(j['createdAt'] as String),
    pgName: j['pgName'] as String? ?? '',
    tenants: j['tenants'] as int? ?? 0,
    payments: j['payments'] as int? ?? 0,
    files: j['files'] as int? ?? 0,
  );
}

/// A decrypted, verified backup waiting for the owner's final confirmation.
class ValidatedBackup {
  const ValidatedBackup(this.manifest, this._archive);
  final BackupManifest manifest;
  final Archive _archive;
}

/// Encrypted local backup (AES-256-GCM, key from PBKDF2-SHA256 of the
/// owner's backup password). File layout:
/// `PGMB1` | salt(16) | nonce(12) | mac(16) | ciphertext(zip).
class BackupService {
  BackupService({required this.files});

  final FileStore files;

  static const format = 1;
  static const extension = 'pgmbackup';
  static final _magic = ascii.encode('PGMB1');
  static const _iterations = 120000;

  static String? validatePassword(String v) {
    if (v.length < 8) return 'Use at least 8 characters';
    return null;
  }

  static Future<Uint8List> _encrypt(Uint8List plain, String password) => Isolate.run(() async {
    final rnd = Random.secure();
    final salt = Uint8List.fromList(List.generate(16, (_) => rnd.nextInt(256)));
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: password, nonce: salt);
    final algo = AesGcm.with256bits();
    final nonce = algo.newNonce();
    final box = await algo.encrypt(plain, secretKey: key, nonce: nonce);
    return Uint8List.fromList([..._magic, ...salt, ...nonce, ...box.mac.bytes, ...box.cipherText]);
  });

  static Future<Uint8List> _decrypt(Uint8List data, String password) => Isolate.run(() async {
    if (data.length < 5 + 16 + 12 + 16 || !_listEq(data.sublist(0, 5), _magic)) {
      throw RuleException('This is not a PG Manager backup file.');
    }
    var o = 5;
    final salt = data.sublist(o, o += 16);
    final nonce = data.sublist(o, o += 12);
    final mac = data.sublist(o, o += 16);
    final cipher = data.sublist(o);
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: _iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: password, nonce: salt);
    try {
      final plain = await AesGcm.with256bits().decrypt(
        SecretBox(cipher, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
      );
      return Uint8List.fromList(plain);
    } on SecretBoxAuthenticationError {
      throw RuleException('Wrong password, or the backup file is damaged.');
    }
  });

  static bool _listEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Builds an encrypted backup of the database and all private files.
  Future<(Uint8List bytes, BackupManifest manifest)> create(AppDatabase db, String password) async {
    final tmp = await getTemporaryDirectory();
    final snapshot = File(p.join(tmp.path, 'snapshot_${DateTime.now().millisecondsSinceEpoch}.sqlite'));
    if (await snapshot.exists()) await snapshot.delete();
    // A consistent copy even while the app is running.
    await db.customStatement('VACUUM INTO ?', [snapshot.path]);

    Future<int> count(String table) async =>
        (await db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle()).read<int>('c');
    final profile = await db.settingsDao.getProfile();

    final archive = Archive();
    archive.add(ArchiveFile.bytes('db/${AppDatabase.fileName}.sqlite', await snapshot.readAsBytes()));
    await snapshot.delete();

    final root = await files.root();
    var fileCount = 0;
    await for (final e in root.list(recursive: true)) {
      if (e is File) {
        archive.add(ArchiveFile.bytes('files/${p.relative(e.path, from: root.path)}', await e.readAsBytes()));
        fileCount++;
      }
    }
    final manifest = BackupManifest(
      format: format,
      schemaVersion: db.schemaVersion,
      createdAt: DateTime.now(),
      pgName: profile?.name ?? '',
      tenants: await count('tenants'),
      payments: await count('payments'),
      files: fileCount,
    );
    archive.add(ArchiveFile.string('manifest.json', jsonEncode(manifest.toJson())));
    final zip = ZipEncoder().encodeBytes(archive);
    final encrypted = await _encrypt(zip, password);
    await db.settingsDao.setSetting('last_backup_at', manifest.createdAt.toIso8601String());
    await db.settingsDao.setSetting('last_backup_bytes', '${encrypted.length}');
    await db.settingsDao.log('backup', null, 'create', '${encrypted.length} bytes');
    return (encrypted, manifest);
  }

  static String fileName(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return 'PGManager-backup-${t.year}${two(t.month)}${two(t.day)}-${two(t.hour)}${two(t.minute)}.$extension';
  }

  /// Decrypts and fully checks a backup without touching current data.
  Future<ValidatedBackup> validate(Uint8List data, String password, {required int currentSchemaVersion}) async {
    final zip = await _decrypt(data, password);
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(zip);
    } catch (_) {
      throw RuleException('The backup file is damaged.');
    }
    final manifestFile = archive.findFile('manifest.json');
    final dbFile = archive.findFile('db/${AppDatabase.fileName}.sqlite');
    if (manifestFile == null || dbFile == null) throw RuleException('The backup is incomplete.');
    final manifest = BackupManifest.fromJson(jsonDecode(utf8.decode(manifestFile.content)) as Map<String, dynamic>);
    if (manifest.format != format) throw RuleException('Unsupported backup format.');
    if (manifest.schemaVersion > currentSchemaVersion) {
      throw RuleException('This backup was made by a newer version of PG Manager. Update the app first.');
    }

    // Open the restored database on its own and check it is sound.
    final tmp = await getTemporaryDirectory();
    final check = File(p.join(tmp.path, 'restore_check.sqlite'));
    await check.writeAsBytes(dbFile.content, flush: true);
    final probe = AppDatabase(NativeDatabase(check));
    try {
      final ok = await probe.customSelect('PRAGMA integrity_check').getSingle();
      if (ok.read<String>('integrity_check') != 'ok') throw RuleException('The database inside the backup is damaged.');
      final profile = await probe.customSelect('SELECT COUNT(*) AS c FROM pg_profile').getSingle();
      if (profile.read<int>('c') != 1) throw RuleException('The backup has no PG profile.');
    } on RuleException {
      rethrow;
    } catch (e) {
      throw RuleException('The database inside the backup could not be read.');
    } finally {
      await probe.close();
      if (await check.exists()) await check.delete();
    }
    return ValidatedBackup(manifest, archive);
  }

  /// Replaces the live data with a validated backup. The caller must close
  /// the open database first. The previous data is kept as a safety copy.
  Future<void> apply(ValidatedBackup backup) async {
    final live = await AppDatabase.databaseFile();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final safetyDir = Directory(p.join(live.parent.path, 'pre_restore_$stamp'));
    await safetyDir.create(recursive: true);

    if (await live.exists()) await live.copy(p.join(safetyDir.path, p.basename(live.path)));
    final root = await files.root();
    if (await root.exists()) await root.rename(p.join(safetyDir.path, 'files'));

    for (final suffix in ['-wal', '-shm', '-journal']) {
      final f = File('${live.path}$suffix');
      if (await f.exists()) await f.delete();
    }
    final dbEntry = backup._archive.findFile('db/${AppDatabase.fileName}.sqlite')!;
    await live.writeAsBytes(dbEntry.content, flush: true);

    final newRoot = await files.root();
    for (final f in backup._archive.files) {
      if (!f.isFile || !f.name.startsWith('files/')) continue;
      final rel = f.name.substring('files/'.length);
      if (rel.contains('..')) continue;
      final out = File(p.join(newRoot.path, rel));
      await out.parent.create(recursive: true);
      await out.writeAsBytes(f.content, flush: true);
    }
  }
}
