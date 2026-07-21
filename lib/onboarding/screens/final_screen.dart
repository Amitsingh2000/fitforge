import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../widgets/animated_counter.dart';
import '../widgets/primary_button.dart';
import '../../providers/onboarding_provider.dart';

class FinalScreen extends ConsumerWidget {
  final VoidCallback onGeneratePlan;

  const FinalScreen({
    super.key,
    required this.onGeneratePlan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(onboardingProvider);
    final dailyCalories = onboardingState.dailyCalories;
    final protein = onboardingState.protein;
    final carbs = onboardingState.carbs;
    final water = onboardingState.water;
    final goal = onboardingState.goal ?? 'Stay Fit';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 72),

            Text(
              'Your personalized plan',
              style: AppTextStyles.headlineMedium,
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 8),
            Text(
              'You\'re ready to begin.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.accentBlue.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                goal,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accentBlue,
                  fontSize: 13,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms).scaleXY(begin: 0.9, end: 1, delay: 200.ms),

            const SizedBox(height: 32),

            // Stats grid — 2x2
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    emoji: '🔥',
                    label: 'DAILY CALORIES',
                    value: dailyCalories.toDouble(),
                    unit: 'kcal',
                    accentColor: AppColors.accentCoral,
                    delay: 300,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    emoji: '🥩',
                    label: 'PROTEIN',
                    value: protein.toDouble(),
                    unit: 'g',
                    accentColor: AppColors.accentBlue,
                    delay: 400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    emoji: '🌾',
                    label: 'CARBS',
                    value: carbs.toDouble(),
                    unit: 'g',
                    accentColor: AppColors.accentPurple,
                    delay: 500,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildStatCard(
                    emoji: '💧',
                    label: 'WATER INTAKE',
                    value: water,
                    unit: 'L',
                    accentColor: AppColors.accentCyan,
                    delay: 600,
                    decimals: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildTasksCard()
                .animate()
                .fadeIn(duration: 500.ms, delay: 700.ms)
                .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 700.ms),

            const SizedBox(height: 32),

            Center(
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentBlue.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.accentBlue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_rounded,
                      color: AppColors.accentBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your journey starts now',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 800.ms),

            const SizedBox(height: 24),

            PrimaryButton(
              label: 'Generate My Plan',
              showShimmer: true,
              onTap: onGeneratePlan,
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 900.ms)
                .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 900.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String label,
    required double value,
    required String unit,
    required Color accentColor,
    required int delay,
    int decimals = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const Spacer(),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  letterSpacing: 0.8,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  AnimatedCounter(
                    targetValue: value,
                    decimals: decimals,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                    duration: const Duration(milliseconds: 1000),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    unit,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.bgTertiary,
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 0.7),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (context, widthFactor, _) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: widthFactor,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: accentColor,
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay))
        .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: Duration(milliseconds: delay));
  }

  Widget _buildTasksCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentBlue.withValues(alpha: 0.08),
                AppColors.accentPurple.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentBlue.withValues(alpha: 0.2),
                      AppColors.accentPurple.withValues(alpha: 0.2),
                    ],
                  ),
                ),
                child: const Center(
                  child: Text('✦', style: TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY TASKS',
                      style: AppTextStyles.caption.copyWith(
                        letterSpacing: 0.8,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '6 tasks per day',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+50 XP each',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
