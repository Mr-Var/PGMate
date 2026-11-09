import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/pin_pad.dart';
import '../../shared/widgets/state_views.dart';
import '../authentication/auth_controller.dart';
import 'pg_profile_form.dart';

final _biometricStateProvider = FutureProvider.autoDispose<(bool available, bool enabled)>((ref) async {
  final auth = ref.watch(authServiceProvider);
  return (await auth.canUseBiometrics(), await auth.isBiometricEnabled());
});

Future<bool?> _verify(AuthService auth, String pin) async => switch (await auth.verifyPin(pin)) {
      PinOk() => true,
      PinWrong() => false,
      PinLockedOut() => null,
    };

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(pgProfileProvider);
    final bio = ref.watch(_biometricStateProvider);
    final auth = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 0, Gap.lg, Gap.xxl),
        children: [
          const SectionHeader(title: 'PG profile'),
          AppCard(
            padding: EdgeInsets.zero,
            child: profile.when(
              loading: () => const ListTile(title: SkeletonBox(width: 160)),
              error: (e, _) => ListTile(title: Text('Could not load profile: $e')),
              data: (p) => ListTile(
                minTileHeight: 72,
                leading: const Icon(Icons.apartment_rounded, color: AppColors.primary),
                title: Text(p?.name ?? 'Not set'),
                subtitle: Text(p == null ? '' : '${p.ownerName} · ${p.ownerPhone}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/more/settings/profile'),
              ),
            ),
          ),
          const SectionHeader(title: 'Security'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  minTileHeight: 64,
                  leading: const Icon(Icons.pin_outlined, color: AppColors.primary),
                  title: const Text('Change PIN'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _changePin(context, ref),
                ),
                const Divider(indent: 56),
                bio.when(
                  loading: () => const ListTile(title: SkeletonBox(width: 160)),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (b) => SwitchListTile(
                    secondary: const Icon(Icons.fingerprint_rounded, color: AppColors.primary),
                    title: const Text('Biometric unlock'),
                    subtitle: Text(b.$1 ? 'Use fingerprint to open the app' : 'Not available on this device'),
                    value: b.$2 && b.$1,
                    onChanged: !b.$1
                        ? null
                        : (on) async {
                            if (on) {
                              final ok = await auth.authenticateWithBiometrics('Confirm to enable biometric unlock');
                              if (!ok) return;
                            }
                            await auth.setBiometricEnabled(on);
                            ref.invalidate(_biometricStateProvider);
                          },
                  ),
                ),
                const Divider(indent: 56),
                ListTile(
                  minTileHeight: 64,
                  leading: const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
                  title: const Text('Lock now'),
                  onTap: () => ref.read(authControllerProvider.notifier).lock(),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Reminders'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Consumer(
              builder: (context, ref, _) {
                final on = ref.watch(remindersEnabledProvider).value ?? true;
                return SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                  title: const Text('Rent due reminders'),
                  subtitle: const Text('A notification at 9 AM when a tenant\'s rent is due'),
                  value: on,
                  onChanged: (v) async {
                    final db = ref.read(databaseProvider);
                    final reminders = ref.read(reminderServiceProvider);
                    if (v) await reminders.requestPermission();
                    await db.settingsDao.setSetting('reminders_enabled', '$v');
                    await refreshReminders(db, reminders);
                  },
                );
              },
            ),
          ),
          const SectionHeader(title: 'About'),
          const AppCard(
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.success),
                SizedBox(width: Gap.md),
                Expanded(
                  child: Text(
                    'All data is stored only on this device. No account, cloud service or internet connection is needed.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changePin(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authServiceProvider);
    final ok = await confirmOwnerPin(
      context,
      title: 'Current PIN',
      message: 'Enter your current PIN.',
      verify: (pin) => _verify(auth, pin),
    );
    if (!ok || !context.mounted) return;

    String? first;
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        String? error;
        return StatefulBuilder(
          builder: (ctx, setState) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(first == null ? 'New PIN' : 'Confirm new PIN', style: Theme.of(ctx).textTheme.titleLarge),
                  const SizedBox(height: Gap.xl),
                  PinPad(
                    length: AuthService.pinLength,
                    errorText: error,
                    onCompleted: (pin) async {
                      if (first == null) {
                        final e = AuthService.validatePin(pin);
                        if (e != null) return setState(() => error = e);
                        setState(() {
                          first = pin;
                          error = null;
                        });
                      } else if (pin != first) {
                        setState(() {
                          first = null;
                          error = 'PINs did not match. Start again.';
                        });
                      } else {
                        await auth.setPin(pin);
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (changed == true) {
      await ref.read(databaseProvider).settingsDao.log('auth', null, 'pin_changed');
      if (context.mounted) showAppSnack(context, 'PIN changed');
    }
  }
}

class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(pgProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('PG profile')),
      body: profile.when(
        loading: () => const LoadingList(),
        error: (e, _) => ErrorState(error: e),
        data: (p) => ListView(
          padding: const EdgeInsets.all(Gap.lg),
          children: [
            PgProfileForm(
              initial: p,
              submitLabel: 'Save changes',
              onSubmit: (d) async {
                await ref.read(databaseProvider).settingsDao.saveProfile(
                      name: d.name,
                      address: d.address,
                      ownerName: d.ownerName,
                      ownerPhone: d.ownerPhone,
                      upiId: d.upiId,
                      defaultRentDueDay: d.rentDueDay,
                    );
                if (context.mounted) {
                  showAppSnack(context, 'Profile saved');
                  context.pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
