import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../blocs/auth/auth_bloc.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  bool _isTesting = false;
  bool _isRestarting = false;
  bool _isSyncing = false;

  // Mock device data
  final _deviceName = 'ESP8266 Controller';
  final _firmwareVersion = '2.3.1';
  final _lastSeen = DateTime.now().subtract(const Duration(minutes: 3));
  final _wifiName = 'FarmNet_2.4G';
  final _signalStrength = -62; // dBm
  final _isOnline = true;

  String get _signalLabel {
    if (_signalStrength >= -50) return 'Excellent';
    if (_signalStrength >= -65) return 'Good';
    if (_signalStrength >= -75) return 'Fair';
    return 'Poor';
  }

  Color get _signalColor {
    if (_signalStrength >= -50) return AppColors.success;
    if (_signalStrength >= -65) return AppColors.primaryLight;
    if (_signalStrength >= -75) return AppColors.warning;
    return AppColors.error;
  }

  int get _signalBars {
    if (_signalStrength >= -50) return 4;
    if (_signalStrength >= -65) return 3;
    if (_signalStrength >= -75) return 2;
    return 1;
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isTesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection test successful — 42ms latency'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _restart() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          side: const BorderSide(color: AppColors.borderColor),
        ),
        title: Text('Restart Device', style: AppTextStyles.headlineMedium),
        content: Text(
          'This will restart your ESP8266 controller. Any active irrigation will be paused.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Restart',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isRestarting = true);
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() => _isRestarting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device restarted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _sync() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings synced to device'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: const AppMainBar(title: 'Device Management', showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage connected irrigation devices',
              style: AppTextStyles.bodyMedium,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Connection status hero
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    /* decoration: BoxDecoration(
                      color: (_isOnline ? AppColors.success : AppColors.error)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(
                        color: (_isOnline ? AppColors.success : AppColors.error)
                            .withOpacity(0.3),
                      ),
                    ), */
                    child: Icon(
                      Icons.router_rounded,
                      color: _isOnline ? AppColors.success : AppColors.error,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_deviceName, style: AppTextStyles.headlineMedium),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isOnline
                                    ? AppColors.success
                                    : AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isOnline ? 'Online' : 'Offline',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: _isOnline
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Device info
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Information',
                    style: AppTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final deviceId = state is AuthAuthenticated
                          ? state.farm?.deviceId ?? '—'
                          : '—';
                      return Column(
                        children: [
                          InfoRow(label: 'Device ID', value: deviceId),
                          const Divider(),
                          InfoRow(label: 'Device Name', value: _deviceName),
                          const Divider(),
                          InfoRow(
                            label: 'Firmware',
                            value: 'v$_firmwareVersion',
                          ),
                          const Divider(),
                          InfoRow(
                            label: 'Last Seen',
                            value: DateFormat('hh:mm a').format(_lastSeen),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // WiFi info
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.wifi_rounded,
                        size: 18,
                        color: AppColors.accentBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'WiFi Connection',
                        style: AppTextStyles.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InfoRow(label: 'Network', value: _wifiName),
                  const Divider(),
                  Row(
                    children: [
                      Text('Signal Strength', style: AppTextStyles.bodyMedium),
                      const Spacer(),
                      // Signal bars
                      Row(
                        children: List.generate(
                          4,
                          (i) => Container(
                            width: 4,
                            height: 8.0 + (i * 4),
                            margin: const EdgeInsets.only(right: 2),
                            decoration: BoxDecoration(
                              color: i < _signalBars
                                  ? _signalColor
                                  : AppColors.borderColor,
                              borderRadius: BorderRadius.circular(
                                AppBorderRadius.xs,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_signalLabel ($_signalStrength dBm)',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: _signalColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            Text('Device Actions', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.sm),

            PrimaryButton(
              label: 'Test Connection',
              icon: Icons.wifi_find_rounded,
              isLoading: _isTesting,
              onPressed: _testConnection,
            ),

            const SizedBox(height: AppSpacing.sm),

            SecondaryButton(
              label: _isSyncing ? 'Syncing...' : 'Sync Settings',
              icon: Icons.sync_rounded,
              onPressed: _isSyncing ? null : _sync,
            ),

            const SizedBox(height: AppSpacing.sm),

            SecondaryButton(
              label: _isRestarting ? 'Restarting...' : 'Restart Device',
              icon: Icons.restart_alt_rounded,
              borderColor: AppColors.warning.withOpacity(0.5),
              onPressed: _isRestarting ? null : _restart,
            ),

            const SizedBox(height: AppSpacing.sm),

            SecondaryButton(
              label: 'Remove Device',
              icon: Icons.delete_outline_rounded,
              borderColor: AppColors.error.withOpacity(0.4),
              onPressed: () => _confirmRemove(context),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          side: const BorderSide(color: AppColors.borderColor),
        ),
        title: Text('Remove Device', style: AppTextStyles.headlineMedium),
        content: Text(
          'Are you sure you want to remove this device? This action cannot be undone.',
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Remove',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
