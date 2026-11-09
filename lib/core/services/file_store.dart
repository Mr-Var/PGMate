import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Stores tenant photos, ID proofs, bills and complaint images in the app's
/// private support directory. Nothing is written to shared/public storage.
/// The database keeps only paths relative to [root].
class FileStore {
  FileStore([Future<Directory> Function()? rootProvider]) : _rootProvider = rootProvider ?? _defaultRoot;

  final Future<Directory> Function() _rootProvider;
  Directory? _root;

  static Future<Directory> _defaultRoot() async {
    final base = await getApplicationSupportDirectory();
    return Directory(p.join(base.path, 'files'));
  }

  Future<Directory> root() async {
    final r = _root ??= await _rootProvider();
    if (!await r.exists()) await r.create(recursive: true);
    return r;
  }

  /// Saves [bytes] under [folder] and returns the relative path.
  Future<String> save(Uint8List bytes, {required String folder, required String extension}) async {
    final r = await root();
    final dir = Directory(p.join(r.path, folder));
    if (!await dir.exists()) await dir.create(recursive: true);
    final rnd = Random.secure().nextInt(1 << 32).toRadixString(36);
    final ext = extension.replaceFirst('.', '').toLowerCase();
    final name = '${DateTime.now().millisecondsSinceEpoch}_$rnd.$ext';
    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes, flush: true);
    return p.join(folder, name);
  }

  Future<File> resolve(String relativePath) async => File(p.join((await root()).path, relativePath));

  static bool isPdf(String path) => p.extension(path).toLowerCase() == '.pdf';
}
