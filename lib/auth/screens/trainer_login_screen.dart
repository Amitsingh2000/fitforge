import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../../onboarding/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class TrainerLoginScreen extends ConsumerStatefulWidget {
  const TrainerLoginScreen({super.key});

  @override
  ConsumerState<TrainerLoginScreen> createState() => _TrainerLoginScreenState();
}

class _TrainerLoginScreenState extends ConsumerState<TrainerLoginScreen>
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
      if (next.status == AuthStatus.authenticated && next.user?.role == UserRole.trainer) {
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
              Color(0xFF0F1B22), // Cyan/dark tint
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
                    Navigator.of(context).pushReplacementNamed('/login');
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

            // Ambient glows
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
                      AppColors.accentCyan.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main Content
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
                          const SizedBox(height: 56),

                          // Brand Section
                          _buildBrandSection()
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 200.ms)
                              .slideY(begin: 0.15, end: 0, duration: 600.ms, delay: 200.ms),

                          const SizedBox(height: 20),

                          // Welcome Section
                          _buildWelcomeSection()
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 400.ms)
                              .slideY(begin: 0.1, end: 0, duration: 600.ms, delay: 400.ms),

                          const SizedBox(height: 24),

                          // Login Form
                          _buildLoginForm(isLoading)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 500.ms)
                              .slideY(begin: 0.08, end: 0, duration: 600.ms, delay: 500.ms),

                          const SizedBox(height: 32),

                          // Back to Member Login Link
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacementNamed('/login');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Are you a member? ',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Login as Member',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.accentCyan,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 500.ms, delay: 700.ms),

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

  Widget _buildBrandSection() {
    return Column(
      children: [
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
                  colors: [AppColors.accentCyan, AppColors.accentBlue],
                ),
              ),
              child: const Icon(
                Icons.sports_rounded,
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
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: const LinearGradient(
              colors: [AppColors.accentCyan, AppColors.accentBlue],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Empower. Track. Transform.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
        Text(
          'Trainer Portal',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Access your client dashboard, review AI plans, and guide transformations.',
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

  Widget _buildLoginForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInputField(
          controller: _emailController,
          focusNode: _emailFocus,
          isFocused: _emailFocused,
          label: 'Trainer Email',
          hint: 'Enter your trainer email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
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
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed('/forgot-password'),
            child: Text(
              'Forgot Password?',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        PrimaryButton(
          label: isLoading ? 'Signing In...' : 'Sign In as Trainer',
          showShimmer: !isLoading,
          onTap: isLoading
              ? null
              : () {
                  ref.read(authProvider.notifier).loginAsTrainer(
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
            color: isFocused ? AppColors.accentCyan : AppColors.textTertiary,
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
                ? AppColors.accentCyan.withValues(alpha: 0.06)
                : AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused
                  ? AppColors.accentCyan.withValues(alpha: 0.4)
                  : AppColors.glassBorder,
              width: isFocused ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.accentCyan.withValues(alpha: 0.08),
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
            cursorColor: AppColors.accentCyan,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                icon,
                color: isFocused
                    ? AppColors.accentCyan
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
}
