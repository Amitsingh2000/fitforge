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
import 'gym_owner/screens/create_gym_screen.dart';
import 'auth/screens/forgot_password_screen.dart';
import 'auth/screens/reset_password_screen.dart';
import 'auth/screens/email_verification_screen.dart';
import 'models/user.dart';
import 'providers/auth_provider.dart';
import 'providers/onboarding_provider.dart';

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
        '/create-gym': (context) => const CreateGymScreen(),
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
  bool _onboardingHydrationTriggered = false;

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
      return;
    }

    // Expected: fitforge://<host>/verify-email?token=... or
    // fitforge://<host>/reset-password?token=... — the backend builds these
    // from FRONTEND_URL, which must be set to the app's deep-link scheme for
    // this to fire (falls back to manual token paste otherwise, see those
    // screens). Matched on path segment so it's independent of host/scheme.
    final token = uri.queryParameters['token'];
    if (token != null && uri.pathSegments.contains('verify-email')) {
      Navigator.of(context).pushNamed('/verify-email', arguments: {'token': token});
      return;
    }
    if (token != null && uri.pathSegments.contains('reset-password')) {
      Navigator.of(context).pushNamed('/reset-password', arguments: {'token': token});
      return;
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

        final user = authState.user;
        final role = user?.role;
        final targetRole = authState.targetRole;

        if (role == UserRole.gymOwner || role == UserRole.frontDesk || targetRole == UserRole.gymOwner) {
          if (user != null && user.gymMemberships.isEmpty) {
            return const CreateGymScreen();
          }
          return const GymOwnerDashboard();
        } else if (role == UserRole.trainer || targetRole == UserRole.trainer) {
          return const TrainerDashboard();
        } else if (user != null && !user.isOnboardingComplete) {
          // Standalone/gym member who registered but never finished the
          // goal-intake wizard (or is resuming after the app was killed
          // mid-flow) — land back in the wizard instead of a half-set-up
          // dashboard. Rehydrate any progress already saved server-side.
          _hydrateOnboardingIfNeeded();
          return const OnboardingFlow(initialPage: 2);
        } else {
          return const HomeDashboard();
        }

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const OnboardingFlow();
    }
  }

  /// Loads any goal-intake profile fields already saved server-side into the
  /// onboarding wizard's local state, once per app session — so a user
  /// resuming an incomplete onboarding doesn't start from a blank wizard.
  void _hydrateOnboardingIfNeeded() {
    if (_onboardingHydrationTriggered) return;
    _onboardingHydrationTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingProvider.notifier).hydrateFromBackend();
    });
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
