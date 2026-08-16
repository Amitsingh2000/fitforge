import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../theme/app_theme.dart';
import '../../onboarding/widgets/primary_button.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';

/// Shown immediately after successful registration.
/// Asks the user to check their inbox and verify their email before proceeding.
class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResending = false;
  bool _resentSuccess = false;
  String? _resendError;

  bool _tokenHandled = false;
  bool _isVerifying = false;
  bool _verifySuccess = false;
  String? _verifyError;

  // Auto-verify if a token arrived via deep link (fitforge://.../verify-email?token=...).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_tokenHandled) return;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    final token = args?['token'];
    if (token != null && token.isNotEmpty) {
      _tokenHandled = true;
      _verifyWithToken(token);
    }
  }

  Future<void> _verifyWithToken(String token) async {
    setState(() {
      _isVerifying = true;
      _verifyError = null;
    });
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/verify-email', data: {'token': token});
      if (mounted) {
        setState(() { _isVerifying = false; _verifySuccess = true; });
        Future.delayed(const Duration(milliseconds: 900), () {
          if (mounted) _continueAnyway();
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _verifyError = e.message ?? 'This verification link is invalid or has expired.';
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isVerifying = false; _verifyError = e.toString(); });
    }
  }

  Future<void> _resendVerification() async {
    setState(() {
      _isResending = true;
      _resendError = null;
      _resentSuccess = false;
    });
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/resend-verification');
      if (mounted) setState(() => _resentSuccess = true);
    } on DioException catch (e) {
      if (mounted) {
        setState(() =>
            _resendError = e.message ?? 'Could not resend. Try again later.');
      }
    } catch (e) {
      if (mounted) setState(() => _resendError = e.toString());
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _continueAnyway() {
    // User confirms they've verified — navigate to dashboard
    final authState = ref.read(authProvider);
    final user = authState.user;
    final role = user?.role;
    final targetRole = authState.targetRole;

    if (role == null && targetRole == null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    } else if (role == UserRole.gymOwner || targetRole == UserRole.gymOwner) {
      if (user?.gymMemberships.isEmpty ?? true) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/create-gym', (_) => false);
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/gym-owner-dashboard', (_) => false);
      }
    } else if (role == UserRole.trainer || targetRole == UserRole.trainer) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/trainer-dashboard', (_) => false);
    } else {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/dashboard', (_) => false);
    }
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = ref.watch(authProvider).user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.4),
            radius: 1.4,
            colors: [Color(0xFF141428), Color(0xFF0D0D12)],
          ),
        ),
        child: Stack(
          children: [
            // Top-right glow
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.accentBlue.withValues(alpha: 0.08),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            // Bottom-left glow
            Positioned(
              bottom: -60,
              left: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.accentCoral.withValues(alpha: 0.05),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Animated mail icon ─────────────────────────────────
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accentBlue.withValues(alpha: 0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Icon container
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accentBlue,
                                  Color(0xFF6366F1)
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentBlue
                                      .withValues(alpha: 0.35),
                                  blurRadius: 32,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.mark_email_unread_rounded,
                                color: Colors.white, size: 44),
                          ),
                        ],
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleXY(
                              begin: 1.0,
                              end: 1.04,
                              duration: 2000.ms,
                              curve: Curves.easeInOut),
                    ),

                    const SizedBox(height: 36),

                    // ── Heading ────────────────────────────────────────────
                    Text(
                      'Verify Your Email',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium
                          .copyWith(fontWeight: FontWeight.w800, fontSize: 28),
                    ).animate().fadeIn(duration: 600.ms, delay: 150.ms),

                    const SizedBox(height: 14),

                    Text(
                      "We've sent a verification link to",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary, height: 1.6),
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

                    const SizedBox(height: 4),

                    Text(
                      userEmail,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 250.ms),

                    const SizedBox(height: 24),

                    if (_isVerifying)
                      _buildFeedbackBanner(
                        message: 'Verifying your email…',
                        color: AppColors.accentBlue,
                        icon: Icons.hourglass_top_rounded,
                      ).animate().fadeIn(duration: 300.ms),

                    if (_verifySuccess)
                      _buildFeedbackBanner(
                        message: 'Email verified! Taking you in…',
                        color: const Color(0xFF10B981),
                        icon: Icons.verified_rounded,
                      ).animate().fadeIn(duration: 300.ms),

                    if (_verifyError != null)
                      _buildFeedbackBanner(
                        message: _verifyError!,
                        color: Colors.redAccent,
                        icon: Icons.error_outline_rounded,
                      ).animate().fadeIn(duration: 300.ms),

                    if (_isVerifying || _verifySuccess || _verifyError != null)
                      const SizedBox(height: 8),

                    const SizedBox(height: 8),

                    // ── Info card ──────────────────────────────────────────
                    _buildInfoCard()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 350.ms)
                        .slideY(begin: 0.08),

                    const SizedBox(height: 32),

                    // ── Feedback strip ─────────────────────────────────────
                    if (_resentSuccess)
                      _buildFeedbackBanner(
                        message: 'Verification email resent successfully!',
                        color: const Color(0xFF10B981),
                        icon: Icons.check_circle_outline_rounded,
                      ).animate().fadeIn(duration: 300.ms),

                    if (_resendError != null)
                      _buildFeedbackBanner(
                        message: _resendError!,
                        color: Colors.redAccent,
                        icon: Icons.error_outline_rounded,
                      ).animate().fadeIn(duration: 300.ms),

                    if (_resentSuccess || _resendError != null)
                      const SizedBox(height: 16),

                    // ── Primary CTA — Continue to App ─────────────────────
                    PrimaryButton(
                      label: "I've Verified — Continue",
                      showShimmer: true,
                      onTap: _continueAnyway,
                    ).animate().fadeIn(duration: 600.ms, delay: 450.ms),

                    const SizedBox(height: 14),

                    // ── Resend button ──────────────────────────────────────
                    _buildResendButton()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 550.ms),

                    const SizedBox(height: 32),

                    // ── Divider ────────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child:
                              Container(height: 1, color: AppColors.glassBorder),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textTertiary),
                          ),
                        ),
                        Expanded(
                          child:
                              Container(height: 1, color: AppColors.glassBorder),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Logout link ────────────────────────────────────────
                    GestureDetector(
                      onTap: _logout,
                      child: Center(
                        child: Text(
                          'Use a different account',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 650.ms),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          _buildStep(
            icon: Icons.inbox_rounded,
            color: AppColors.accentBlue,
            title: 'Check your inbox',
            subtitle:
                'Look for an email from FitForge. Check spam if you don\'t see it.',
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.glassBorder),
          const SizedBox(height: 16),
          _buildStep(
            icon: Icons.touch_app_rounded,
            color: AppColors.accentCyan,
            title: 'Click the link',
            subtitle: 'Tap "Verify Email" inside the email to confirm your account.',
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.glassBorder),
          const SizedBox(height: 16),
          _buildStep(
            icon: Icons.arrow_forward_rounded,
            color: const Color(0xFF10B981),
            title: 'Come back here',
            subtitle: 'Once verified, tap the button below to enter the app.',
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textTertiary, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResendButton() {
    return GestureDetector(
      onTap: _isResending ? null : _resendVerification,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isResending)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentBlue,
                ),
              )
            else
              const Icon(Icons.send_rounded,
                  color: AppColors.accentBlue, size: 18),
            const SizedBox(width: 10),
            Text(
              _isResending ? 'Resending...' : 'Resend Verification Email',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackBanner({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: AppTextStyles.caption.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}
