import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../widgets/app_widgets.dart';
import '../../blocs/auth/auth_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordResetSent) {
          setState(() => _sent = true);
        } else if (state is AuthError) {
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
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _sent
              ? _SuccessView()
              : _FormView(formKey: _formKey, emailCtrl: _emailCtrl),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;

  const _FormView({required this.formKey, required this.emailCtrl});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: 56,
            height: 56,
            /* decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ), */
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppColors.primary,
              size: 56,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text('Reset Password', style: AppTextStyles.displayMedium),
          const SizedBox(height: 6),
          Text(
            'Enter your email and we\'ll send you a reset link.',
            style: AppTextStyles.bodyMedium,
          ),

          const SizedBox(height: AppSpacing.xl),

          AppTextField(
            label: 'Email Address',
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => PrimaryButton(
              label: 'Send Reset Link',
              isLoading: state is AuthLoading,
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                context.read<AuthBloc>().add(
                  AuthPasswordResetRequested(emailCtrl.text.trim()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Check your email!', style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We\'ve sent password reset instructions to your email address.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Back to Login',
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}
