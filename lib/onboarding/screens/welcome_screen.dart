import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/floating_stat_card.dart';
import '../widgets/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const WelcomeScreen({super.key, required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -0.3),
          radius: 1.4,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF0D0D12),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Subtle ambient glow top-right
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
                    AppColors.accentBlue.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Subtle ambient glow bottom-left
          Positioned(
            bottom: -40,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentPurple.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Floating stat cards
          Positioned(
            top: size.height * 0.1,
            left: 20,
            child: const FloatingStatCard(
              emoji: '🔥',
              label: 'Calories',
              value: '2,140',
              accentColor: AppColors.accentCoral,
              floatSpeed: 3.5,
              initialPhase: 0,
            )
                .animate()
                .fadeIn(duration: 800.ms, delay: 400.ms)
                .slideX(begin: -0.3, end: 0, duration: 800.ms, delay: 400.ms),
          ),

          Positioned(
            top: size.height * 0.08,
            right: 16,
            child: const FloatingStatCard(
              emoji: '💧',
              label: 'Hydration',
              value: '2.4L',
              accentColor: AppColors.accentCyan,
              floatSpeed: 4.0,
              initialPhase: 1.5,
            )
                .animate()
                .fadeIn(duration: 800.ms, delay: 600.ms)
                .slideX(begin: 0.3, end: 0, duration: 800.ms, delay: 600.ms),
          ),

          Positioned(
            top: size.height * 0.24,
            right: 30,
            child: const FloatingStatCard(
              emoji: '⚡',
              label: 'Streak',
              value: '14 days',
              accentColor: AppColors.accentOrange,
              floatSpeed: 3.0,
              initialPhase: 3.0,
            )
                .animate()
                .fadeIn(duration: 800.ms, delay: 800.ms)
                .slideX(begin: 0.3, end: 0, duration: 800.ms, delay: 800.ms),
          ),

          Positioned(
            top: size.height * 0.26,
            left: 16,
            child: const FloatingStatCard(
              emoji: '✦',
              label: 'XP Earned',
              value: '2,450',
              accentColor: AppColors.accentPurple,
              floatSpeed: 3.8,
              initialPhase: 4.5,
            )
                .animate()
                .fadeIn(duration: 800.ms, delay: 1000.ms)
                .slideX(begin: -0.3, end: 0, duration: 800.ms, delay: 1000.ms),
          ),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: constraints.maxHeight * 0.30),

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
                                  colors: [
                                    AppColors.accentBlue,
                                    AppColors.accentPurple,
                                  ],
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
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .slideY(begin: 0.2, end: 0),

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
                        ).animate().fadeIn(delay: 400.ms).scaleX(begin: 0, end: 1, delay: 400.ms, duration: 500.ms),

                        const SizedBox(height: 40),

                        // Tagline
                        Text(
                          'Build Your\nStrongest Version',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayLarge.copyWith(
                            height: 1.1,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 700.ms, delay: 500.ms)
                            .slideY(begin: 0.15, end: 0, duration: 700.ms, delay: 500.ms),

                        const SizedBox(height: 20),

                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Personalized fitness, nutrition tracking, and AI-powered diet plans — all in one.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 700.ms, delay: 700.ms)
                            .slideY(begin: 0.15, end: 0, duration: 700.ms, delay: 700.ms),

                        const SizedBox(height: 48),

                        // CTA
                        PrimaryButton(
                          label: 'Start Your Journey',
                          onTap: onGetStarted,
                        )
                            .animate()
                            .fadeIn(duration: 600.ms, delay: 1000.ms)
                            .slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 1000.ms),

                        const SizedBox(height: 20),

                        // Sign In link
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/login');
                          },
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                                fontSize: 14,
                              ),
                              children: [
                                const TextSpan(text: 'Already have an account? '),
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: AppColors.accentBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms, delay: 1200.ms),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
