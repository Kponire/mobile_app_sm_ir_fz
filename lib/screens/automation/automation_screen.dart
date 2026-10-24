import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/schedule/schedule_bloc.dart';
import '../../models/models.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  AutomationSettings _settings = const AutomationSettings();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated && auth.farm != null) {
      context.read<AutomationBloc>().add(
        AutomationLoadRequested(auth.farm!.id),
      );
    }
  }

  void _save() {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || auth.farm == null) return;
    //print(auth.farm!.id);
    final updatedSettings = _settings.copyWith(farmId: auth.farm!.id);
    context.read<AutomationBloc>().add(
      AutomationSaveRequested(farmId: auth.farm!.id, settings: updatedSettings),
    );
  }

  void _update(AutomationSettings newSettings) {
    setState(() => _settings = newSettings);
    context.read<AutomationBloc>().add(AutomationSettingChanged(newSettings));
  }

  Future<void> _pickTime(String current, void Function(String) onPicked) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 6,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: AppColors.cardBg,
            dialBackgroundColor: AppColors.surfaceBg,
            hourMinuteColor: AppColors.surfaceBg,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onPicked(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AutomationBloc, AutomationState>(
      listener: (context, state) {
        if (state is AutomationLoaded || state is AutomationSaved) {
          final s = state is AutomationLoaded
              ? state.settings
              : (state as AutomationSaved).settings;
          setState(() => _settings = s);
        }
        if (state is AutomationSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Automation rules updated successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
        if (state is AutomationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.black,
          appBar: AppMainBar(
            title: 'Automation Settings',
            showBack: true,
            actions: [
              TextButton(
                onPressed: _save,
                child: Text(
                  'Save',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          body: state is AutomationLoading
              ? const LoadingWidget(message: 'Loading settings...')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configure smart irrigation rules',
                        style: AppTextStyles.bodyMedium,
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Irrigation Rules
                      _SectionLabel(
                        icon: Icons.water_drop_rounded,
                        label: 'Irrigation Rules',
                        color: AppColors.primary,
                      ),

                      AppCard(
                        child: Column(
                          children: [
                            _SliderRow(
                              label: 'Moisture Threshold',
                              value: _settings.moistureThreshold,
                              unit: '%',
                              min: 10,
                              max: 80,
                              onChanged: (v) => _update(
                                _settings.copyWith(moistureThreshold: v),
                              ),
                            ),
                            const Divider(),
                            _StepperRow(
                              label: 'Max Irrigation Time',
                              value: _settings.maxIrrigationTime,
                              unit: 'min',
                              onDecrement: () => _update(
                                _settings.copyWith(
                                  maxIrrigationTime:
                                      (_settings.maxIrrigationTime - 5).clamp(
                                        5,
                                        120,
                                      ),
                                ),
                              ),
                              onIncrement: () => _update(
                                _settings.copyWith(
                                  maxIrrigationTime:
                                      (_settings.maxIrrigationTime + 5).clamp(
                                        5,
                                        120,
                                      ),
                                ),
                              ),
                            ),
                            const Divider(),
                            _StepperRow(
                              label: 'Min Time Between',
                              value: _settings.minTimeBetweenIrrigation,
                              unit: 'min',
                              onDecrement: () => _update(
                                _settings.copyWith(
                                  minTimeBetweenIrrigation:
                                      (_settings.minTimeBetweenIrrigation - 30)
                                          .clamp(30, 720),
                                ),
                              ),
                              onIncrement: () => _update(
                                _settings.copyWith(
                                  minTimeBetweenIrrigation:
                                      (_settings.minTimeBetweenIrrigation + 30)
                                          .clamp(30, 720),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Fertigation Rules
                      _SectionLabel(
                        icon: Icons.eco_rounded,
                        label: 'Fertigation Rules',
                        color: AppColors.primaryLight,
                      ),

                      AppCard(
                        child: Column(
                          children: [
                            ToggleRow(
                              title: 'Enable Fertigation',
                              subtitle: 'Automated NPK nutrient delivery',
                              value: _settings.fertigationEnabled,
                              onChanged: (v) => _update(
                                _settings.copyWith(fertigationEnabled: v),
                              ),
                              icon: Icons.eco_rounded,
                            ),
                            if (_settings.fertigationEnabled) ...[
                              const Divider(),
                              _StepperRow(
                                label: 'Fertigation Interval',
                                value: _settings.fertigationIntervalDays,
                                unit: 'days',
                                onDecrement: () => _update(
                                  _settings.copyWith(
                                    fertigationIntervalDays:
                                        (_settings.fertigationIntervalDays - 1)
                                            .clamp(1, 30),
                                  ),
                                ),
                                onIncrement: () => _update(
                                  _settings.copyWith(
                                    fertigationIntervalDays:
                                        (_settings.fertigationIntervalDays + 1)
                                            .clamp(1, 30),
                                  ),
                                ),
                              ),
                              const Divider(),
                              _StepperRow(
                                label: 'Fertigation Duration',
                                value: _settings.fertigationDuration,
                                unit: 'min',
                                onDecrement: () => _update(
                                  _settings.copyWith(
                                    fertigationDuration:
                                        (_settings.fertigationDuration - 5)
                                            .clamp(5, 60),
                                  ),
                                ),
                                onIncrement: () => _update(
                                  _settings.copyWith(
                                    fertigationDuration:
                                        (_settings.fertigationDuration + 5)
                                            .clamp(5, 60),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Weather Rules
                      _SectionLabel(
                        icon: Icons.cloud_rounded,
                        label: 'Weather-Based Rules',
                        color: AppColors.accentBlue,
                      ),

                      AppCard(
                        child: Column(
                          children: [
                            ToggleRow(
                              title: 'Stop on Rain',
                              subtitle:
                                  'Pause irrigation when rain is detected',
                              value: _settings.stopOnRain,
                              onChanged: (v) =>
                                  _update(_settings.copyWith(stopOnRain: v)),
                              icon: Icons.umbrella_rounded,
                            ),
                            const Divider(),
                            ToggleRow(
                              title: 'Reduce on High Humidity',
                              subtitle: 'Reduce watering when humidity > 80%',
                              value: _settings.reduceOnHighHumidity,
                              onChanged: (v) => _update(
                                _settings.copyWith(reduceOnHighHumidity: v),
                              ),
                              icon: Icons.water_rounded,
                            ),
                            const Divider(),
                            ToggleRow(
                              title: 'Increase on High Temp',
                              subtitle: 'Increase watering when temp > 35°C',
                              value: _settings.increaseOnHighTemp,
                              onChanged: (v) => _update(
                                _settings.copyWith(increaseOnHighTemp: v),
                              ),
                              icon: Icons.thermostat_rounded,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // ── Time Windows
                      _SectionLabel(
                        icon: Icons.access_time_rounded,
                        label: 'Allowed Time Windows',
                        color: AppColors.accentOrange,
                      ),

                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Irrigation Window',
                              style: AppTextStyles.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: _TimeButton(
                                    label: 'Start',
                                    time: _settings.irrigationWindowStart,
                                    onTap: () => _pickTime(
                                      _settings.irrigationWindowStart,
                                      (t) => _update(
                                        _settings.copyWith(
                                          irrigationWindowStart: t,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                  child: Text(
                                    'to',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                ),
                                Expanded(
                                  child: _TimeButton(
                                    label: 'End',
                                    time: _settings.irrigationWindowEnd,
                                    onTap: () => _pickTime(
                                      _settings.irrigationWindowEnd,
                                      (t) => _update(
                                        _settings.copyWith(
                                          irrigationWindowEnd: t,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_settings.fertigationEnabled) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Fertigation Window',
                                style: AppTextStyles.headlineSmall,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: _TimeButton(
                                      label: 'Start',
                                      time: _settings.fertigationWindowStart,
                                      onTap: () => _pickTime(
                                        _settings.fertigationWindowStart,
                                        (t) => _update(
                                          _settings.copyWith(
                                            fertigationWindowStart: t,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                    ),
                                    child: Text(
                                      'to',
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                  ),
                                  Expanded(
                                    child: _TimeButton(
                                      label: 'End',
                                      time: _settings.fertigationWindowEnd,
                                      onTap: () => _pickTime(
                                        _settings.fertigationWindowEnd,
                                        (t) => _update(
                                          _settings.copyWith(
                                            fertigationWindowEnd: t,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      BlocBuilder<AutomationBloc, AutomationState>(
                        builder: (_, s) => PrimaryButton(
                          label: 'Save Settings',
                          icon: Icons.save_rounded,
                          isLoading: s is AutomationLoading,
                          onPressed: _save,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final double min, max;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.headlineSmall),
            const Spacer(),
            Text(
              '${value.toStringAsFixed(0)}$unit',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceBg,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.12),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final VoidCallback onDecrement, onIncrement;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.unit,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.headlineSmall),
                Text('$value $unit', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          Row(
            children: [
              _StepButton(icon: Icons.remove, onTap: onDecrement),
              const SizedBox(width: 8),
              _StepButton(icon: Icons.add, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          // FIX: Removed "as Border" cast and used Border.all
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          // FIX: Removed "as Border" cast and used Border.all
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Fix for potential vertical overflow
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            const SizedBox(height: 2),
            Text(
              time,
              // Use a smaller style if headlineMedium is too large for the row
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
