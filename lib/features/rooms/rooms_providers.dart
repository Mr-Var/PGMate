import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/daos/rooms_dao.dart';
import '../../core/services/providers.dart';

final roomsProvider = StreamProvider<List<RoomWithBeds>>(
  (ref) => ref.watch(databaseProvider).roomsDao.watchRooms(),
);
