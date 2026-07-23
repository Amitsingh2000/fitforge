import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../onboarding/widgets/primary_button.dart';
import '../../services/api_client.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();
  bool _emailFocused = false;
  bool _isLoading = false;
  bool _emailSent = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(
        () => setState(() => _emailFocused = _emailFocus.hasFocus));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/forgot-password', data: {'email': email});
      if (mounted) setState(() => _emailSent = true);
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _error = e.message ?? 'Something went wrong. Try again.');
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
            // Ambient glow — top right
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.accentBlue.withValues(alpha: 0.07),
                    Colors.transparent,
                  ]),
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
                  gradient: RadialGradient(colors: [
                    AppColors.accentPurple.withValues(alpha: 0.05),
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

                    // ── Back button ────────────────────────────────────────
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
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // ── Icon ───────────────────────────────────────────────
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.accentBlue, Color(0xFF6366F1)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentBlue.withValues(alpha: 0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
                    ),

                    const SizedBox(height: 32),

                    // ── Title ──────────────────────────────────────────────
                    Text(
                      'Forgot Password?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 150.ms),

                    const SizedBox(height: 12),

                    Text(
                      _emailSent
                          ? 'We\'ve sent a reset link to your email. Check your inbox and follow the instructions.'
                          : 'Enter the email address linked to your account and we\'ll send you a reset link.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 250.ms),

                    const SizedBox(height: 40),

                    if (_emailSent) ...[
                      // ── Success state ─────────────────────────────────
                      _buildSuccessCard().animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        label: 'Back to Login',
                        showShimmer: true,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 16),
                      _buildResendRow(),
                    ] else ...[
                      // ── Email field ───────────────────────────────────
                      _buildEmailField()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 350.ms),

                      const SizedBox(height: 8),

                      if (_error != null)
                        Container(
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
                                child: Text(
                                  _error!,
                                  style: AppTextStyles.caption.copyWith(
                                      color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 24),

                      PrimaryButton(
                        label: _isLoading ? 'Sending...' : 'Send Reset Link',
                        showShimmer: !_isLoading,
                        onTap: _isLoading ? null : _submit,
                      ).animate().fadeIn(duration: 600.ms, delay: 450.ms),

                      const SizedBox(height: 20),

                      _buildBackToLogin()
                          .animate()
                          .fadeIn(duration: 500.ms, delay: 550.ms),
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

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: AppTextStyles.caption.copyWith(
            color: _emailFocused ? AppColors.accentBlue : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _emailFocused
                ? AppColors.accentBlue.withValues(alpha: 0.06)
                : AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _emailFocused
                  ? AppColors.accentBlue.withValues(alpha: 0.4)
                  : AppColors.glassBorder,
              width: _emailFocused ? 1.5 : 1,
            ),
            boxShadow: _emailFocused
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
            controller: _emailController,
            focusNode: _emailFocus,
            keyboardType: TextInputType.emailAddress,
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.textPrimary, fontSize: 15),
            cursorColor: AppColors.accentBlue,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textDisabled, fontSize: 14),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: _emailFocused
                    ? AppColors.accentBlue
                    : AppColors.textTertiary,
                size: 20,
              ),
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
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email Sent!',
                    style: AppTextStyles.titleMedium.copyWith(
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  _emailController.text.trim(),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive it? ",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
            fontSize: 13,
          ),
        ),
        GestureDetector(
          onTap: () => setState(() {
            _emailSent = false;
            _error = null;
          }),
          child: Text(
            'Try again',
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

  Widget _buildBackToLogin() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Remember your password? ',
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textTertiary, fontSize: 13),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
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
