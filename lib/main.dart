import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'providers/gym_provider.dart';
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
import 'auth/screens/forgot_password_screen.dart';
import 'auth/screens/reset_password_screen.dart';
import 'auth/screens/email_verification_screen.dart';
import 'models/user.dart';
import 'providers/auth_provider.dart';

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
      home: const _AppEntry(),
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
        '/gym-owner-join-requests': (context) =>
            const GymOwnerJoinRequestsScreen(),
        '/billing-plans': (context) => const BillingPlansScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/register': (context) =>
            const RegisterScreen(isEmbeddedInOnboarding: false),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/verify-email': (context) => const EmailVerificationScreen(),
      },
    );
  }
}

/// App entry widget that restores a persisted session on cold start.
/// Shows a splash/loading screen while checking stored tokens, then routes
/// to the appropriate screen.
class _AppEntry extends ConsumerStatefulWidget {
  const _AppEntry();

  @override
  ConsumerState<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends ConsumerState<_AppEntry> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();

    // Listen for incoming deep links (Google OAuth callback)
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });

    // Restore session asynchronously after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).tryRestoreSession();
    });
  }

  void _handleDeepLink(Uri uri) {
    // Expected: fitforge://oauth/callback?accessToken=...&refreshToken=...
    final accessToken = uri.queryParameters['accessToken'];
    final refreshToken = uri.queryParameters['refreshToken'];
    if (accessToken != null && refreshToken != null) {
      ref.read(authProvider.notifier).handleOAuthCallback(
            accessToken: accessToken,
            refreshToken: refreshToken,
          );
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        // Splash screen while checking stored tokens
        return const _SplashScreen();

      case AuthStatus.authenticated:
        // Auto-select gym if user has exactly one gym membership
        _autoSelectGymIfNeeded();

        final role = authState.user?.role;
        if (role == UserRole.gymOwner || role == UserRole.frontDesk) {
          return const GymOwnerDashboard();
        } else if (role == UserRole.trainer) {
          return const TrainerDashboard();
        } else {
          return const HomeDashboard();
        }

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const OnboardingFlow();
    }
  }

  /// If the authenticated user has exactly one gym membership,
  /// auto-select it so gym-scoped screens work immediately.
  void _autoSelectGymIfNeeded() {
    final user = ref.read(authProvider).user;
    if (user != null && user.gymMemberships.length == 1) {
      final current = ref.read(selectedGymProvider);
      if (current == null) {
        ref.read(selectedGymProvider.notifier).state =
            user.gymMemberships.first;
      }
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.accentBlue,
              strokeWidth: 2,
            ),
            SizedBox(height: 24),
            Text(
              'FITFORGE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
