import 'package:drift/drift.dart';

import '../app_database.dart';
import '../enums.dart';
import '../rules.dart';
import '../tables/operations_tables.dart';
import '../tables/property_tables.dart';

part 'rooms_dao.g.dart';

class BedView {
  const BedView({required this.bed, this.tenantId, this.tenantName});

  final Bed bed;
  final int? tenantId;
  final String? tenantName;

  /// The live status: an active allocation always wins over the stored flag.
  BedStatus get effectiveStatus {
    if (tenantId != null) return BedStatus.occupied;
    if (bed.status == BedStatus.occupied) return BedStatus.available;
    return bed.status;
  }
}

class RoomWithBeds {
  const RoomWithBeds(this.room, this.beds);

  final Room room;
  final List<BedView> beds;

  int count(BedStatus s) => beds.where((b) => b.effectiveStatus == s).length;
  int get capacity => beds.length;
}

class RoomRuleException extends RuleException {
  RoomRuleException(super.message);
}

@DriftAccessor(tables: [Rooms, Beds, Allocations, Tenants, AuditLogs])
class RoomsDao extends DatabaseAccessor<AppDatabase> with _$RoomsDaoMixin {
  RoomsDao(super.db);

  /// All active rooms with their active beds and current occupant, ordered
  /// by floor then room number.
  Stream<List<RoomWithBeds>> watchRooms() {
    final query =
        select(rooms).join([
            leftOuterJoin(beds, beds.roomId.equalsExp(rooms.id) & beds.isActive.equals(true)),
            leftOuterJoin(allocations, allocations.bedId.equalsExp(beds.id) & allocations.isActive.equals(true)),
            leftOuterJoin(tenants, tenants.id.equalsExp(allocations.tenantId)),
          ])
          ..where(rooms.isActive.equals(true))
          ..orderBy([OrderingTerm.asc(rooms.floor), OrderingTerm.asc(rooms.roomNumber), OrderingTerm.asc(beds.label)]);

    return query.watch().map((rows) {
      final byRoom = <int, (Room, List<BedView>)>{};
      for (final row in rows) {
        final room = row.readTable(rooms);
        final entry = byRoom.putIfAbsent(room.id, () => (room, <BedView>[]));
        final bed = row.readTableOrNull(beds);
        if (bed != null) {
          final tenant = row.readTableOrNull(tenants);
          entry.$2.add(BedView(bed: bed, tenantId: tenant?.id, tenantName: tenant?.fullName));
        }
      }
      return byRoom.values.map((e) => RoomWithBeds(e.$1, e.$2)).toList();
    });
  }

  static String bedLabel(int index) {
    // A..Z, then AA, AB...
    var n = index;
    var label = '';
    do {
      label = String.fromCharCode(65 + n % 26) + label;
      n = n ~/ 26 - 1;
    } while (n >= 0);
    return label;
  }

  Future<bool> roomNumberExists(String number, {int? exceptId}) async {
    final q = select(rooms)..where((r) => r.roomNumber.equals(number.trim()));
    if (exceptId != null) q.where((r) => r.id.equals(exceptId).not());
    return (await q.get()).isNotEmpty;
  }

  Future<int> addRoom({
    required String roomNumber,
    required int floor,
    required int rentPaise,
    required int bedCount,
    String? notes,
  }) {
    if (bedCount < 1 || bedCount > 20) {
      throw RoomRuleException('A room must have between 1 and 20 beds.');
    }
    return transaction(() async {
      final number = roomNumber.trim();
      // A deactivated room with the same number is revived instead of duplicated.
      if (await roomNumberExists(number)) {
        throw RoomRuleException('Room $number already exists.');
      }
      final id = await into(rooms).insert(
        RoomsCompanion.insert(
          roomNumber: number,
          floor: floor,
          rentPaise: rentPaise,
          notes: Value(_blankToNull(notes)),
        ),
      );
      for (var i = 0; i < bedCount; i++) {
        await into(beds).insert(BedsCompanion.insert(roomId: id, label: bedLabel(i)));
      }
      await _log(id, 'create', 'Room $number, $bedCount beds');
      return id;
    });
  }

  /// Updates room details and grows or shrinks bed capacity. Beds are only
  /// removed if they are free; beds with history are deactivated, not deleted.
  Future<void> updateRoom({
    required int roomId,
    required String roomNumber,
    required int floor,
    required int rentPaise,
    required int bedCount,
    String? notes,
  }) {
    if (bedCount < 1 || bedCount > 20) {
      throw RoomRuleException('A room must have between 1 and 20 beds.');
    }
    return transaction(() async {
      final number = roomNumber.trim();
      if (await roomNumberExists(number, exceptId: roomId)) {
        throw RoomRuleException('Room $number already exists.');
      }
      await (update(rooms)..where((r) => r.id.equals(roomId))).write(
        RoomsCompanion(
          roomNumber: Value(number),
          floor: Value(floor),
          rentPaise: Value(rentPaise),
          notes: Value(_blankToNull(notes)),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final allBeds =
          await (select(beds)
                ..where((b) => b.roomId.equals(roomId))
                ..orderBy([(b) => OrderingTerm.asc(b.id)]))
              .get();
      final active = allBeds.where((b) => b.isActive).toList();

      if (bedCount > active.length) {
        final used = allBeds.map((b) => b.label).toSet();
        var added = 0;
        // Reactivate previously removed beds first, then create new labels.
        for (final b in allBeds.where((b) => !b.isActive)) {
          if (active.length + added >= bedCount) break;
          await (update(beds)..where((x) => x.id.equals(b.id))).write(
            BedsCompanion(
              isActive: const Value(true),
              status: const Value(BedStatus.available),
              updatedAt: Value(DateTime.now()),
            ),
          );
          added++;
        }
        var i = 0;
        while (active.length + added < bedCount) {
          final label = bedLabel(i++);
          if (used.contains(label)) continue;
          await into(beds).insert(BedsCompanion.insert(roomId: roomId, label: label));
          used.add(label);
          added++;
        }
      } else if (bedCount < active.length) {
        final toRemove = active.length - bedCount;
        // Remove free beds, starting from the last label.
        final candidates = <Bed>[];
        for (final b in active.reversed) {
          if (!await _hasActiveAllocation(b.id)) candidates.add(b);
          if (candidates.length == toRemove) break;
        }
        if (candidates.length < toRemove) {
          throw RoomRuleException('Cannot reduce to $bedCount beds: only ${candidates.length} bed(s) are free.');
        }
        for (final b in candidates) {
          await (update(beds)..where((x) => x.id.equals(b.id))).write(
            BedsCompanion(isActive: const Value(false), updatedAt: Value(DateTime.now())),
          );
        }
      }
      await _log(roomId, 'update', 'Room $number, $bedCount beds');
    });
  }

  /// Rooms that never had a tenant are deleted; rooms with history are
  /// deactivated so allocation records stay intact.
  Future<void> deleteRoom(int roomId) {
    return transaction(() async {
      final roomBeds = await (select(beds)..where((b) => b.roomId.equals(roomId))).get();
      final bedIds = roomBeds.map((b) => b.id).toList();
      if (bedIds.isNotEmpty) {
        final activeCount = await (select(
          allocations,
        )..where((a) => a.bedId.isIn(bedIds) & a.isActive.equals(true))).get();
        if (activeCount.isNotEmpty) {
          throw RoomRuleException('This room has tenants. Transfer or check them out first.');
        }
      }
      final history = bedIds.isEmpty
          ? <Allocation>[]
          : await (select(allocations)..where((a) => a.bedId.isIn(bedIds))).get();
      final complaintsCount = await db
          .customSelect('SELECT COUNT(*) AS c FROM complaints WHERE room_id = ?', variables: [Variable.withInt(roomId)])
          .getSingle();

      if (history.isEmpty && complaintsCount.read<int>('c') == 0) {
        await (delete(beds)..where((b) => b.roomId.equals(roomId))).go();
        await (delete(rooms)..where((r) => r.id.equals(roomId))).go();
        await _log(roomId, 'delete');
      } else {
        await (update(beds)..where((b) => b.roomId.equals(roomId))).write(
          BedsCompanion(isActive: const Value(false), updatedAt: Value(DateTime.now())),
        );
        final room = await (select(rooms)..where((r) => r.id.equals(roomId))).getSingle();
        // Free the room number for reuse while keeping the archived record.
        await (update(rooms)..where((r) => r.id.equals(roomId))).write(
          RoomsCompanion(
            isActive: const Value(false),
            roomNumber: Value('${room.roomNumber}~archived-$roomId'),
            updatedAt: Value(DateTime.now()),
          ),
        );
        await _log(roomId, 'archive', 'Room has history; archived instead of deleted');
      }
    });
  }

  /// Owner can only toggle free beds between available, reserved and
  /// maintenance. "Occupied" is set exclusively through allocations.
  Future<void> setBedStatus(int bedId, BedStatus status) {
    if (status == BedStatus.occupied) {
      throw RoomRuleException('Assign a tenant to mark a bed occupied.');
    }
    return transaction(() async {
      if (await _hasActiveAllocation(bedId)) {
        throw RoomRuleException('This bed is occupied. Transfer or check out the tenant first.');
      }
      await (update(beds)..where((b) => b.id.equals(bedId))).write(
        BedsCompanion(status: Value(status), updatedAt: Value(DateTime.now())),
      );
      await into(auditLogs).insert(
        AuditLogsCompanion.insert(entity: 'bed', entityId: Value(bedId), action: 'status', details: Value(status.name)),
      );
    });
  }

  Future<bool> _hasActiveAllocation(int bedId) async {
    final rows = await (select(allocations)..where((a) => a.bedId.equals(bedId) & a.isActive.equals(true))).get();
    return rows.isNotEmpty;
  }

  Future<void> _log(int id, String action, [String? details]) => into(auditLogs)
      .insert(AuditLogsCompanion.insert(entity: 'room', entityId: Value(id), action: action, details: Value(details)));

  static String? _blankToNull(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
