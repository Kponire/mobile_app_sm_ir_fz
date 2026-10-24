import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../blocs/auth/auth_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _nameCtrl = TextEditingController(text: state.user.fullName);
      _emailCtrl = TextEditingController(text: state.user.email);
      _phoneCtrl = TextEditingController(text: state.user.phone ?? '');
    } else {
      _nameCtrl = TextEditingController();
      _emailCtrl = TextEditingController();
      _phoneCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthProfileUpdateRequested({
        'fullName': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
      }),
    );
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppMainBar(
        title: 'My Profile',
        showBack: true,
        actions: [
          IconButton(
            onPressed: () => setState(() => _editing = !_editing),
            icon: Icon(
              _editing ? Icons.close_rounded : Icons.edit_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const LoadingWidget();
          }
          final user = state.user;
          final farm = state.farm;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      if (_editing)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.sm),
                  Text(user.fullName, style: AppTextStyles.headlineLarge),
                  Text(user.email, style: AppTextStyles.bodyMedium),

                  if (farm != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    StatusBadge(
                      label: '🌿 ${farm.name}',
                      color: AppColors.primary,
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),

                  // Form fields
                  AppCard(
                    child: Column(
                      children: [
                        AppTextField(
                          label: 'Full Name',
                          controller: _nameCtrl,
                          readOnly: !_editing,
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            size: 20,
                          ),
                          validator: (v) =>
                              v?.isEmpty == true ? 'Name is required' : null,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Email Address',
                          controller: _emailCtrl,
                          readOnly: true, // Email not editable
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Phone Number',
                          controller: _phoneCtrl,
                          readOnly: !_editing,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (farm != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.agriculture_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Farm Info',
                                style: AppTextStyles.headlineSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          InfoRow(label: 'Farm Name', value: farm.name),
                          const Divider(),
                          InfoRow(label: 'Location', value: farm.location),
                          const Divider(),
                          InfoRow(label: 'Device ID', value: farm.deviceId),
                          const Divider(),
                          InfoRow(
                            label: 'Water Source',
                            value: farm.waterSource,
                          ),
                          const Divider(),
                          InfoRow(label: 'Zones', value: '${farm.zonesCount}'),
                        ],
                      ),
                    ),
                  ],

                  if (_editing) ...[
                    const SizedBox(height: AppSpacing.xl),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (_, s) => PrimaryButton(
                        label: 'Update Profile',
                        onPressed: _save,
                        isLoading: s is AuthLoading,
                        icon: Icons.save_rounded,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
