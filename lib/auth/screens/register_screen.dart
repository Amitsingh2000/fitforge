import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../../onboarding/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';

import '../../models/user.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final bool isEmbeddedInOnboarding;
  final VoidCallback? onRegisterSuccess;
  final UserRole? targetRole;

  const RegisterScreen({
    super.key,
    this.isEmbeddedInOnboarding = false,
    this.onRegisterSuccess,
    this.targetRole,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with TickerProviderStateMixin {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  late UserRole _selectedRole;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _firstNameFocused = false;
  bool _lastNameFocused = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;
  bool _confirmPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.targetRole ?? UserRole.client;
    _firstNameFocus.addListener(() {
      setState(() => _firstNameFocused = _firstNameFocus.hasFocus);
    });
    _lastNameFocus.addListener(() {
      setState(() => _lastNameFocused = _lastNameFocus.hasFocus);
    });
    _emailFocus.addListener(() {
      setState(() => _emailFocused = _emailFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordFocused = _passwordFocus.hasFocus);
    });
    _confirmPasswordFocus.addListener(() {
      setState(() => _confirmPasswordFocused = _confirmPasswordFocus.hasFocus);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        final isGymOwner = _selectedRole == UserRole.gymOwner || next.targetRole == UserRole.gymOwner;
        if (isGymOwner) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
        } else if (widget.isEmbeddedInOnboarding) {
          // Navigate to email verification before continuing onboarding, and
          // let the host flow know registration succeeded so it can advance
          // its own page state while the verification screen sits on top.
          widget.onRegisterSuccess?.call();
          Navigator.of(context).pushNamed('/verify-email');
        } else {
          Navigator.of(context).pushReplacementNamed('/verify-email');
        }
      } else if (next.status == AuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Registration failed.'),
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
            // Back button (hide in onboarding since progress indicator handles navigation)
            if (!widget.isEmbeddedInOnboarding)
              Positioned(
                top: 16,
                left: 16,
                child: SafeArea(
                  child: GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacementNamed('/login');
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
                          if (!widget.isEmbeddedInOnboarding) const SizedBox(height: 56),

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

                          // Registration form
                          _buildRegisterForm(isLoading)
                              .animate()
                              .fadeIn(duration: 600.ms, delay: 500.ms)
                              .slideY(begin: 0.08, end: 0, duration: 600.ms, delay: 500.ms),

                          const SizedBox(height: 20),

                          if (!widget.isEmbeddedInOnboarding) ...[
                            // Login navigation
                            _buildLoginLink()
                                .animate()
                                .fadeIn(duration: 500.ms, delay: 700.ms),
                            const SizedBox(height: 24),
                          ],
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
          'Create Account',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'Join FitForge today to personalize your diet, track fitness milestones, and earn streaks.',
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
  // REGISTER FORM
  // ─────────────────────────────────────────────

  Widget _buildRegisterForm(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Role Selector Segmented Switch
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = UserRole.client),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedRole == UserRole.client
                          ? AppColors.accentBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '🏃‍♂️ Member',
                        style: TextStyle(
                          color: _selectedRole == UserRole.client
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRole = UserRole.gymOwner),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedRole == UserRole.gymOwner
                          ? AppColors.accentBlue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '🏋️‍♂️ Gym Owner',
                        style: TextStyle(
                          color: _selectedRole == UserRole.gymOwner
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // First Name & Last Name fields
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                controller: _firstNameController,
                focusNode: _firstNameFocus,
                isFocused: _firstNameFocused,
                label: 'First Name',
                hint: 'First name',
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInputField(
                controller: _lastNameController,
                focusNode: _lastNameFocus,
                isFocused: _lastNameFocused,
                label: 'Last Name',
                hint: 'Last name',
                icon: Icons.person_outline_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

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
          hint: 'Create a password (min. 8 chars)',
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
        const SizedBox(height: 14),

        // Confirm Password field
        _buildInputField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          isFocused: _confirmPasswordFocused,
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirmPassword,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            child: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 22),

        // Register button
        PrimaryButton(
          label: isLoading ? 'Registering...' : (_selectedRole == UserRole.gymOwner ? 'Register as Gym Owner' : 'Register'),
          showShimmer: !isLoading,
          onTap: isLoading
              ? null
              : () {
                  final firstName = _firstNameController.text.trim();
                  final lastName = _lastNameController.text.trim();
                  final email = _emailController.text.trim();
                  final password = _passwordController.text;
                  final confirmPassword = _confirmPasswordController.text;

                  if (firstName.isEmpty || lastName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter your first and last name.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  if (password.length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password must be at least 8 characters.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  if (password != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Passwords do not match.'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                    return;
                  }
                  ref.read(authProvider.notifier).register(
                        firstName,
                        lastName,
                        email,
                        password.trim(),
                        targetRole: _selectedRole,
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused
                  ? AppColors.accentBlue.withValues(alpha: 0.5)
                  : AppColors.glassBorder,
              width: 1.5,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.accentBlue.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
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
  // LOGIN LINK
  // ─────────────────────────────────────────────

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Text(
            'Login',
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
