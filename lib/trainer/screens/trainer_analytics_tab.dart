import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';
import '../../dashboard/widgets/radial_progress.dart';
import '../widgets/trainer_glass_stat_card.dart';

class TrainerAnalyticsTab extends StatelessWidget {
  const TrainerAnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> clientProgress = [
      {'name': 'Rahul Sharma', 'goal': 'Weight Loss', 'val': 0.78, 'color': AppColors.accentCyan},
      {'name': 'Priya Patel', 'goal': 'Muscle Gain', 'val': 0.65, 'color': AppColors.accentPurple},
      {'name': 'Sneha Gupta', 'goal': 'Flexibility', 'val': 0.88, 'color': AppColors.accentBlue},
      {'name': 'Arjun Reddy', 'goal': 'Strength', 'val': 0.55, 'color': AppColors.accentOrange},
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Insights and performance trends regarding your training results.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Grid metrics
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverGrid.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              const TrainerGlassStatCard(
                title: 'Total Clients',
                value: 18,
                icon: Icons.people_rounded,
                color: AppColors.accentCyan,
                trendText: '+3 new',
              ),
              const TrainerGlassStatCard(
                title: 'Sessions Taught',
                value: 124,
                icon: Icons.fitness_center_rounded,
                color: AppColors.accentBlue,
                trendText: '+15% MoM',
              ),
              const TrainerGlassStatCard(
                title: 'Client Avg XP',
                value: 1980,
                icon: Icons.flash_on_rounded,
                color: AppColors.accentOrange,
                trendText: '+240 XP',
              ),
              const TrainerGlassStatCard(
                title: 'Retention Rate',
                value: 94,
                icon: Icons.cached_rounded,
                color: AppColors.accentPurple,
                trendText: 'Steady',
                suffix: '%',
              ),
            ],
          ),
        ),

        // Weekly Target radial card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: DashboardGlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const RadialProgress(
                    progress: 24 / 30,
                    size: 90,
                    strokeWidth: 8,
                    progressColor: AppColors.accentCyan,
                    child: Center(
                      child: Text(
                        '24/30',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Session Target', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          'You have completed 24 out of your target 30 sessions for this week.',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Next session: Today, 4:00 PM',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 100.ms),
        ),

        // Clients Progress list
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'CLIENTS PROGRESS LOG',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: clientProgress.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final client = clientProgress[index];
                    final progressVal = client['val'] as double;
                    return DashboardGlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      borderRadius: 14,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(client['name'] as String, style: AppTextStyles.labelLarge.copyWith(fontSize: 14)),
                              const Spacer(),
                              Text(
                                '${(progressVal * 100).toInt()}%',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LinearProgressBar(
                            progress: progressVal,
                            color: client['color'] as Color,
                            height: 4,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 130), // space for bottom nav
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ),
      ],
    );
  }
}
