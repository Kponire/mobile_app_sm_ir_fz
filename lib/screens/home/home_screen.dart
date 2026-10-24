import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sm_ir_fz/blocs/sensor/sensor_bloc.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/farm/farm_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock sensor data for display (in production replace with SensorBloc)
  /*   final _soilMoisture = 72.0;
  final _temperature = 28.4;
  final _humidity = 65.0;
  final _tankLevel = 84.0;
  final _pumpOn = false;
  final _systemOnline = true;
  final _currentMode = 'Automatic';
  final _activeOperation = 'Idle'; */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: BlocBuilder<SensorBloc, SensorState>(
          builder: (context, state) {
            // Extract data or provide null-safety defaults
            final data = state.data;
            //final isOnline = state.isConnected;
            final isOnline = state.data != null;

            // Helper to format doubles or return --
            String formatValue(double? value, {int precision = 0}) {
              if (!isOnline || value == null) return '--';
              return value.toStringAsFixed(precision);
            }

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader(context)),

                // Status Cards Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 1.35,
                        ),
                    delegate: SliverChildListDelegate([
                      SensorCard(
                        title: 'Soil Moisture',
                        // Taking average of two sensors if available
                        value: data != null
                            ? ((data.soilMoisture1 + data.soilMoisture2) / 2)
                                  .toStringAsFixed(0)
                            : '--',
                        unit: '%',
                        imagePath: "assets/images/home_soil_moisture.webp",
                      ),
                      SensorCard(
                        title: 'Temperature',
                        value: formatValue(data?.temperature, precision: 1),
                        unit: '°C',
                        imagePath: "assets/images/home_temperature.jpg",
                      ),
                      SensorCard(
                        title: 'Humidity',
                        value: formatValue(data?.humidity),
                        unit: '%',
                        imagePath: "assets/images/home_humidity.jpg",
                      ),
                      SensorCard(
                        title: 'TDS (Water Quality)',
                        value: formatValue(data?.tds),
                        unit: 'ppm',
                        imagePath: "assets/images/home_tank_level.webp",
                      ),
                    ]),
                  ),
                ),

                // Tank progress bar (using Boolean level sensor from model)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: _TankLevelBar(
                      // Pass null if offline, otherwise pass 1.0 or 0.0
                      level: (isOnline && data != null)
                          ? (data.tankLevel ? 1.0 : 0.0)
                          : null,
                    ),
                  ),
                ),

                // System status cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              // 1. Determine the status state
                              final bool isUnknown = !isOnline || data == null;
                              final bool isPumpOn = data?.pumpOn ?? false;

                              // 2. Define Display Values
                              String displayValue;
                              IconData displayIcon;
                              Color displayColor;

                              if (isUnknown) {
                                displayValue = '--';
                                displayIcon = TablerIcons.help;
                                displayColor = AppColors.textMuted;
                              } else {
                                displayValue = isPumpOn ? 'ON' : 'OFF';
                                displayIcon = isPumpOn
                                    ? TablerIcons.toggle_right
                                    : TablerIcons.toggle_left;
                                displayColor = isPumpOn
                                    ? AppColors.success
                                    : AppColors.textMuted;
                              }

                              return _StatusCard(
                                label: 'Pump',
                                value: displayValue,
                                icon: displayIcon,
                                color: displayColor,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _StatusCard(
                            label: 'System',
                            value: isOnline ? 'Online' : 'Offline',
                            icon: isOnline
                                ? TablerIcons.wifi
                                : TablerIcons.wifi_off,
                            color: isOnline
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final bool isUnknown = !isOnline || data == null;
                              final bool isRaining =
                                  data?.rainDetected ?? false;

                              return _StatusCard(
                                label: 'Rain',
                                value: isUnknown
                                    ? '--'
                                    : (isRaining ? 'Raining' : 'Dry'),
                                icon: isUnknown
                                    ? TablerIcons.cloud_question
                                    : (isRaining
                                          ? TablerIcons.cloud_rain
                                          : TablerIcons.sun),
                                color: isUnknown
                                    ? AppColors.textMuted
                                    : (isRaining
                                          ? AppColors.accentBlue
                                          : AppColors.accentOrange),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Operation status
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: AppCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_circle_outline_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Active Operation',
                                style: AppTextStyles.bodyMedium,
                              ),
                              Text(
                                (data?.pumpOn ?? false) ? 'Irrigating' : 'Idle',
                                style: AppTextStyles.headlineSmall,
                              ),
                            ],
                          ),
                          const Spacer(),
                          StatusBadge(
                            label: (data?.pumpOn ?? false) ? 'Active' : 'Idle',
                            color: (data?.pumpOn ?? false)
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Quick Actions'),
                        const SizedBox(height: AppSpacing.sm),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 1.35,
                          children: [
                            QuickActionButton(
                              label: 'Start Irrigation',
                              color: AppColors.primary,
                              onTap: () => context.go('/control'),
                            ),
                            QuickActionButton(
                              label: 'Stop Irrigation',
                              color: AppColors.error,
                              onTap: () => context.go('/control'),
                            ),
                            QuickActionButton(
                              label: 'View Reports',
                              color: AppColors.accentBlue,
                              onTap: () => context.go('/reports'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Last updated
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.update_rounded,
                            size: 12,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last updated: ${DateFormat('hh:mm a').format(DateTime.now())}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.lg),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final name = state is AuthAuthenticated
                    ? state.user.fullName.split(' ').first
                    : 'Farmer';
                final farm = state is AuthAuthenticated
                    ? state.farm?.name ?? 'My Farm'
                    : 'My Farm';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $name 👋', style: AppTextStyles.headlineLarge),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Farm: $farm',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          // Notification bell
          Stack(
            children: [
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: const Icon(Icons.notifications_outlined),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceBg,
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TankLevelBar extends StatelessWidget {
  final double? level; // Null means unknown/offline
  const _TankLevelBar({required this.level});

  @override
  Widget build(BuildContext context) {
    // Determine state
    final bool isUnknown = level == null;
    final bool isFull = level != null && level! > 0;

    // UI Configuration based on state
    String statusText = isUnknown
        ? 'Connection lost'
        : (isFull ? 'Float switch triggered' : 'Level below sensor');
    String badgeText = isUnknown ? 'UNKNOWN' : (isFull ? 'FILLED' : 'EMPTY');

    Color statusColor;
    if (isUnknown) {
      statusColor = AppColors.textMuted;
    } else {
      statusColor = isFull ? AppColors.success : AppColors.error;
    }

    return AppCard(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Water Tank Status', style: AppTextStyles.headlineSmall),
              Text(
                statusText,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor, width: 1),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatusCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
