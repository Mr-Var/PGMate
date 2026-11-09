import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pg_manager/core/database/app_database.dart';
import 'package:pg_manager/core/database/daos/rooms_dao.dart';
import 'package:pg_manager/core/database/enums.dart';
import 'package:pg_manager/core/utils/dates.dart';

/// Shared fixtures for building realistic test data.
class Seed {
  Seed(this.db);
  final AppDatabase db;

  Future<int> tenant(String name, {String phone = '9876543210', TenantStatus status = TenantStatus.active}) => db
      .into(db.tenants)
      .insert(
        TenantsCompanion.insert(
          fullName: name,
          phone: phone,
          gender: Gender.male,
          joiningDate: DateTime(2026, 1, 1),
          monthlyRentPaise: 800000,
          rentDueDay: 5,
          status: Value(status),
        ),
      );

  Future<int> allocate(int tenantId, int bedId) => db
      .into(db.allocations)
      .insert(
        AllocationsCompanion.insert(
          tenantId: tenantId,
          bedId: bedId,
          startDate: DateTime(2026, 1, 1),
          rentPaise: 800000,
        ),
      );

  Future<int> invoice(
    int tenantId,
    int year,
    int month, {
    int total = 800000,
    int paid = 0,
    InvoiceStatus status = InvoiceStatus.unpaid,
    DateTime? due,
  }) => db
      .into(db.rentInvoices)
      .insert(
        RentInvoicesCompanion.insert(
          invoiceNumber: 'INV-$tenantId-$year$month-${DateTime.now().microsecondsSinceEpoch}',
          tenantId: tenantId,
          periodYear: year,
          periodMonth: month,
          periodStart: DateTime(year, month),
          periodEnd: DateTime(year, month + 1),
          rentPaise: total,
          totalPaise: total,
          paidPaise: Value(paid),
          status: Value(status),
          dueDate: due ?? DateTime(year, month, 5),
        ),
      );

  var _n = 0;
  Future<int> payment(
    int tenantId,
    int amount,
    DateTime date, {
    PaymentMethod method = PaymentMethod.cash,
    PaymentStatus status = PaymentStatus.confirmed,
    String? utr,
  }) {
    _n++;
    return db
        .into(db.payments)
        .insert(
          PaymentsCompanion.insert(
            transactionId: 'TXN-$_n',
            receiptNumber: 'RCPT-$_n',
            tenantId: tenantId,
            amountPaise: amount,
            method: method,
            upiReference: Value(utr),
            paymentDate: date,
            status: status,
          ),
        );
  }
}

void main() {
  late AppDatabase db;
  late Seed seed;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    seed = Seed(db);
  });
  tearDown(() => db.close());

  Future<List<int>> bedIds() async => (await db.select(db.beds).get()).map((b) => b.id).toList();

  group('Rooms and beds', () {
    test('adding a room creates labelled beds', () async {
      await db.roomsDao.addRoom(roomNumber: '101', floor: 1, rentPaise: 800000, bedCount: 3);
      final rooms = await db.roomsDao.watchRooms().first;
      expect(rooms.single.beds.map((b) => b.bed.label), ['A', 'B', 'C']);
      expect(rooms.single.count(BedStatus.available), 3);
    });

    test('duplicate room numbers are rejected', () async {
      await db.roomsDao.addRoom(roomNumber: '101', floor: 1, rentPaise: 800000, bedCount: 1);
      expect(
        () => db.roomsDao.addRoom(roomNumber: '101', floor: 1, rentPaise: 800000, bedCount: 1),
        throwsA(isA<RoomRuleException>()),
      );
    });

    test('cannot shrink below occupied beds; free beds are removed', () async {
      final roomId = await db.roomsDao.addRoom(roomNumber: '201', floor: 2, rentPaise: 700000, bedCount: 3);
      final ids = await bedIds();
      await seed.allocate(await seed.tenant('Asha'), ids[0]);
      await seed.allocate(await seed.tenant('Bala', phone: '9876543211'), ids[1]);

      expect(
        () => db.roomsDao.updateRoom(roomId: roomId, roomNumber: '201', floor: 2, rentPaise: 700000, bedCount: 1),
        throwsA(isA<RoomRuleException>()),
      );
      await db.roomsDao.updateRoom(roomId: roomId, roomNumber: '201', floor: 2, rentPaise: 700000, bedCount: 2);
      final room = (await db.roomsDao.watchRooms().first).single;
      expect(room.capacity, 2);
      expect(room.count(BedStatus.occupied), 2);
    });

    test('occupied beds cannot be set to maintenance', () async {
      await db.roomsDao.addRoom(roomNumber: '1', floor: 0, rentPaise: 1, bedCount: 1);
      final bed = (await bedIds()).single;
      await seed.allocate(await seed.tenant('Asha'), bed);
      expect(() => db.roomsDao.setBedStatus(bed, BedStatus.maintenance), throwsA(isA<RoomRuleException>()));
    });

    test('room with history is archived, not deleted', () async {
      final roomId = await db.roomsDao.addRoom(roomNumber: '9', floor: 0, rentPaise: 1, bedCount: 1);
      final bed = (await bedIds()).single;
      final allocation = await seed.allocate(await seed.tenant('Asha'), bed);
      await (db.update(db.allocations)..where((a) => a.id.equals(allocation))).write(
        AllocationsCompanion(isActive: const Value(false), endDate: Value(DateTime(2026, 3, 1))),
      );

      await db.roomsDao.deleteRoom(roomId);
      expect(await db.roomsDao.watchRooms().first, isEmpty);
      expect(await db.select(db.allocations).get(), hasLength(1), reason: 'history preserved');
      // The number is free to reuse.
      await db.roomsDao.addRoom(roomNumber: '9', floor: 0, rentPaise: 1, bedCount: 1);
    });
  });

  group('Integrity constraints', () {
    test('two active tenants can never share a bed', () async {
      await db.roomsDao.addRoom(roomNumber: '1', floor: 0, rentPaise: 1, bedCount: 1);
      final bed = (await bedIds()).single;
      await seed.allocate(await seed.tenant('Asha'), bed);
      final b = await seed.tenant('Bala', phone: '9876543211');
      expect(() => seed.allocate(b, bed), throwsA(isA<SqliteException>()));
    });

    test('a tenant cannot hold two active beds', () async {
      await db.roomsDao.addRoom(roomNumber: '1', floor: 0, rentPaise: 1, bedCount: 2);
      final ids = await bedIds();
      final a = await seed.tenant('Asha');
      await seed.allocate(a, ids[0]);
      expect(() => seed.allocate(a, ids[1]), throwsA(isA<SqliteException>()));
    });

    test('duplicate invoice for the same month is blocked unless cancelled', () async {
      final a = await seed.tenant('Asha');
      final first = await seed.invoice(a, 2026, 11);
      expect(() => seed.invoice(a, 2026, 11), throwsA(isA<SqliteException>()));

      await (db.update(
        db.rentInvoices,
      )..where((i) => i.id.equals(first))).write(const RentInvoicesCompanion(status: Value(InvoiceStatus.cancelled)));
      await seed.invoice(a, 2026, 11); // re-issue allowed after cancellation
    });

    test('payments cannot be deleted or edited', () async {
      final a = await seed.tenant('Asha');
      final p = await seed.payment(a, 500000, DateTime(2026, 11, 2));
      expect(() => (db.delete(db.payments)..where((x) => x.id.equals(p))).go(), throwsA(isA<SqliteException>()));
      expect(
        () => (db.update(
          db.payments,
        )..where((x) => x.id.equals(p))).write(const PaymentsCompanion(amountPaise: Value(1))),
        throwsA(isA<SqliteException>()),
      );
    });

    test('confirmed payments cannot be un-confirmed', () async {
      final a = await seed.tenant('Asha');
      final p = await seed.payment(a, 500000, DateTime(2026, 11, 2));
      expect(
        () => (db.update(
          db.payments,
        )..where((x) => x.id.equals(p))).write(const PaymentsCompanion(status: Value(PaymentStatus.rejected))),
        throwsA(isA<SqliteException>()),
      );
    });

    test('UPI reference (UTR) cannot be recorded twice', () async {
      final a = await seed.tenant('Asha');
      await seed.payment(a, 500000, DateTime(2026, 11, 2), method: PaymentMethod.upi, utr: '412345678901');
      expect(
        () => seed.payment(a, 500000, DateTime(2026, 11, 3), method: PaymentMethod.upi, utr: '412345678901'),
        throwsA(isA<SqliteException>()),
      );
    });

    test('invoices and expenses cannot be hard-deleted', () async {
      final a = await seed.tenant('Asha');
      await seed.invoice(a, 2026, 11);
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              title: 'Power',
              category: ExpenseCategory.electricity,
              amountPaise: 100,
              expenseDate: DateTime(2026, 11, 1),
              paymentMethod: PaymentMethod.cash,
            ),
          );
      expect(() => db.delete(db.rentInvoices).go(), throwsA(isA<SqliteException>()));
      expect(() => db.delete(db.expenses).go(), throwsA(isA<SqliteException>()));
    });

    test('money columns reject negative values', () async {
      expect(
        () => db.roomsDao.addRoom(roomNumber: 'X', floor: 0, rentPaise: -1, bedCount: 1),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('Dashboard summary', () {
    test('computes figures from real records', () async {
      final now = DateTime(2026, 11, 10, 9);
      await db.roomsDao.addRoom(roomNumber: '101', floor: 1, rentPaise: 800000, bedCount: 4);
      final ids = await bedIds();
      final a = await seed.tenant('Arjun');
      final b = await seed.tenant('Bala', phone: '9876543211');
      await seed.allocate(a, ids[0]);
      await seed.allocate(b, ids[1]);
      await db.roomsDao.setBedStatus(ids[2], BedStatus.maintenance);

      // November: Arjun paid in full, Bala partially; Bala also owes October.
      await seed.invoice(a, 2026, 11, paid: 800000, status: InvoiceStatus.paid);
      await seed.invoice(b, 2026, 11, paid: 300000, status: InvoiceStatus.partiallyPaid, due: DateTime(2026, 11, 10));
      await seed.invoice(b, 2026, 10, due: DateTime(2026, 10, 5));
      final cancelled = await seed.invoice(a, 2026, 10, status: InvoiceStatus.cancelled);
      expect(cancelled, isPositive);

      await seed.payment(a, 800000, DateTime(2026, 11, 3));
      await seed.payment(b, 300000, DateTime(2026, 11, 4), method: PaymentMethod.upi, utr: 'U1');
      // Unverified UPI must not count as collected.
      await seed.payment(
        b,
        500000,
        DateTime(2026, 11, 6),
        method: PaymentMethod.upi,
        status: PaymentStatus.pendingVerification,
        utr: 'U2',
      );
      // A payment from last month is outside the range.
      await seed.payment(a, 100000, DateTime(2026, 10, 30));

      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              title: 'Electricity bill',
              category: ExpenseCategory.electricity,
              amountPaise: 250000,
              expenseDate: DateTime(2026, 11, 2),
              paymentMethod: PaymentMethod.upi,
            ),
          );
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              title: 'Voided',
              category: ExpenseCategory.repairs,
              amountPaise: 999900,
              expenseDate: DateTime(2026, 11, 2),
              paymentMethod: PaymentMethod.cash,
              isVoided: const Value(true),
            ),
          );

      final s = await db.dashboardDao.summary(DateRange.month(2026, 11), now: now);
      expect(s.totalTenants, 2);
      expect(s.totalBeds, 4);
      expect(s.occupiedBeds, 2);
      expect(s.maintenanceBeds, 1);
      expect(s.availableBeds, 1);
      expect(s.occupancy, 0.5);
      expect(s.rentBilledPaise, 1600000);
      expect(s.rentCollectedPaise, 1100000);
      expect(s.outstandingPaise, 500000 + 800000); // Nov balance + October
      expect(s.expensesPaise, 250000);
      expect(s.netCashFlowPaise, 850000);
      expect(s.pendingUpiCount, 1);
      expect(s.dueToday.single.tenantName, 'Bala');
      expect(s.dueToday.single.balancePaise, 500000);
      expect(s.overdue.single.balancePaise, 800000);
      expect(s.recent.first.pendingVerification, isTrue);
      expect(s.recent.length, 5);
    });

    test('empty database yields zeros, not errors', () async {
      final s = await db.dashboardDao.summary(DateRange.month(2026, 11));
      expect(s.totalBeds, 0);
      expect(s.occupancy, 0);
      expect(s.collectionRate, 0);
      expect(s.recent, isEmpty);
    });
  });
}
