import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../models/models.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/farm/farm_bloc.dart';

class FarmSetupScreen extends StatefulWidget {
  const FarmSetupScreen({super.key});

  @override
  State<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class _FarmSetupScreenState extends State<FarmSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _farmNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _deviceIdCtrl = TextEditingController();
  int _zones = 3;
  String _waterSource = 'Tank';

  final _waterSources = ['Tank', 'Borehole', 'Well', 'River'];

  @override
  void dispose() {
    _farmNameCtrl.dispose();
    _locationCtrl.dispose();
    _deviceIdCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return;

    final farm = FarmModel(
      id: const Uuid().v4(),
      name: _farmNameCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      deviceId: _deviceIdCtrl.text.trim(),
      zonesCount: _zones,
      waterSource: _waterSource,
      userId: auth.user.id,
    );
    context.read<FarmBloc>().add(FarmSetupRequested(farm));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmBloc, FarmState>(
      listener: (context, state) {
        if (state is FarmLoaded) {
          context.go('/home');
        } else if (state is FarmError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // Header
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.brown.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(
                        color: AppColors.brownLight.withOpacity(0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.agriculture_rounded,
                      color: AppColors.brownLight,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  Text('Farm Setup', style: AppTextStyles.displayMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Connect your farm system',
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AppTextField(
                    label: 'Farm Name',
                    controller: _farmNameCtrl,
                    prefixIcon: const Icon(
                      Icons.local_florist_outlined,
                      size: 20,
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Farm name is required' : null,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: 'Farm Location',
                    controller: _locationCtrl,
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      size: 20,
                    ),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Location is required' : null,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: 'Device ID / System Serial Number',
                    controller: _deviceIdCtrl,
                    prefixIcon: const Icon(Icons.devices_outlined, size: 20),
                    validator: (v) =>
                        v?.isEmpty == true ? 'Device ID is required' : null,
                  ),

                  // Device ID hint
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Your Device ID is printed on the control box.',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Zones selector
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Number of Irrigation Zones',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [1, 2, 3, 4, 6, 8]
                              .map(
                                (z) => _ZoneChip(
                                  zones: z,
                                  isSelected: _zones == z,
                                  onTap: () => setState(() => _zones = z),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Water source
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Water Source Type',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          children: _waterSources
                              .map(
                                (s) => ChoiceChip(
                                  label: Text(s),
                                  selected: _waterSource == s,
                                  onSelected: (_) =>
                                      setState(() => _waterSource = s),
                                  selectedColor: AppColors.primary.withOpacity(
                                    0.2,
                                  ),
                                  backgroundColor: AppColors.surfaceBg,
                                  side: BorderSide(
                                    color: _waterSource == s
                                        ? AppColors.primary
                                        : AppColors.borderColor,
                                  ),
                                  labelStyle: AppTextStyles.labelMedium
                                      .copyWith(
                                        color: _waterSource == s
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  BlocBuilder<FarmBloc, FarmState>(
                    builder: (context, state) => PrimaryButton(
                      label: 'Save & Continue',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: state is FarmLoading,
                      onPressed: _save,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZoneChip extends StatelessWidget {
  final int zones;
  final bool isSelected;
  final VoidCallback onTap;

  const _ZoneChip({
    required this.zones,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceBg,
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$zones',
            style: AppTextStyles.headlineSmall.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
