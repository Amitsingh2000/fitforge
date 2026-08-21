import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trainer_analytics.dart';
import '../../models/trainer_client.dart';
import '../../providers/trainer_flow_providers.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';
import '../../dashboard/widgets/radial_progress.dart';
import '../../dashboard/widgets/state_views.dart';
import '../widgets/client_gradient.dart';
import '../widgets/trainer_glass_stat_card.dart';
import 'trainer_client_detail_screen.dart';

class TrainerAnalyticsTab extends ConsumerStatefulWidget {
  const TrainerAnalyticsTab({super.key});

  @override
  ConsumerState<TrainerAnalyticsTab> createState() => _TrainerAnalyticsTabState();
}

class _TrainerAnalyticsTabState extends ConsumerState<TrainerAnalyticsTab> {
  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(currentGymTrainerAnalyticsProvider);
    final clientsAsync = ref.watch(currentGymTrainerClientsProvider);

    return analyticsAsync.when(
      loading: () =>
          const Center(child: LoadingView(message: 'Loading analytics…')),
      error: (e, _) => Center(
        child: ErrorRetryView(
          message: friendlyApiError(e),
          onRetry: () => ref.invalidate(currentGymTrainerAnalyticsProvider),
        ),
      ),
      data: (analytics) {
        return clientsAsync.when(
          loading: () =>
              const Center(child: LoadingView(message: 'Loading clients…')),
          error: (e, _) => Center(
            child: ErrorRetryView(
              message: friendlyApiError(e),
              onRetry: () => ref.invalidate(currentGymTrainerClientsProvider),
            ),
          ),
          data: (clients) => _buildBody(analytics, clients),
        );
      },
    );
  }

  Widget _buildBody(TrainerAnalytics analytics, List<TrainerClient> clients) {
    final activeMembers = analytics.activeMembers;
    final workoutPct = analytics.avgWorkoutCompletionRatePercent.toInt();
    final nutritionPct = analytics.avgNutritionComplianceRatePercent.toInt();
    final engagedPct = analytics.engagedClientsLast7dPercent.toInt();
    final goalPct = analytics.goalCompletionRatePercent.toInt();

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
              TrainerGlassStatCard(
                title: 'Total Clients',
                value: activeMembers,
                icon: Icons.people_rounded,
                color: AppColors.accentCyan,
                trendText: 'Assigned',
              ),
              TrainerGlassStatCard(
                title: 'Workout Completion',
                value: workoutPct,
                icon: Icons.fitness_center_rounded,
                color: AppColors.accentBlue,
                trendText: 'Clients avg',
                suffix: '%',
              ),
              TrainerGlassStatCard(
                title: 'Nutrition Compliance',
                value: nutritionPct,
                icon: Icons.restaurant_rounded,
                color: AppColors.accentOrange,
                trendText: 'Clients avg',
                suffix: '%',
              ),
              TrainerGlassStatCard(
                title: 'Engaged (7d)',
                value: engagedPct,
                icon: Icons.cached_rounded,
                color: AppColors.accentPurple,
                trendText: 'Logged 7d',
                suffix: '%',
              ),
            ],
          ),
        ),

        // Goal completion radial card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: DashboardGlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  RadialProgress(
                    progress: goalPct / 100,
                    size: 90,
                    strokeWidth: 8,
                    progressColor: AppColors.accentCyan,
                    child: Center(
                      child: Text(
                        '$goalPct%',
                        style: const TextStyle(
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
                        Text('Goal Completion', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Share of your clients currently meeting their goal trajectory.',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$activeMembers clients · ${analytics.avgWorkoutCompletionRatePercent.toStringAsFixed(0)}% avg workout completion',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textTertiary),
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
                if (clients.isEmpty)
                  DashboardGlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    borderRadius: 14,
                    child: Center(
                      child: Text(
                        'No assigned clients yet.',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textTertiary),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: clients.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      final summary = client.progressSummary;
                      final progressVal = summary == null
                          ? 0.0
                          : (summary.workoutCompletionRatePercent / 100)
                              .clamp(0.0, 1.0);
                      final color = clientGradient(client.userId)[0];
                      return DashboardGlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        borderRadius: 14,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TrainerClientDetailScreen(client: client),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  client.fullName,
                                  style: AppTextStyles.labelLarge
                                      .copyWith(fontSize: 14),
                                ),
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
                              color: color,
                              height: 4,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                SizedBox(height: Layout.navClearance(context)),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ),
      ],
    );
  }
}