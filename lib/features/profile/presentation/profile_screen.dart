import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/nav_widgets.dart';
import '../../../shared/widgets/screen.dart';
import '../../auth/application/auth_providers.dart';
import 'billing_screen.dart';
import 'family_screen.dart';
import 'notifications_screen.dart';
import 'preferences_screen.dart';
import 'settings_screen.dart';

/// Profile (Me) hub. Mirrors Lovable `_app.profile.tsx`.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    void go(Widget screen) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    return Screen(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
            child: Text(
              'Profile',
              style: Theme.of(context).textTheme.displaySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: PlainCard(
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.gradientSunset,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      user?.initials ?? 'YO',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name.isNotEmpty == true
                              ? user!.name
                              : 'Your Name',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.foreground,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email.isNotEmpty == true
                              ? user!.email
                              : 'Travel DNA: Explorer · Foodie · Family-first',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Section(
            title: 'Account',
            child: Column(
              children: [
                NavRow(
                  icon: Icons.public_rounded,
                  iconColor: AppColors.ocean,
                  title: 'Travel preferences',
                  onTap: () => go(const PreferencesScreen()),
                ),
                NavRow(
                  icon: Icons.group_rounded,
                  iconColor: AppColors.ocean,
                  title: 'Family & sharing',
                  onTap: () => go(const FamilyScreen()),
                ),
                NavRow(
                  icon: Icons.credit_card_rounded,
                  iconColor: AppColors.ocean,
                  title: 'Subscription',
                  onTap: () => go(const BillingScreen()),
                ),
                NavRow(
                  icon: Icons.notifications_rounded,
                  iconColor: AppColors.ocean,
                  title: 'Notifications',
                  onTap: () => go(const NotificationsScreen()),
                ),
                NavRow(
                  icon: Icons.settings_rounded,
                  iconColor: AppColors.ocean,
                  title: 'Settings',
                  onTap: () => go(const SettingsScreen()),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () => ref.read(authControllerProvider.notifier).logout(),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.destructive.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.destructive,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Sign out',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.destructive,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
