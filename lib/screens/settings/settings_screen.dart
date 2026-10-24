import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../blocs/auth/auth_bloc.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _smsAlerts = false;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          side: const BorderSide(color: AppColors.borderColor),
        ),
        title: Text('Logout', style: AppTextStyles.headlineMedium),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
              context.go('/login');
            },
            child: Text(
              'Logout',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text('Settings', style: AppTextStyles.headlineLarge),
              ),
            ),

            // Account section
            _buildSection('Account Settings', [
              _SettingsNavItem(
                icon: Icons.person_outlined,
                label: 'My Profile',
                onTap: () => context.push('/profile'),
              ),
              _SettingsNavItem(
                icon: Icons.agriculture_rounded,
                label: 'Farm Settings',
                onTap: () => context.push('/farm-setup'),
              ),
              _SettingsNavItem(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () => context.push('/forgot-password'),
              ),
            ]),

            // Device section
            _buildSection('Device & Automation', [
              _SettingsNavItem(
                icon: Icons.devices_rounded,
                label: 'Device Management',
                onTap: () => context.push('/device'),
              ),
              _SettingsNavItem(
                icon: Icons.smart_toy_outlined,
                label: 'Automation Settings',
                onTap: () => context.push('/automation'),
              ),
              _SettingsNavItem(
                icon: Icons.schedule_rounded,
                label: 'Schedule',
                onTap: () => context.push('/schedule'),
              ),
            ]),

            // Notifications section
            _buildSection('Notification Settings', [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    ToggleRow(
                      title: 'Push Notifications',
                      subtitle: 'Receive alerts on your device',
                      value: _pushNotifications,
                      onChanged: (v) => setState(() => _pushNotifications = v),
                      icon: Icons.notifications_outlined,
                    ),
                    const Divider(
                      height: AppSpacing.lg,
                    ), // Increased spacing for light theme clarity
                    ToggleRow(
                      title: 'Email Alerts',
                      subtitle: 'Critical alerts via email',
                      value: _emailAlerts,
                      onChanged: (v) => setState(() => _emailAlerts = v),
                      icon: Icons.email_outlined,
                    ),
                    const Divider(height: AppSpacing.lg),
                    ToggleRow(
                      title: 'SMS Alerts',
                      subtitle: 'Text messages for critical events',
                      value: _smsAlerts,
                      onChanged: (v) => setState(() => _smsAlerts = v),
                      icon: Icons.sms_outlined,
                    ),
                  ],
                ),
              ),
            ]),

            // Support section
            _buildSection('Support', [
              _SettingsNavItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                onTap: () => context.push('/help'),
              ),
              _SettingsNavItem(
                icon: Icons.info_outline_rounded,
                label: 'About App',
                onTap: () => _showAbout(context),
              ),
            ]),

            // Logout
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: PrimaryButton(
                  label: 'Logout',
                  backgroundColor: AppColors.error.withOpacity(0.15),
                  icon: Icons.logout_rounded,
                  onPressed: _showLogoutDialog,
                ),
              ),
            ),

            // Version
            /* SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Center(
                  child: Text(
                    'Smart Irrigation v1.0.0',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
            ), */
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSection(String title, List<Widget> children) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(children: children),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          side: const BorderSide(color: AppColors.borderColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Icon(
                Icons.water_drop_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Smart Irrigation System',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text('Version 1.0.0', style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'IoT Powered Farm Monitoring & Control System',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withOpacity(0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color ?? AppColors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: AppTextStyles.headlineSmall)),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
