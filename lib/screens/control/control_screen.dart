import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sm_ir_fz/blocs/sensor/sensor_bloc.dart';
import 'package:sm_ir_fz/services/mqtt_service.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../blocs/auth/auth_bloc.dart';
//import '../../blocs/farm/farm_bloc.dart';

class ControlScreen extends StatefulWidget {
  const ControlScreen({super.key});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Irrigation state
  bool _pumpOn = false;
  bool _zoneA = false;
  bool _zoneB = false;
  bool _zoneC = false;
  int _irrigationDuration = 10;
  bool _isAutoMode = false;

  // Fertigation state
  bool _fertAPump = false;
  bool _fertBPump = false;
  bool _fertCPump = false;
  bool _mixingEnabled = false;
  int _fertigationDuration = 10;

  bool _isProcessing = false;

  final _durations = [5, 10, 20];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _deviceId {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) return state.farm?.deviceId ?? '';
    return '';
  }

  void _handleIrrigation(bool start) {
    final mqtt = context.read<MqttService>();
    mqtt.publish('farm/commands', {
      "type": "irrigation",
      "command": start ? "start" : "stop",
      "duration": _irrigationDuration,
      "zones": {"A": _zoneA, "B": _zoneB, "C": _zoneC},
    });
  }

  void _handleFertigation(bool start) {
    final mqtt = context.read<MqttService>();
    mqtt.publish('farm/commands', {
      "type": "fertigation",
      "command": start ? "start" : "stop",
      "duration": _fertigationDuration,
      "mixing": _mixingEnabled,
      "pumps": {"A": _fertAPump, "B": _fertBPump, "C": _fertCPump},
    });
  }

  Future<void> _sendCommand(VoidCallback action, String message) async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 600));
    action();
    setState(() => _isProcessing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Control', style: AppTextStyles.headlineLarge),
                          Text(
                            'Manual & automatic management',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Mode toggle
                      Row(
                        children: [
                          Text(
                            _isAutoMode ? 'Auto' : 'Manual',
                            style: AppTextStyles.labelMedium,
                          ),
                          const SizedBox(width: 6),
                          Switch(
                            value: _isAutoMode,
                            onChanged: (v) => setState(() => _isAutoMode = v),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Mode badge
                  Row(
                    children: [
                      StatusBadge(
                        label: 'Mode: ${_isAutoMode ? 'Automatic' : 'Manual'}',
                        color: _isAutoMode
                            ? AppColors.primary
                            : AppColors.accentBlue,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      StatusBadge(
                        label: 'Operation: Idle',
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Warnings
            if (!_isAutoMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: const [
                    WarningBanner(
                      message: 'Rain detected, irrigation may be blocked',
                      color: AppColors.warning,
                      icon: Icons.umbrella_rounded,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.sm),

            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceBg,
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textMuted,
                  labelStyle: AppTextStyles.labelLarge,
                  tabs: const [
                    Tab(text: 'Irrigation'),
                    Tab(text: 'Fertigation'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _IrrigationTab(
                    pumpOn: _pumpOn,
                    zoneA: _zoneA,
                    zoneB: _zoneB,
                    zoneC: _zoneC,
                    duration: _irrigationDuration,
                    durations: _durations,
                    isProcessing: _isProcessing,
                    onPumpToggle: (v) => _sendCommand(
                      () => setState(() => _pumpOn = v),
                      'Pump ${v ? 'started' : 'stopped'}',
                    ),
                    onZoneAToggle: (v) => _sendCommand(
                      () => setState(() => _zoneA = v),
                      'Zone A ${v ? 'activated' : 'deactivated'}',
                    ),
                    onZoneBToggle: (v) => _sendCommand(
                      () => setState(() => _zoneB = v),
                      'Zone B ${v ? 'activated' : 'deactivated'}',
                    ),
                    onZoneCToggle: (v) => _sendCommand(
                      () => setState(() => _zoneC = v),
                      'Zone C ${v ? 'activated' : 'deactivated'}',
                    ),
                    onDurationChanged: (d) =>
                        setState(() => _irrigationDuration = d),
                    onStart: () => _sendCommand(() {
                      _handleIrrigation(true);
                    }, 'Irrigation started for $_irrigationDuration mins'),
                    onStop: () => _sendCommand(() {
                      setState(() {
                        _pumpOn = false;
                        _zoneA = false;
                        _zoneB = false;
                        _zoneC = false;
                      });
                      _handleIrrigation(false);
                    }, 'Irrigation stopped'),
                  ),
                  _FertigationTab(
                    fertAPump: _fertAPump,
                    fertBPump: _fertBPump,
                    fertCPump: _fertCPump,
                    mixingEnabled: _mixingEnabled,
                    duration: _fertigationDuration,
                    durations: _durations,
                    isProcessing: _isProcessing,
                    onFertAToggle: (v) => setState(() => _fertAPump = v),
                    onFertBToggle: (v) => setState(() => _fertBPump = v),
                    onFertCToggle: (v) => setState(() => _fertCPump = v),
                    onMixingToggle: (v) => setState(() => _mixingEnabled = v),
                    onDurationChanged: (d) =>
                        setState(() => _fertigationDuration = d),
                    onStart: () => _sendCommand(() {
                      _handleFertigation(true);
                    }, 'Fertigation started for $_fertigationDuration mins'),
                    onStop: () => _sendCommand(() {
                      setState(() {
                        _fertAPump = false;
                        _fertBPump = false;
                        _fertCPump = false;
                      });
                      _handleFertigation(false);
                    }, 'Fertigation stopped'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Irrigation Tab
class _IrrigationTab extends StatelessWidget {
  final bool pumpOn, zoneA, zoneB, zoneC, isProcessing;
  final int duration;
  final List<int> durations;
  final ValueChanged<bool> onPumpToggle,
      onZoneAToggle,
      onZoneBToggle,
      onZoneCToggle;
  final ValueChanged<int> onDurationChanged;
  final VoidCallback onStart, onStop;

  const _IrrigationTab({
    required this.pumpOn,
    required this.zoneA,
    required this.zoneB,
    required this.zoneC,
    required this.isProcessing,
    required this.duration,
    required this.durations,
    required this.onPumpToggle,
    required this.onZoneAToggle,
    required this.onZoneBToggle,
    required this.onZoneCToggle,
    required this.onDurationChanged,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Pump button
          AppCard(
            child: Column(
              children: [
                BlocBuilder<SensorBloc, SensorState>(
                  builder: (context, state) {
                    bool isActuallyOn = state.data?.pumpOn ?? false;

                    return PumpButton(
                      isOn: isActuallyOn,
                      isLoading: isProcessing,
                      onToggle: () => onPumpToggle(!isActuallyOn),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Last Irrigation: Today, 6:15 AM',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Zone controls
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Valve Control', style: AppTextStyles.headlineSmall),
                const SizedBox(height: AppSpacing.md),
                _ZoneToggle(
                  label: 'Zone A',
                  isOn: zoneA,
                  onToggle: onZoneAToggle,
                ),
                const Divider(),
                _ZoneToggle(
                  label: 'Zone B',
                  isOn: zoneB,
                  onToggle: onZoneBToggle,
                ),
                const Divider(),
                _ZoneToggle(
                  label: 'Zone C',
                  isOn: zoneC,
                  onToggle: onZoneCToggle,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Duration selector
          _DurationSelector(
            duration: duration,
            durations: durations,
            onChanged: onDurationChanged,
          ),

          const SizedBox(height: AppSpacing.md),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Start',
                  icon: Icons.play_arrow_rounded,
                  onPressed: onStart,
                  isLoading: isProcessing,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PrimaryButton(
                  label: 'Stop',
                  icon: Icons.stop_rounded,
                  backgroundColor: AppColors.error,
                  onPressed: onStop,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Fertigation Tab
class _FertigationTab extends StatelessWidget {
  final bool fertAPump, fertBPump, fertCPump, mixingEnabled, isProcessing;
  final int duration;
  final List<int> durations;
  final ValueChanged<bool> onFertAToggle,
      onFertBToggle,
      onFertCToggle,
      onMixingToggle;
  final ValueChanged<int> onDurationChanged;
  final VoidCallback onStart, onStop;

  const _FertigationTab({
    required this.fertAPump,
    required this.fertBPump,
    required this.fertCPump,
    required this.mixingEnabled,
    required this.isProcessing,
    required this.duration,
    required this.durations,
    required this.onFertAToggle,
    required this.onFertBToggle,
    required this.onFertCToggle,
    required this.onMixingToggle,
    required this.onDurationChanged,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Warning banner
          const WarningBanner(
            message: 'Fertigation requires sufficient water level (>30%)',
            color: AppColors.warning,
            icon: Icons.warning_amber_rounded,
          ),

          const SizedBox(height: AppSpacing.md),

          // Fertilizer pump controls
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: AppColors.primaryLight,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fertilizer Pumps',
                      style: AppTextStyles.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _ZoneToggle(
                  label: 'Fertilizer A Pump',
                  isOn: fertAPump,
                  onToggle: onFertAToggle,
                  color: AppColors.primaryLight,
                ),
                const Divider(),
                _ZoneToggle(
                  label: 'Fertilizer B Pump',
                  isOn: fertBPump,
                  onToggle: onFertBToggle,
                  color: AppColors.accentOrange,
                ),
                const Divider(),
                _ZoneToggle(
                  label: 'Fertilizer C Pump',
                  isOn: fertCPump,
                  onToggle: onFertCToggle,
                  color: AppColors.accentPurple,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Mixing control
          AppCard(
            child: ToggleRow(
              title: 'Mixing Mode',
              subtitle: 'Enable nutrient mixing before delivery',
              value: mixingEnabled,
              onChanged: onMixingToggle,
              icon: Icons.blender_rounded,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          _DurationSelector(
            duration: duration,
            durations: durations,
            onChanged: onDurationChanged,
            label: 'Fertigation Duration',
          ),

          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Start Fertigation',
                  icon: Icons.play_arrow_rounded,
                  backgroundColor: AppColors.primaryLight,
                  onPressed: onStart,
                  isLoading: isProcessing,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PrimaryButton(
                  label: 'Stop',
                  icon: Icons.stop_rounded,
                  backgroundColor: AppColors.error,
                  onPressed: onStop,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                'Last Fertigation: Yesterday, 7:00 AM',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets
class _ZoneToggle extends StatelessWidget {
  final String label;
  final bool isOn;
  final ValueChanged<bool> onToggle;
  final Color? color;

  const _ZoneToggle({
    required this.label,
    required this.isOn,
    required this.onToggle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOn ? c : AppColors.borderColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTextStyles.headlineSmall),
          const Spacer(),
          Switch(value: isOn, onChanged: onToggle),
        ],
      ),
    );
  }
}

class _DurationSelector extends StatelessWidget {
  final int duration;
  final List<int> durations;
  final ValueChanged<int> onChanged;
  final String? label;

  const _DurationSelector({
    required this.duration,
    required this.durations,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label ?? 'Irrigation Duration',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ...durations.map(
                (d) => Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: GestureDetector(
                    onTap: () => onChanged(d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: duration == d
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.surfaceBg,
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                        border: Border.all(
                          color: duration == d
                              ? AppColors.primary
                              : AppColors.borderColor,
                          width: duration == d ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        '$d min',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: duration == d
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: !durations.contains(duration)
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.surfaceBg,
                      borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      border: Border.all(
                        color: !durations.contains(duration)
                            ? AppColors.primary
                            : AppColors.borderColor,
                      ),
                    ),
                    child: Text(
                      'Custom',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: !durations.contains(duration)
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
