import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../../onboarding/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _emailFocused = false;
  bool _passwordFocused = false;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {
      setState(() => _emailFocused = _emailFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordFocused = _passwordFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Authentication failed.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.4,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF0D0D12),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Back button
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pushReplacementNamed('/onboarding');
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.glassBorder,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Ambient glow — top right
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentBlue.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Ambient glow — bottom left
            Positioned(
              bottom: -60,
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accentPurple.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                        maxWidth: Layout.formMax,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 56), // Spacing for back button and top edge

                          // Logo + Brand
                          _buildBrandSection()
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 200.ms)
                              .slideY(begin: 0.15, end: 0, duration: 600.ms, delay: 200.ms),

                          const SizedBox(height: 20),

                          // Welcome heading
                          _buildWelcomeSection()
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 400.ms)
                              .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 400.ms),

                          const SizedBox(height: 24),

                          // Login form
                          _buildLoginForm(isLoading)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 500.ms)
                              .slideY(begin: 0.08, end: 0, duration: 600.ms, delay: 500.ms),

                          const SizedBox(height: 20),

                          // Social login
                          _buildSocialLogin()
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 700.ms),

                          const SizedBox(height: 20),

                          // Create account
                          _buildCreateAccount()
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 800.ms),

                          const SizedBox(height: 16),

                          // Gym Owner login
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed('/gym-owner-login');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: AppColors.accentPurple.withValues(alpha: 0.08),
                                border: Border.all(
                                  color: AppColors.accentPurple.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.store_rounded,
                                    color: AppColors.accentPurple,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Login as Gym Owner',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.accentPurple,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 900.ms),

                          const SizedBox(height: 10),

                          // Trainer login
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed('/trainer-login');
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: AppColors.accentCyan.withValues(alpha: 0.08),
                                border: Border.all(
                                  color: AppColors.accentCyan.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sports_rounded,
                                    color: AppColors.accentCyan,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Login as Trainer',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.accentCyan,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 950.ms),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }



  // ─────────────────────────────────────────────
  // BRAND SECTION
  // ─────────────────────────────────────────────

  Widget _buildBrandSection() {
    return Column(
      children: [
        // Logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accentBlue, AppColors.accentPurple],
                ),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'FITFORGE',
              style: AppTextStyles.titleLarge.copyWith(
                letterSpacing: 4,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Accent bar
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [AppColors.accentBlue, AppColors.accentPurple],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Tagline
        Text(
          'Consistency creates transformation.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // WELCOME SECTION
  // ─────────────────────────────────────────────

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
          'Welcome Back',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Continue your fitness journey, track your progress, and stay on top of your goals.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // LOGIN FORM
  // ─────────────────────────────────────────────

  Widget _buildLoginForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email field
        _buildInputField(
          controller: _emailController,
          focusNode: _emailFocus,
          isFocused: _emailFocused,
          label: 'Email Address',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),

        // Password field
        _buildInputField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          isFocused: _passwordFocused,
          label: 'Password',
          hint: 'Enter your password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/forgot-password'),
            child: Text(
              'Forgot Password?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),

        // Sign In button
        PrimaryButton(
          label: isLoading ? 'Signing In...' : 'Sign In',
          showShimmer: !isLoading,
          onTap: isLoading
              ? null
              : () {
                  ref.read(authProvider.notifier).login(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                },
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isFocused ? AppColors.accentBlue : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isFocused
                ? AppColors.accentBlue.withValues(alpha: 0.06)
                : AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused
                  ? AppColors.accentBlue.withValues(alpha: 0.4)
                  : AppColors.glassBorder,
              width: isFocused ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.accentBlue.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 15,
            ),
            cursorColor: AppColors.accentBlue,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: isFocused
                    ? AppColors.accentBlue
                    : AppColors.textTertiary,
                size: 20,
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: suffixIcon,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SOCIAL LOGIN
  // ─────────────────────────────────────────────

  Widget _buildSocialLogin() {
    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.glassBorder,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.glassBorder,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Social button — only Google Sign-In is backed by the API today.
        _buildSocialButton(
          label: 'Google',
          iconText: 'G',
          gradientColors: [
            AppColors.accentCoral.withValues(alpha: 0.1),
            AppColors.accentOrange.withValues(alpha: 0.06),
          ],
          iconColor: AppColors.accentCoral,
          onTap: () async {
            final uri = Uri.parse(
                'https://fitos-backend-55g6.onrender.com/api/v1/auth/google');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    String? iconText,
    IconData? icon,
    required List<Color> gradientColors,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(icon, color: iconColor, size: 22)
            else if (iconText != null)
              Text(
                iconText,
                style: AppTextStyles.titleMedium.copyWith(
                  color: iconColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            const SizedBox(width: 10),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CREATE ACCOUNT
  // ─────────────────────────────────────────────

  Widget _buildCreateAccount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/register');
          },
          child: Text(
            'Create Account',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.accentBlue,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }


}


