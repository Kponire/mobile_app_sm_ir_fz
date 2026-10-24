import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _ringController;
  late AnimationController _loadingController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _ring1Scale;
  late Animation<double> _ring2Scale;
  late Animation<double> _ring1Opacity;
  late Animation<double> _ring2Opacity;
  late Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _ring1Scale = Tween<double>(
      begin: 0.8,
      end: 1.6,
    ).animate(CurvedAnimation(parent: _ringController, curve: Curves.easeOut));
    _ring2Scale = Tween<double>(begin: 0.8, end: 2.0).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _ring1Opacity = Tween<double>(
      begin: 0.5,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ringController, curve: Curves.easeOut));
    _ring2Opacity = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _ringController.repeat();
      _loadingController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _ringController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  void _navigate(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      if (state.farm == null) {
        context.go('/farm-setup');
      } else {
        context.go('/home');
      }
    } else if (state is AuthUnauthenticated) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated || state is AuthUnauthenticated) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            // ignore: use_build_context_synchronously
            if (mounted) _navigate(context, state);
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo with pulsing rings
              AnimatedBuilder(
                animation: Listenable.merge([_logoController, _ringController]),
                builder: (context, _) {
                  return SizedBox(
                    width: 200,
                    height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Pulsing Logo (Replacing Ring 2)
                        Transform.scale(
                          scale: _ring2Scale.value,
                          child: Opacity(
                            opacity: _ring2Opacity.value,
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 180,
                              height: 180,
                            ),
                          ),
                        ),

                        // Middle Pulsing Logo (Replacing Ring 1)
                        Transform.scale(
                          scale: _ring1Scale.value,
                          child: Opacity(
                            opacity: _ring1Opacity.value,
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 180,
                              height: 180,
                            ),
                          ),
                        ),

                        // Main Center Logo (Replacing the Circle/Icon)
                        ScaleTransition(
                          scale: _logoScale,
                          child: FadeTransition(
                            opacity: _logoOpacity,
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 150,
                              height: 150,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.xl),

              // App name
              FadeTransition(
                opacity: _logoOpacity,
                child: Column(
                  children: [
                    Text(
                      'Automated Precision',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Irrigation',
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '& Nutrient Management System',
                      style: AppTextStyles.headlineSmall.copyWith(
                        letterSpacing: 0.5,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'IoT Powered Farm Monitoring',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Loading bar
              /* Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _loadingController,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppBorderRadius.full,
                        ),
                        child: LinearProgressIndicator(
                          value: _loadingProgress.value,
                          backgroundColor: AppColors.surfaceBg,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Initializing system...',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}
