import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'onboarding/onboarding_flow.dart';
import 'dashboard/screens/home_dashboard.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/gym_owner_login_screen.dart';
import 'gym_owner/screens/gym_owner_dashboard.dart';
import 'gym_owner/screens/gym_owner_trainers_screen.dart';
import 'gym_owner/screens/gym_owner_join_requests_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FitForgeApp());
}

class FitForgeApp extends StatelessWidget {
  const FitForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const OnboardingFlow(),
      routes: {
        '/onboarding': (context) => const OnboardingFlow(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const HomeDashboard(),
        '/gym-owner-login': (context) => const GymOwnerLoginScreen(),
        '/gym-owner-dashboard': (context) => const GymOwnerDashboard(),
        '/gym-owner-trainers': (context) => const GymOwnerTrainersScreen(),
        '/gym-owner-join-requests': (context) => const GymOwnerJoinRequestsScreen(),
      },
    );
  }
}


