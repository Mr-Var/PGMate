import 'package:drift/drift.dart';

import '../../utils/money.dart';
import '../app_database.dart';
import '../billing_math.dart';
import '../enums.dart';
import '../rules.dart';
import '../tables/finance_tables.dart';
import '../tables/operations_tables.dart';
import '../tables/property_tables.dart';
import 'billing_dao.dart';

part 'tenants_dao.g.dart';

class TenantInput {
  const TenantInput({
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.joiningDate,
    required this.monthlyRentPaise,
    required this.rentDueDay,
    this.email,
    this.photoPath,
    this.idProofType,
    this.idProofNumber,
    this.idProofPath,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.occupation,
    this.securityDepositPaise = 0,
    this.advancePaise = 0,
    this.notes,
  });

  final String fullName;
  final String phone;
  final Gender gender;
  final DateTime joiningDate;
  final int monthlyRentPaise;
  final int rentDueDay;
  final String? email;
  final String? photoPath;
  final String? idProofType;
  final String? idProofNumber;
  final String? idProofPath;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? occupation;
  final int securityDepositPaise;
  final int advancePaise;
  final String? notes;
}

enum TenantFilter { current, active, notice, checkedOut, all }

enum TenantSort { joiningNewest, joiningOldest, name, dues }

class TenantListItem {
  const TenantListItem({required this.tenant, required this.roomLabel, required this.duesPaise, required this.overdue});
  final Tenant tenant;
  final String? roomLabel;
  final int duesPaise;
  final bool overdue;
}

class AllocationView {
  const AllocationView(this.allocation, this.room, this.bed);
  final Allocation allocation;
  final Room room;
  final Bed bed;
  String get label => 'Room ${room.roomNumber} · Bed ${bed.label}';
}

class FreeBed {
  const FreeBed(this.room, this.bed);
  final Room room;
  final Bed bed;
  String get label => 'Room ${room.roomNumber} · Bed ${bed.label}';
}

class TenantDetail {
  const TenantDetail({
    required this.tenant,
    required this.current,
    required this.history,
    required this.outstandingPaise,
    required this.creditPaise,
  });

  final Tenant tenant;
  final AllocationView? current;
  final List<AllocationView> history;
  final int outstandingPaise;
  final int creditPaise;

  bool get isCurrent =>
      tenant.status == TenantStatus.active ||
      tenant.status == TenantStatus.noticeGiven ||
      tenant.status == TenantStatus.newTenant;
}

@DriftAccessor(tables: [Tenants, Allocations, Beds, Rooms, RentInvoices, Payments, PaymentAllocations, AuditLogs])
class TenantsDao extends DatabaseAccessor<AppDatabase> with _$TenantsDaoMixin {
  TenantsDao(super.db);

  static const currentStatuses = [TenantStatus.newTenant, TenantStatus.active, TenantStatus.noticeGiven];

  TenantsCompanion _companion(TenantInput i) => TenantsCompanion(
    fullName: Value(i.fullName.trim()),
    phone: Value(i.phone.trim()),
    email: Value(_n(i.email)),
    gender: Value(i.gender),
    photoPath: Value(i.photoPath),
    idProofType: Value(_n(i.idProofType)),
    idProofNumber: Value(_n(i.idProofNumber)),
    idProofPath: Value(i.idProofPath),
    emergencyContactName: Value(_n(i.emergencyContactName)),
    emergencyContactPhone: Value(_n(i.emergencyContactPhone)),
    occupation: Value(_n(i.occupation)),
    joiningDate: Value(DateTime(i.joiningDate.year, i.joiningDate.month, i.joiningDate.day)),
    monthlyRentPaise: Value(i.monthlyRentPaise),
    securityDepositPaise: Value(i.securityDepositPaise),
    advancePaise: Value(i.advancePaise),
    rentDueDay: Value(i.rentDueDay),
    notes: Value(_n(i.notes)),
    updatedAt: Value(DateTime.now()),
  );

  Future<void> _checkPhone(String phone, {int? exceptId}) async {
    final q = select(tenants)..where((t) => t.phone.equals(phone.trim()) & t.status.isInValues(currentStatuses));
    if (exceptId != null) q.where((t) => t.id.equals(exceptId).not());
    final dup = await q.getSingleOrNull();
    if (dup != null) throw RuleException('${dup.fullName} is a current tenant with this phone number.');
  }

  /// Registers a tenant, assigns the bed, records the advance and creates the
  /// joining month's invoice — all or nothing.
  Future<int> createTenant(
    TenantInput input, {
    int? bedId,
    PaymentMethod advanceMethod = PaymentMethod.cash,
    String? advanceUpiReference,
    bool generateFirstInvoice = true,
  }) {
    return transaction(() async {
      await _checkPhone(input.phone);
      final id = await into(tenants).insert(
        _companion(input).copyWith(
          status: Value(bedId == null ? TenantStatus.newTenant : TenantStatus.active),
          createdAt: Value(DateTime.now()),
        ),
      );
      if (bedId != null) await _allocate(id, bedId, input.joiningDate, input.monthlyRentPaise);
      if (input.advancePaise > 0) {
        await db.billingDao.recordPayment(
          PaymentInput(
            tenantId: id,
            amountPaise: input.advancePaise,
            method: advanceMethod,
            date: input.joiningDate,
            upiReference: advanceUpiReference,
            upiVerified: true,
            notes: 'Advance paid at joining',
          ),
        );
      }
      if (bedId != null && generateFirstInvoice) {
        final j = input.joiningDate;
        await db.billingDao.createInvoice(
          tenantId: id,
          year: j.year,
          month: j.month,
          rentPaise: BillingMath.joiningMonthRent(input.monthlyRentPaise, j),
          prorated: j.day > 1,
        );
      }
      await db.settingsDao.log('tenant', id, 'create', input.fullName);
      return id;
    });
  }

  Future<void> updateTenant(int id, TenantInput input) {
    return transaction(() async {
      await _checkPhone(input.phone, exceptId: id);
      final c = _companion(input);
      // Deposit and advance are fixed at joining; changes go through payments.
      await (update(tenants)..where((t) => t.id.equals(id))).write(
        c.copyWith(advancePaise: const Value.absent(), joiningDate: const Value.absent()),
      );
      await db.settingsDao.log('tenant', id, 'update');
    });
  }

  Future<void> _allocate(int tenantId, int bedId, DateTime start, int rentPaise) async {
    final bed = await (select(beds)..where((b) => b.id.equals(bedId))).getSingle();
    if (!bed.isActive) throw RuleException('This bed is no longer in use.');
    if (bed.status == BedStatus.maintenance) throw RuleException('This bed is under maintenance.');
    final taken = await (select(
      allocations,
    )..where((a) => a.bedId.equals(bedId) & a.isActive.equals(true))).getSingleOrNull();
    if (taken != null) throw RuleException('This bed is already occupied.');
    await into(allocations).insert(
      AllocationsCompanion.insert(
        tenantId: tenantId,
        bedId: bedId,
        startDate: DateTime(start.year, start.month, start.day),
        rentPaise: rentPaise,
      ),
    );
    await (update(beds)..where((b) => b.id.equals(bedId))).write(
      BedsCompanion(status: const Value(BedStatus.occupied), updatedAt: Value(DateTime.now())),
    );
  }

  /// Assigns a bed to a tenant who has none yet.
  Future<void> assignBed(int tenantId, int bedId, DateTime date) {
    return transaction(() async {
      final t = await (select(tenants)..where((x) => x.id.equals(tenantId))).getSingle();
      await _allocate(tenantId, bedId, date, t.monthlyRentPaise);
      if (t.status == TenantStatus.newTenant) {
        await (update(
          tenants,
        )..where((x) => x.id.equals(tenantId))).write(const TenantsCompanion(status: Value(TenantStatus.active)));
      }
      await db.settingsDao.log('tenant', tenantId, 'assign_bed', '$bedId');
    });
  }

  /// Moves a tenant to another bed, keeping the old allocation as history.
  /// A new rent applies from the next invoice.
  Future<void> transfer(int tenantId, int newBedId, DateTime date, {int? newRentPaise}) {
    return transaction(() async {
      final current = await (select(
        allocations,
      )..where((a) => a.tenantId.equals(tenantId) & a.isActive.equals(true))).getSingleOrNull();
      if (current == null) throw RuleException('This tenant has no bed to transfer from.');
      if (current.bedId == newBedId) throw RuleException('Choose a different bed.');
      final t = await (select(tenants)..where((x) => x.id.equals(tenantId))).getSingle();
      await (update(allocations)..where((a) => a.id.equals(current.id))).write(
        AllocationsCompanion(
          isActive: const Value(false),
          endDate: Value(DateTime(date.year, date.month, date.day)),
          endReason: const Value('transfer'),
        ),
      );
      await (update(beds)..where((b) => b.id.equals(current.bedId))).write(
        BedsCompanion(status: const Value(BedStatus.available), updatedAt: Value(DateTime.now())),
      );
      final rent = newRentPaise ?? t.monthlyRentPaise;
      await _allocate(tenantId, newBedId, date, rent);
      if (newRentPaise != null && newRentPaise != t.monthlyRentPaise) {
        await (update(tenants)..where((x) => x.id.equals(tenantId))).write(
          TenantsCompanion(monthlyRentPaise: Value(newRentPaise), updatedAt: Value(DateTime.now())),
        );
      }
      await db.settingsDao.log(
        'tenant',
        tenantId,
        'transfer',
        'bed ${current.bedId} → $newBedId, ${Money.format(rent)}',
      );
    });
  }

  Future<void> giveNotice(int tenantId, DateTime noticeDate, DateTime expectedCheckout) {
    if (expectedCheckout.isBefore(noticeDate)) {
      throw RuleException('Checkout date must be on or after the notice date.');
    }
    return transaction(() async {
      await (update(tenants)..where((t) => t.id.equals(tenantId))).write(
        TenantsCompanion(
          status: const Value(TenantStatus.noticeGiven),
          noticeDate: Value(noticeDate),
          expectedCheckoutDate: Value(expectedCheckout),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await db.settingsDao.log('tenant', tenantId, 'notice');
    });
  }

  Future<void> withdrawNotice(int tenantId) {
    return transaction(() async {
      await (update(tenants)..where((t) => t.id.equals(tenantId))).write(
        TenantsCompanion(
          status: const Value(TenantStatus.active),
          noticeDate: const Value(null),
          expectedCheckoutDate: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await db.settingsDao.log('tenant', tenantId, 'notice_withdrawn');
    });
  }

  Future<void> archive(int tenantId) {
    return transaction(() async {
      final t = await (select(tenants)..where((x) => x.id.equals(tenantId))).getSingle();
      if (t.status != TenantStatus.checkedOut) throw RuleException('Only checked-out tenants can be archived.');
      if (await db.billingDao.tenantOutstanding(tenantId) > 0) {
        throw RuleException('Clear the pending dues before archiving.');
      }
      await (update(tenants)..where((x) => x.id.equals(tenantId))).write(
        TenantsCompanion(status: const Value(TenantStatus.archived), updatedAt: Value(DateTime.now())),
      );
      await db.settingsDao.log('tenant', tenantId, 'archive');
    });
  }

  static const _roomLabelSql = '''
    (SELECT r.room_number || ' · Bed ' || b.label FROM allocations a
       JOIN beds b ON b.id = a.bed_id JOIN rooms r ON r.id = b.room_id
      WHERE a.tenant_id = t.id AND a.is_active = 1)''';

  Stream<List<TenantListItem>> watchTenants({
    TenantFilter filter = TenantFilter.current,
    String search = '',
    TenantSort sort = TenantSort.joiningNewest,
    DateTime? today,
  }) {
    final where = <String>[];
    final vars = <Variable>[
      Variable.withDateTime(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)),
    ];
    switch (filter) {
      case TenantFilter.current:
        where.add("t.status IN ('newTenant','active','noticeGiven')");
      case TenantFilter.active:
        where.add("t.status IN ('newTenant','active')");
      case TenantFilter.notice:
        where.add("t.status = 'noticeGiven'");
      case TenantFilter.checkedOut:
        where.add("t.status IN ('checkedOut','archived')");
      case TenantFilter.all:
        break;
    }
    final q = search.trim();
    if (q.isNotEmpty) {
      where.add('(t.full_name LIKE ? OR t.phone LIKE ?)');
      vars.addAll([Variable.withString('%$q%'), Variable.withString('%$q%')]);
    }
    final order = switch (sort) {
      TenantSort.joiningNewest => 't.joining_date DESC',
      TenantSort.joiningOldest => 't.joining_date ASC',
      TenantSort.name => 't.full_name COLLATE NOCASE ASC',
      TenantSort.dues => 'dues DESC, t.full_name',
    };
    return customSelect(
      '''SELECT t.*, $_roomLabelSql AS room_label,
           COALESCE((SELECT SUM(i.total_paise - i.paid_paise) FROM rent_invoices i
                     WHERE i.tenant_id = t.id AND i.status <> 'cancelled'), 0) AS dues,
           EXISTS (SELECT 1 FROM rent_invoices i WHERE i.tenant_id = t.id AND i.status <> 'cancelled'
                     AND i.total_paise > i.paid_paise AND i.due_date < ?1) AS overdue
         FROM tenants t
         ${where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}'}
         ORDER BY $order''',
      variables: vars,
      readsFrom: {tenants, allocations, rentInvoices, beds, rooms},
    ).watch().asyncMap(
      (rows) async => [
        for (final r in rows)
          TenantListItem(
            tenant: await tenants.mapFromRow(r),
            roomLabel: r.read<String?>('room_label'),
            duesPaise: r.read<int>('dues'),
            overdue: r.read<bool>('overdue'),
          ),
      ],
    );
  }

  Stream<TenantDetail?> watchTenant(int id) {
    return customSelect(
      'SELECT 1',
      readsFrom: {tenants, allocations, rentInvoices, payments, paymentAllocations, beds, rooms},
    ).watch().asyncMap((_) => tenantDetail(id));
  }

  Future<TenantDetail?> tenantDetail(int id) async {
    final t = await (select(tenants)..where((x) => x.id.equals(id))).getSingleOrNull();
    if (t == null) return null;
    final rows =
        await (select(allocations).join([
                innerJoin(beds, beds.id.equalsExp(allocations.bedId)),
                innerJoin(rooms, rooms.id.equalsExp(beds.roomId)),
              ])
              ..where(allocations.tenantId.equals(id))
              ..orderBy([OrderingTerm.desc(allocations.startDate), OrderingTerm.desc(allocations.id)]))
            .get();
    final history = [
      for (final r in rows) AllocationView(r.readTable(allocations), r.readTable(rooms), r.readTable(beds)),
    ];
    return TenantDetail(
      tenant: t,
      current: history.where((a) => a.allocation.isActive).firstOrNull,
      history: history,
      outstandingPaise: await db.billingDao.tenantOutstanding(id),
      creditPaise: await db.billingDao.tenantCredit(id),
    );
  }

  /// Beds a tenant can move into: active, not occupied, not under maintenance.
  Future<List<FreeBed>> freeBeds() async {
    final rows = await customSelect('''SELECT b.id AS bed_id FROM beds b JOIN rooms r ON r.id = b.room_id
         WHERE b.is_active = 1 AND r.is_active = 1 AND b.status <> 'maintenance'
           AND NOT EXISTS (SELECT 1 FROM allocations a WHERE a.bed_id = b.id AND a.is_active = 1)
         ORDER BY r.floor, r.room_number, b.label''').get();
    final out = <FreeBed>[];
    for (final r in rows) {
      final bed = await (select(beds)..where((b) => b.id.equals(r.read<int>('bed_id')))).getSingle();
      final room = await (select(rooms)..where((x) => x.id.equals(bed.roomId))).getSingle();
      out.add(FreeBed(room, bed));
    }
    return out;
  }

  static String? _n(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
