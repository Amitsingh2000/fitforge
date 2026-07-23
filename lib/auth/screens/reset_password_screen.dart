import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../onboarding/widgets/primary_button.dart';
import '../../services/api_client.dart';

/// Landed on via the reset-password link in the email.
/// The token arrives as a query param; in a real deep-link setup it would be
/// passed automatically. Here the user is asked to paste it from the email.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _tokenFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _tokenFocused = false;
  bool _passwordFocused = false;
  bool _confirmFocused = false;

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _success = false;
  String? _error;

  // Pre-fill token if passed as route argument (from deep link)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null && args['token'] != null) {
      _tokenController.text = args['token']!;
    }
  }

  @override
  void initState() {
    super.initState();
    _tokenFocus.addListener(
        () => setState(() => _tokenFocused = _tokenFocus.hasFocus));
    _passwordFocus.addListener(
        () => setState(() => _passwordFocused = _passwordFocus.hasFocus));
    _confirmFocus.addListener(
        () => setState(() => _confirmFocused = _confirmFocus.hasFocus));
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _tokenFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (token.isEmpty) {
      setState(() => _error = 'Please enter the reset token from your email.');
      return;
    }
    if (password.length < 8) {
      setState(
          () => _error = 'New password must be at least 8 characters long.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/reset-password',
          data: {'token': token, 'newPassword': password});
      if (mounted) setState(() => _success = true);
    } on DioException catch (e) {
      if (mounted) {
        setState(
            () => _error = e.message ?? 'Reset failed. The link may have expired.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.4,
            colors: [Color(0xFF1A1A2E), Color(0xFF0D0D12)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.accentPurple.withValues(alpha: 0.07),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.accentBlue.withValues(alpha: 0.05),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.bgSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: AppColors.textSecondary),
                      ),
                    ),

                    const SizedBox(height: 48),

                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.accentPurple,
                              AppColors.accentBlue,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentPurple.withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.shield_rounded,
                            color: Colors.white, size: 36),
                      )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                    ),

                    const SizedBox(height: 32),

                    Text(
                      _success ? 'Password Updated!' : 'Set New Password',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                          fontWeight: FontWeight.w800, fontSize: 28),
                    ).animate().fadeIn(duration: 600.ms, delay: 150.ms),

                    const SizedBox(height: 12),

                    Text(
                      _success
                          ? 'Your password has been reset. You can now sign in with your new password.'
                          : 'Paste the reset token from your email and choose a new password.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary, height: 1.6),
                    ).animate().fadeIn(duration: 600.ms, delay: 250.ms),

                    const SizedBox(height: 40),

                    if (_success) ...[
                      _buildSuccessCard()
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .slideY(begin: 0.1),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: 'Go to Login',
                        showShimmer: true,
                        onTap: () =>
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/login', (route) => false),
                      ),
                    ] else ...[
                      _buildForm()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 350.ms),

                      const SizedBox(height: 8),

                      if (_error != null)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.redAccent.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Colors.redAccent, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_error!,
                                    style: AppTextStyles.caption
                                        .copyWith(color: Colors.redAccent)),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 24),

                      PrimaryButton(
                        label: _isLoading ? 'Updating...' : 'Reset Password',
                        showShimmer: !_isLoading,
                        onTap: _isLoading ? null : _submit,
                      ).animate().fadeIn(duration: 600.ms, delay: 450.ms),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _buildField(
          controller: _tokenController,
          focusNode: _tokenFocus,
          isFocused: _tokenFocused,
          label: 'Reset Token',
          hint: 'Paste the token from your email',
          icon: Icons.vpn_key_outlined,
        ),
        const SizedBox(height: 16),
        _buildField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          isFocused: _passwordFocused,
          label: 'New Password',
          hint: 'Enter new password (min 8 chars)',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          toggleObscure: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 16),
        _buildField(
          controller: _confirmController,
          focusNode: _confirmFocus,
          isFocused: _confirmFocused,
          label: 'Confirm Password',
          hint: 'Re-enter your new password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirm,
          toggleObscure: () =>
              setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color:
                isFocused ? AppColors.accentBlue : AppColors.textTertiary,
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
                    )
                  ]
                : [],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: obscureText,
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textPrimary, fontSize: 15),
            cursorColor: AppColors.accentBlue,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textDisabled, fontSize: 14),
              prefixIcon: Icon(icon,
                  color: isFocused
                      ? AppColors.accentBlue
                      : AppColors.textTertiary,
                  size: 20),
              suffixIcon: toggleObscure != null
                  ? GestureDetector(
                      onTap: toggleObscure,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          obscureText
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ),
                    )
                  : null,
              suffixIconConstraints:
                  const BoxConstraints(minWidth: 40, minHeight: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF10B981), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Your password has been successfully updated.',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF10B981), fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
