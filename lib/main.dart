import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'constants/app_theme.dart';
import 'services/appwrite_service.dart';
import 'services/mqtt_service.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/farm/farm_bloc.dart';
import 'blocs/sensor/sensor_bloc.dart';
import 'blocs/schedule/schedule_bloc.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/monitor/monitor_screen.dart';
import 'screens/control/control_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/farm_setup/farm_setup_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/device/device_screen.dart';
import 'screens/automation/automation_screen.dart';
import 'screens/schedule/schedule_screen.dart';
import 'screens/help/help_screen.dart';
import 'screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  AppwriteService().init();

  runApp(const SmartIrrigationApp());
}

class SmartIrrigationApp extends StatelessWidget {
  const SmartIrrigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final farmService = FarmService();
    final sensorService = SensorService();
    final scheduleService = ScheduleService();
    final notificationService = NotificationService();
    final automationService = AutomationServiceBackend();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AuthBloc(authService: authService, farmService: farmService)
                ..add(AuthCheckRequested()),
        ),
        BlocProvider(create: (_) => FarmBloc(farmService: farmService)),
        //BlocProvider(create: (_) => SensorBloc(sensorService: sensorService)),
        BlocProvider(create: (_) => ControlBloc(sensorService: sensorService)),
        BlocProvider(
          create: (_) => ScheduleBloc(scheduleService: scheduleService),
        ),
        BlocProvider(
          create: (_) =>
              NotificationBloc(notificationService: notificationService),
        ),
        BlocProvider(
          create: (_) => AutomationBloc(automationService: automationService),
        ),
        BlocProvider(create: (_) => SensorBloc(MqttService())..add(ConnectMqtt())),
      ],
      child: MaterialApp.router(
        title: 'Smart Irrigation System',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: _router,
      ),
    );
  }
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),
    GoRoute(path: '/farm-setup', builder: (_, __) => const FarmSetupScreen()),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/monitor', builder: (_, __) => const MonitorScreen()),
        GoRoute(path: '/control', builder: (_, __) => const ControlScreen()),
        GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      ],
    ),
    GoRoute(
      path: '/notifications',
      builder: (_, __) => const NotificationsScreen(),
    ),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    GoRoute(path: '/device', builder: (_, __) => const DeviceScreen()),
    GoRoute(path: '/automation', builder: (_, __) => const AutomationScreen()),
    GoRoute(path: '/schedule', builder: (_, __) => const ScheduleScreen()),
    GoRoute(path: '/help', builder: (_, __) => const HelpScreen()),
  ],
);
