// QA: drive real screens like an owner would and check that every field is
// pre-filled, saved, calculated and displayed correctly.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pg_manager/app/app.dart';
import 'package:pg_manager/core/database/app_database.dart';
import 'package:pg_manager/core/database/billing_math.dart';
import 'package:pg_manager/core/database/daos/billing_dao.dart';
import 'package:pg_manager/core/database/daos/tenants_dao.dart';
import 'package:pg_manager/core/database/enums.dart';
import 'package:pg_manager/core/services/auth_service.dart';
import 'package:pg_manager/core/services/providers.dart';
import 'package:pg_manager/core/utils/dates.dart';
import 'package:pg_manager/core/utils/money.dart';
import 'package:pg_manager/features/authentication/auth_controller.dart';

Future<void> settle(WidgetTester tester, [int n = 4]) async {
  for (var i = 0; i < n; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pump(const Duration(milliseconds: 250));
  }
}

class Qa {
  Qa(this.tester, this.db);
  final WidgetTester tester;
  final AppDatabase db;

  /// Opens a screen on top of Home, the way the app navigates.
  Future<void> go(String route) async {
    final el = tester.element(find.byType(Scaffold).first);
    ScaffoldMessenger.of(el).clearSnackBars();
    final router = GoRouter.of(el);
    router.go('/home');
    await settle(tester, 2);
    if (route != '/home') {
      router.push(route);
      await settle(tester);
    }
  }

  Finder get _vertical => find.byWidgetPredicate((w) => w is Scrollable && w.axisDirection == AxisDirection.down).last;

  /// Scrolls the screen until [f] is built and visible.
  Future<Finder> reveal(Finder f) async {
    if (f.evaluate().isEmpty && _vertical.evaluate().isNotEmpty) {
      // Back to the top, then search downwards.
      await tester.drag(_vertical, const Offset(0, 5000));
      await tester.pump(const Duration(milliseconds: 200));
      if (f.evaluate().isEmpty) {
        await tester.scrollUntilVisible(f, 250, scrollable: _vertical, maxScrolls: 40);
      }
    }
    await tester.ensureVisible(f.first);
    await tester.pump(const Duration(milliseconds: 200));
    return f.first;
  }

  Finder field(String label) => find.ancestor(of: find.text(label), matching: find.byType(TextField)).first;

  Future<String> textOf(String label) async {
    await reveal(find.text(label));
    return tester.widget<TextField>(field(label)).controller!.text;
  }

  Future<void> type(String label, String value) async {
    await reveal(find.text(label));
    await tester.enterText(field(label), value);
    await tester.pump();
  }

  Future<void> see(Finder f, {String? reason}) async {
    await reveal(f);
    expect(f, findsWidgets, reason: reason);
  }

  Future<void> tap(Finder f) async {
    final one = await reveal(f);
    await tester.tap(one, warnIfMissed: false);
    await settle(tester);
  }

  Future<void> pick(String dropdownLabel, String itemContains) async {
    await tap(find.text(dropdownLabel));
    final item = find.textContaining(itemContains).last;
    await tester.tap(item, warnIfMissed: false);
    await settle(tester);
  }

  Future<T> run<T>(Future<T> Function() f) async => (await tester.runAsync(f)) as T;
}

Future<(Qa, Map<String, int>)> boot(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final db = AppDatabase(NativeDatabase.memory());
  final auth = AuthService(store: MemorySecureStore(), iterations: 1000, hashInIsolate: false);
  final now = DateTime.now();
  final ids = (await tester.runAsync(() async {
    await db.settingsDao.saveProfile(
      name: 'Sunrise PG',
      address: '12 MG Road, Bengaluru',
      ownerName: 'Ravi Kumar',
      ownerPhone: '9876543210',
      upiId: 'ravi@okaxis',
      defaultRentDueDay: 7,
    );
    await db.settingsDao.setSetting('auto_receipt', 'false');
    await auth.setPin('2580');
    await auth.createRecoveryCode();
    await db.settingsDao.setSetting('last_backup_at', now.toIso8601String());
    final r101 = await db.roomsDao.addRoom(roomNumber: '101', floor: 1, rentPaise: 850000, bedCount: 3);
    await db.roomsDao.addRoom(roomNumber: '001', floor: 0, rentPaise: 750000, bedCount: 2);
    final beds = await (db.select(db.beds)..where((b) => b.roomId.equals(r101))).get();
    Future<int> tenant(String name, String phone, int bed) => db.tenantsDao.createTenant(
      TenantInput(
        fullName: name,
        phone: phone,
        gender: Gender.male,
        joiningDate: DateTime(now.year, now.month - 2, 10),
        monthlyRentPaise: 850000,
        rentDueDay: 5,
        securityDepositPaise: 1000000,
        emergencyContactName: 'Father',
        emergencyContactPhone: '9876500000',
        idProofType: 'Aadhaar',
      ),
      bedId: bed,
    );
    final a = await tenant('Arjun Mehta', '9876500001', beds[0].id);
    final b = await tenant('Bala Subramanian', '9876500002', beds[1].id);
    await db.tenantsDao.giveNotice(b, Dates.today(), Dates.today().add(const Duration(days: 12)));
    return {'a': a, 'b': b, 'room101': r101};
  }))!;

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db), authServiceProvider.overrideWithValue(auth)],
      child: const PgManagerApp(),
    ),
  );
  await settle(tester);
  for (final d in '2580'.split('')) {
    await tester.tap(find.text(d).last);
    await tester.pump();
  }
  await settle(tester);
  return (Qa(tester, db), ids);
}

Future<void> finish(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await settle(tester, 2);
  await tester.runAsync(() => db.close());
}

void main() {
  AuthController.splashMinimum = Duration.zero;
  setUpAll(() => initializeDateFormatting('en_IN'));

  testWidgets('register a tenant: defaults, every field saved, profile shows it, edit form pre-filled', (tester) async {
    final (qa, _) = await boot(tester);
    await qa.go('/tenants/new');

    // Defaults: PG due day, joining today, rent filled from the chosen room.
    await qa.see(find.text('Day 7 of every month'), reason: 'due day defaults to PG setting');
    expect(find.text(Dates.short(Dates.today())), findsWidgets, reason: 'joining date defaults to today');

    await qa.type('Full name', 'Kiran Kumar');
    await qa.type('Mobile number', '9876501234');
    await qa.type('Email (optional)', 'kiran@example.com');
    await qa.tap(find.text('Female'));
    await qa.type('Occupation / company (optional)', 'Infosys');
    await qa.type('Name and relation', 'Ravi (brother)');
    await qa.type('Emergency phone', '9876509999');
    await qa.pick('ID type', 'Driving licence');
    await qa.type('ID number (optional)', 'KA0120230001');
    await qa.pick('Bed', 'Room 101 · Bed C');
    expect(await qa.textOf('Monthly rent'), '8500', reason: 'rent copied from the room');
    await qa.type('Security deposit', '12,000');
    await qa.type('Notes (optional)', 'Vegetarian');
    await qa.tap(find.text('Register tenant'));

    final t = await qa.run(() => (qa.db.select(qa.db.tenants)..where((x) => x.phone.equals('9876501234'))).getSingle());
    expect(t.fullName, 'Kiran Kumar');
    expect(t.email, 'kiran@example.com');
    expect(t.gender, Gender.female);
    expect(t.occupation, 'Infosys');
    expect(t.emergencyContactName, 'Ravi (brother)');
    expect(t.emergencyContactPhone, '9876509999');
    expect(t.idProofType, 'Driving licence');
    expect(t.idProofNumber, 'KA0120230001');
    expect(t.monthlyRentPaise, 850000);
    expect(t.securityDepositPaise, 1200000);
    expect(t.rentDueDay, 7);
    expect(t.notes, 'Vegetarian');
    expect(t.status, TenantStatus.active);

    // First rent bill: this month, charged from today.
    final inv = await qa.run(() => (qa.db.select(qa.db.rentInvoices)..where((i) => i.tenantId.equals(t.id))).get());
    final today = Dates.today();
    expect(inv.single.rentPaise, BillingMath.rentForMonth(850000, today, today.year, today.month));
    expect(inv.single.dueDate, BillingMath.dueDate(today.year, today.month, 7, today));

    // Profile shows what was saved.
    expect(find.text('Kiran Kumar'), findsWidgets);
    expect(find.text('Room 101 · Bed C'), findsWidgets);
    expect(find.text('₹12,000 deposit'), findsOneWidget);

    // Edit form is pre-filled with every saved value.
    await qa.go('/tenants/${t.id}/edit');
    expect(await qa.textOf('Full name'), 'Kiran Kumar');
    expect(await qa.textOf('Mobile number'), '9876501234');
    expect(await qa.textOf('Email (optional)'), 'kiran@example.com');
    expect(await qa.textOf('Occupation / company (optional)'), 'Infosys');
    expect(await qa.textOf('Name and relation'), 'Ravi (brother)');
    expect(await qa.textOf('Emergency phone'), '9876509999');
    expect(await qa.textOf('ID number (optional)'), 'KA0120230001');
    expect(await qa.textOf('Monthly rent'), '8500');
    expect(await qa.textOf('Security deposit'), '12000');
    expect(await qa.textOf('Notes (optional)'), 'Vegetarian');
    await qa.see(find.text('Driving licence'));
    await qa.see(find.text('Day 7 of every month'));

    await qa.type('Mobile number', '9876501235');
    await qa.tap(find.text('Save changes'));
    final edited = await qa.run(() => (qa.db.select(qa.db.tenants)..where((x) => x.id.equals(t.id))).getSingle());
    expect(edited.phone, '9876501235');
    expect(edited.securityDepositPaise, 1200000, reason: 'unchanged fields stay');
    expect(edited.idProofType, 'Driving licence');
    await finish(tester, qa.db);
  });

  testWidgets('long form: an empty field far above the Save button still blocks saving', (tester) async {
    final (qa, _) = await boot(tester);
    await qa.go('/tenants/new');
    await qa.type('Monthly rent', '8000');
    await qa.tap(find.text('Register tenant'));
    await qa.see(find.text('Full name is required'));
    final count = await qa.run(() => qa.db.select(qa.db.tenants).get());
    expect(count, hasLength(2), reason: 'nothing new saved');
    await finish(tester, qa.db);
  });

  testWidgets('collect rent: amount pre-filled, confirmation shows the right facts, payment applied', (tester) async {
    final (qa, ids) = await boot(tester);
    final due = await qa.run(() => qa.db.billingDao.tenantOutstanding(ids['b']!));
    await qa.go('/payments/collect?tenant=${ids['b']}');
    expect(await qa.textOf('Amount received'), Money.toInput(due), reason: 'whole due amount pre-filled');

    await qa.tap(find.text('UPI'));
    await qa.type('UPI transaction number', '6123 4567 0000');
    await qa.tap(find.text('I checked my UPI / bank app and the money has arrived'));
    await qa.tap(find.textContaining('Record ₹'));

    // Confirmation sheet states amount, person, method and months.
    expect(find.text('Save this payment?'), findsOneWidget);
    expect(find.text(Money.format(due)), findsWidgets);
    expect(find.text('Bala Subramanian'), findsWidgets);
    expect(find.textContaining('UPI · 6123 4567 0000'), findsOneWidget);
    await qa.tap(find.text('Yes, save'));

    final p = await qa.run(
      () => (qa.db.select(qa.db.payments)..where((x) => x.tenantId.equals(ids['b']!))).getSingle(),
    );
    expect(p.amountPaise, due);
    expect(p.method, PaymentMethod.upi);
    expect(p.status, PaymentStatus.confirmed, reason: 'owner ticked verified');
    expect(p.upiReference, '612345670000', reason: 'spaces removed');
    expect(await qa.run(() => qa.db.billingDao.tenantOutstanding(ids['b']!)), 0);
    expect(p.balanceAfterPaise, 0, reason: 'receipt balance frozen at zero');

    // Payment screen shows the result.
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text(Money.format(due)), findsWidgets);
    expect(find.textContaining('Send receipt to Bala'), findsOneWidget);
    await finish(tester, qa.db);
  });

  testWidgets('new rent bill: rent pre-filled from tenant, month and due date correct', (tester) async {
    final (qa, ids) = await boot(tester);
    await qa.go('/invoices/new?tenant=${ids['a']}');
    expect(await qa.textOf('Rent'), '8500');
    await qa.tap(find.byTooltip('Next month'));
    final next = DateTime(DateTime.now().year, DateTime.now().month + 1);
    expect(find.text(Dates.monthYear(next)), findsOneWidget);
    expect(find.text(Dates.short(DateTime(next.year, next.month, 5))), findsOneWidget, reason: 'due day 5');
    await qa.type('Additional charges', '450');
    expect(find.text('₹8,950'), findsOneWidget, reason: 'total updates live');
    await qa.tap(find.text('Create rent bill'));
    final inv = await qa.run(() => qa.db.billingDao.invoiceFor(ids['a']!, next.year, next.month));
    expect(inv!.rentPaise, 850000);
    expect(inv.additionalChargesPaise, 45000);
    expect(inv.totalPaise, 895000);
    expect(inv.dueDate, DateTime(next.year, next.month, 5));
    await finish(tester, qa.db);
  });

  testWidgets('checkout: date pre-filled from notice, settlement equals the real result, bad deduction blocked', (
    tester,
  ) async {
    final (qa, ids) = await boot(tester);
    final leave = Dates.today().add(const Duration(days: 12));
    await qa.go('/tenants/${ids['b']}/checkout');
    expect(find.text(Dates.short(leave)), findsOneWidget, reason: 'expected checkout date used');
    final preview = await qa.run(() => qa.db.billingDao.previewCheckout(ids['b']!, leave));
    expect(find.text(Money.format(preview.settlementPaise.abs())), findsWidgets);
    expect(find.text(preview.settlementPaise >= 0 ? 'Refund to tenant' : 'Collect from tenant'), findsOneWidget);

    await qa.type('Deductions (damages, cleaning…)', '12.345');
    await qa.tap(find.text('Confirm checkout'));
    expect(find.text('Confirm checkout'), findsWidgets, reason: 'still on the screen');
    expect(find.textContaining('valid amount'), findsOneWidget, reason: 'error shown next to the field');
    final t = await qa.run(() => (qa.db.select(qa.db.tenants)..where((x) => x.id.equals(ids['b']!))).getSingle());
    expect(t.status, TenantStatus.noticeGiven, reason: 'nothing saved');
    await finish(tester, qa.db);
  });

  testWidgets('room: add with stepper, edit form pre-filled, bed count change saved', (tester) async {
    final (qa, _) = await boot(tester);
    await qa.go('/rooms/new');
    await qa.pick('Floor', 'Third Floor');
    await qa.type('Room number', '305');
    await qa.type('Rent per bed (monthly)', '9,000');
    await qa.tap(find.byTooltip('More beds'));
    expect(find.text('3 beds'), findsOneWidget);
    await qa.tap(find.text('Add room'));
    final room = await qa.run(() => (qa.db.select(qa.db.rooms)..where((r) => r.roomNumber.equals('305'))).getSingle());
    expect(room.floor, 3);
    expect(room.rentPaise, 900000);
    final beds = await qa.run(() => (qa.db.select(qa.db.beds)..where((b) => b.roomId.equals(room.id))).get());
    expect(beds.map((b) => b.label), ['A', 'B', 'C']);

    await qa.go('/rooms/${room.id}/edit');
    expect(await qa.textOf('Room number'), '305');
    expect(await qa.textOf('Rent per bed (monthly)'), '9000');
    await qa.see(find.text('3 beds'));
    await qa.see(find.text('Third Floor'));
    await qa.tap(find.byTooltip('Fewer beds'));
    await qa.tap(find.text('Save changes'));
    final active = await qa.run(
      () => (qa.db.select(qa.db.beds)..where((b) => b.roomId.equals(room.id) & b.isActive.equals(true))).get(),
    );
    expect(active, hasLength(2));
    await finish(tester, qa.db);
  });

  testWidgets('expense: category fills title, saved and totalled on the expenses screen', (tester) async {
    final (qa, _) = await boot(tester);
    await qa.go('/more/expenses/new');
    await qa.tap(find.text('Water'));
    expect(await qa.textOf('Title'), 'Water');
    await qa.type('Amount', '1,500');
    await qa.tap(find.text('Bank'));
    await qa.type('Vendor (optional)', 'BWSSB');
    await qa.tap(find.text('Save expense'));
    final e = await qa.run(() => qa.db.select(qa.db.expenses).getSingle());
    expect(e.category, ExpenseCategory.water);
    expect(e.amountPaise, 150000);
    expect(e.paymentMethod, PaymentMethod.bank);
    expect(e.vendor, 'BWSSB');
    expect(e.expenseDate, Dates.today());
    await qa.go('/more/expenses');
    expect(find.text('₹1,500'), findsWidgets);
    await finish(tester, qa.db);
  });

  testWidgets('PG profile: edit form pre-filled and saved', (tester) async {
    final (qa, _) = await boot(tester);
    await qa.go('/more/settings/profile');
    expect(await qa.textOf('PG name'), 'Sunrise PG');
    expect(await qa.textOf('Address'), '12 MG Road, Bengaluru');
    expect(await qa.textOf('Owner name'), 'Ravi Kumar');
    expect(await qa.textOf('Owner phone'), '9876543210');
    expect(await qa.textOf('UPI ID (optional)'), 'ravi@okaxis');
    await qa.see(find.text('7th of every month'));
    await qa.type('UPI ID (optional)', 'ravi@okhdfcbank');
    await qa.tap(find.text('Save changes'));
    final p = await qa.run(() => qa.db.settingsDao.getProfile());
    expect(p!.upiId, 'ravi@okhdfcbank');
    expect(p.name, 'Sunrise PG');
    await finish(tester, qa.db);
  });

  testWidgets('home figures equal the database summary', (tester) async {
    final (qa, _) = await boot(tester);
    await qa.go('/home');
    final s = await qa.run(() => qa.db.dashboardDao.summary(DateRange.currentMonth()));
    expect(find.text(Money.format(s.rentCollectedPaise)), findsWidgets);
    expect(find.text(Money.format(s.outstandingPaise)), findsWidgets);
    expect(find.text(Money.format(s.expensesPaise)), findsWidgets);
    expect(
      find.text('${Money.format(s.billedPaidPaise)} of ${Money.format(s.rentBilledPaise)} billed is paid'),
      findsOneWidget,
    );
    await qa.see(find.text('Overdue · ${s.overdue.length}'.toUpperCase()));
    await finish(tester, qa.db);
  });

  testWidgets('complaint: saved with tenant and room, edit form pre-filled, change saved', (tester) async {
    final (qa, ids) = await boot(tester);
    await qa.go('/more/complaints/new?tenant=${ids['a']}');
    await qa.tap(find.text('Plumbing'));
    await qa.type('Description', 'Bathroom tap leaking');
    await qa.tap(find.text('High'));
    await qa.pick('Room (optional)', 'Room 101');
    await qa.tap(find.text('Log complaint'));
    final c = await qa.run(() => qa.db.select(qa.db.complaints).getSingle());
    expect(c.category, 'Plumbing');
    expect(c.description, 'Bathroom tap leaking');
    expect(c.priority, ComplaintPriority.high);
    expect(c.tenantId, ids['a']);
    expect(c.roomId, ids['room101']);

    await qa.go('/more/complaints/${c.id}/edit');
    expect(await qa.textOf('Description'), 'Bathroom tap leaking');
    await qa.see(find.textContaining('Arjun Mehta'));
    await qa.see(find.textContaining('Room 101 · First Floor'));
    await qa.type('Description', 'Bathroom tap and shower leaking');
    await qa.tap(find.text('Save changes'));
    final e = await qa.run(() => qa.db.select(qa.db.complaints).getSingle());
    expect(e.description, 'Bathroom tap and shower leaking');
    expect(e.tenantId, ids['a'], reason: 'tenant kept');
    await finish(tester, qa.db);
  });

  testWidgets('notice: saved, edit form pre-filled', (tester) async {
    final (qa, _) = await boot(tester);
    await qa.go('/more/notices/new');
    await qa.tap(find.text('Water / power cut'));
    await qa.type('Title', 'Water off Sunday');
    await qa.type('Message', 'From 10 AM to 2 PM.');
    await qa.tap(find.text('Save'));
    final n = await qa.run(() => qa.db.select(qa.db.notices).getSingle());
    expect(n.category, 'Water / power cut');
    expect(n.title, 'Water off Sunday');
    expect(n.publishDate, Dates.today());
    await qa.go('/more/notices/${n.id}');
    expect(await qa.textOf('Title'), 'Water off Sunday');
    expect(await qa.textOf('Message'), 'From 10 AM to 2 PM.');
    await finish(tester, qa.db);
  });

  testWidgets('expense correction: form pre-filled, original voided only when saved', (tester) async {
    final (qa, _) = await boot(tester);
    final id = await qa.run(
      () => qa.db.opsDao.addExpense(
        title: 'Power bill',
        category: ExpenseCategory.electricity,
        amountPaise: 1240000,
        date: Dates.today(),
        method: PaymentMethod.upi,
        vendor: 'BESCOM',
      ),
    );
    await qa.go('/more/expenses/new?from=$id');
    expect(await qa.textOf('Title'), 'Power bill');
    expect(await qa.textOf('Amount'), '12400');
    expect(await qa.textOf('Vendor (optional)'), 'BESCOM');
    // Backing out keeps the original.
    final before = await qa.run(() => (qa.db.select(qa.db.expenses)..where((e) => e.id.equals(id))).getSingle());
    expect(before.isVoided, isFalse);
    await qa.type('Amount', '12,040');
    await qa.tap(find.text('Save expense'));
    final all = await qa.run(() => qa.db.select(qa.db.expenses).get());
    expect(all, hasLength(2));
    expect(all.firstWhere((e) => e.id == id).isVoided, isTrue);
    expect(all.firstWhere((e) => e.id != id).amountPaise, 1204000);
    final total = await qa.run(() => qa.db.dashboardDao.summary(DateRange.currentMonth()));
    expect(total.expensesPaise, 1204000, reason: 'only the corrected amount counts');
    await finish(tester, qa.db);
  });

  testWidgets('rent bill: charges and discount change the total and the due', (tester) async {
    final (qa, ids) = await boot(tester);
    final now = DateTime.now();
    final inv = await qa.run(() => qa.db.billingDao.invoiceFor(ids['a']!, now.year, now.month));
    await qa.go('/invoices/${inv!.id}');
    await qa.tap(find.text('Add charge or discount'));
    await qa.type('Additional charges', '600');
    await qa.type('Discount', '100');
    await qa.tap(find.text('Save'));
    final after = await qa.run(() => qa.db.billingDao.invoiceFor(ids['a']!, now.year, now.month));
    expect(after!.totalPaise, inv.rentPaise + 60000 - 10000);
    await qa.see(find.text(Money.format(after.totalPaise)));
    await finish(tester, qa.db);
  });
}

// Keeps the import used when assertions change.
// ignore: unused_element
PaymentInput _unused() => throw UnimplementedError();
