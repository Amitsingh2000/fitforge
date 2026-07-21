import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'onboarding/onboarding_flow.dart';
import 'dashboard/screens/home_dashboard.dart';
import 'auth/screens/login_screen.dart';
import 'auth/screens/gym_owner_login_screen.dart';
import 'gym_owner/screens/gym_owner_dashboard.dart';
import 'auth/screens/trainer_login_screen.dart';
import 'trainer/screens/trainer_dashboard.dart';
import 'gym_owner/screens/gym_owner_trainers_screen.dart';
import 'gym_owner/screens/gym_owner_join_requests_screen.dart';
import 'dashboard/screens/billing_plans_screen.dart';
import 'dashboard/screens/settings_screen.dart';
import 'auth/screens/register_screen.dart';

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
  runApp(const ProviderScope(child: FitForgeApp()));
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
        '/onboarding': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as int?;
          return OnboardingFlow(initialPage: args ?? 0);
        },
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const HomeDashboard(),
        '/gym-owner-login': (context) => const GymOwnerLoginScreen(),
        '/gym-owner-dashboard': (context) => const GymOwnerDashboard(),
        '/trainer-login': (context) => const TrainerLoginScreen(),
        '/trainer-dashboard': (context) => const TrainerDashboard(),
        '/gym-owner-trainers': (context) => const GymOwnerTrainersScreen(),
        '/gym-owner-join-requests': (context) => const GymOwnerJoinRequestsScreen(),
        '/billing-plans': (context) => const BillingPlansScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/register': (context) => const RegisterScreen(isEmbeddedInOnboarding: false),
      },
    );
  }
}


