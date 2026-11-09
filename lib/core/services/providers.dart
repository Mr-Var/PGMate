import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'auth_service.dart';

/// Overridden in main() and in tests.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureStoreProvider = Provider<SecureStore>((ref) => const PlatformSecureStore());

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(store: ref.watch(secureStoreProvider)),
);

final pgProfileProvider = StreamProvider<PgProfile?>(
  (ref) => ref.watch(databaseProvider).settingsDao.watchProfile(),
);
