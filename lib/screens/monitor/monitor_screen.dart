import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ir_fz/blocs/sensor/sensor_bloc.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/farm/farm_bloc.dart';
import 'dart:ui';

class MonitorScreen extends StatefulWidget {
  const MonitorScreen({super.key});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  // Mock data
  /* final _sensors = [
    _SensorItem(
      label: 'Soil Moisture',
      value: '72',
      unit: '%',
      imagePath: "assets/images/monitor_soil.jpg",
      status: 'Normal',
      statusColor: AppColors.success,
    ),
    _SensorItem(
      label: 'Temperature',
      value: '28.4',
      unit: '°C',
      imagePath: "assets/images/monitor_dht22.webp",
      status: 'Warm',
      statusColor: AppColors.warning,
    ),
    _SensorItem(
      label: 'Humidity',
      value: '65',
      unit: '%',
      imagePath: "assets/images/monitor_dht22.webp",
      status: 'Optimal',
      statusColor: AppColors.success,
    ),
    _SensorItem(
      label: 'Tank Level',
      value: '84',
      unit: '%',
      imagePath: "assets/images/monitor_tank_level.gif",
      status: 'Good',
      statusColor: AppColors.success,
    ),
    _SensorItem(
      label: 'Rainfall',
      value: '0',
      unit: 'mm',
      imagePath: "assets/imagesmonitor_rainfall.webp",
      status: 'No Rain',
      statusColor: AppColors.textMuted,
    ),
    _SensorItem(
      label: 'Light Level',
      value: '78',
      unit: '%',
      imagePath: "assets/images/monitor_ldr.gif",
      status: 'Bright',
      statusColor: AppColors.warning,
    ),
    _SensorItem(
      label: 'Total dissolved',
      value: '42',
      unit: 'ppm',
      imagePath: "assets/images/monitor_tds.webp",
      status: 'Low',
      statusColor: AppColors.warning,
    ),
    _SensorItem(
      label: 'Fertilizer Tank',
      value: '60',
      unit: '%',
      imagePath: "assets/images/monitor_tds.webp",
      status: 'Adequate',
      statusColor: AppColors.success,
    ),
  ]; */

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Monitor', style: AppTextStyles.headlineLarge),
                        Text(
                          'Real-time sensor data',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    const Spacer(),

                    // Connection status
                    BlocBuilder<SensorBloc, SensorState>(
                      builder: (context, state) {
                        // Determine if we are actively receiving data
                        final bool isLive = state.data != null;

                        return AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, __) => Row(
                            children: [
                              Opacity(
                                opacity: isLive ? _pulse.value : 0.3,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isLive ? 'Live' : 'Offline',
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Connection status card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: BlocBuilder<SensorBloc, SensorState>(
                  builder: (context, sensorState) {
                    // You can check if the state is 'SensorConnected' or if data is non-null
                    final bool isConnected = sensorState.data != null;

                    return AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isConnected
                                  ? AppColors.success
                                  : AppColors.error,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            isConnected
                                ? 'Device Connected'
                                : 'Device Disconnected',
                            style: AppTextStyles.headlineSmall,
                          ),
                          const Spacer(),
                          // Existing AuthBloc to show the Device ID
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, authState) {
                              final deviceId = authState is AuthAuthenticated
                                  ? authState.farm?.deviceId ?? '—'
                                  : '—';
                              return Text(
                                deviceId,
                                style: AppTextStyles.bodyMedium,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

            // Sensor grid
            BlocBuilder<SensorBloc, SensorState>(
              builder: (context, state) {
                if (state.data == null) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child:
                          CircularProgressIndicator(), // Better than just text
                    ),
                  );
                }

                final data = state.data!;

                final sensors = [
                  _SensorItem(
                    label: 'Soil Moisture 1',
                    value: data.soilMoisture1.toStringAsFixed(0),
                    unit: '%',
                    imagePath: "assets/images/monitor_soil.jpg",
                    status: data.soilMoisture1 < 40 ? 'Low' : 'Normal',
                    statusColor: data.soilMoisture1 < 40
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  _SensorItem(
                    label: 'Temperature',
                    value: data.temperature.toStringAsFixed(1),
                    unit: '°C',
                    imagePath: "assets/images/monitor_dht22.webp",
                    status: data.temperature > 25 ? 'Hot' : 'Normal',
                    statusColor: data.temperature > 25
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  _SensorItem(
                    label: 'Humidity',
                    value: data.humidity.toStringAsFixed(1),
                    unit: '%',
                    imagePath: "assets/images/monitor_dht22.webp",
                    status: data.humidity < 60 ? 'Low' : 'Optimal',
                    statusColor: data.humidity < 60
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                  _SensorItem(
                    label: 'Tank Level',
                    value: data.tankLevel ? "Filled" : "Empty",
                    unit: ' ',
                    imagePath: "assets/images/monitor_tank_level_2.jpg",
                    status: data.tankLevel ? 'Good' : 'Empty',
                    statusColor: data.tankLevel
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  _SensorItem(
                    label: 'Flow Rate',
                    value: data.flowRate.toStringAsFixed(1),
                    unit: ' ',
                    imagePath: "assets/images/monitor_flow_rate_2.webp",
                    status: data.flowRate > 0 ? 'Flowing' : 'Stopped',
                    statusColor: data.flowRate > 0
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  _SensorItem(
                    label: 'Rainfall',
                    value: data.rainDetected ? 'Raining' : 'Clear',
                    unit: ' ',
                    imagePath: "assets/images/monitor_rainfall.webp",
                    status: data.rainDetected ? 'Raining' : 'Clear',
                    statusColor: data.rainDetected
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  _SensorItem(
                    label: 'Light Level',
                    value: '78',
                    unit: '%',
                    imagePath: "assets/images/monitor_ldr.gif",
                    status: 'Bright',
                    statusColor: AppColors.warning,
                  ),
                  _SensorItem(
                    label: 'Total dissolved',
                    value: '42',
                    unit: 'ppm',
                    imagePath: "assets/images/monitor_tds.webp",
                    status: 'Low',
                    statusColor: AppColors.warning,
                  ),
                  _SensorItem(
                    label: 'Fertilizer Tank',
                    value: '60',
                    unit: '%',
                    imagePath: "assets/images/monitor_tds.webp",
                    status: 'Adequate',
                    statusColor: AppColors.success,
                  ),
                ];

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.sm,
                          mainAxisSpacing: AppSpacing.sm,
                          childAspectRatio: 1.1,
                        ),
                    delegate: SliverChildBuilderDelegate((context, i) {
                      return _SensorDetailCard(
                        key: ValueKey('sensor_card_${sensors[i].label}'),
                        item: sensors[i],
                      );
                    }, childCount: sensors.length),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

class _SensorItem {
  final String label;
  final String value;
  final String unit;
  final String imagePath;
  final String status;
  final Color statusColor;

  const _SensorItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.imagePath,
    required this.status,
    required this.statusColor,
  });
}

class _SensorDetailCard extends StatelessWidget {
  final _SensorItem item;
  const _SensorDetailCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 200, // Adjust as needed
        decoration: BoxDecoration(color: AppColors.surfaceBg),
        child: Stack(
          children: [
            // 1. THE IMAGE (Background)
            Positioned.fill(
              child: Image.asset(item.imagePath, fit: BoxFit.cover),
            ),

            // 2. STATUS BADGE (Glassmorphism Overlay at top)
            Positioned(
              top: 10,
              right: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: item.statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. BOTTOM INFO OVERLAY (Label left, Value right)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.0),
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Label (Left)
                        Expanded(
                          child: Text(
                            item.label,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Value + Unit (Right)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: item.value,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${item.unit}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
