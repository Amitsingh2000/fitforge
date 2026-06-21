import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/radial_progress.dart';

/// Progress Analytics Content — designed to be embedded inside the DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class ProgressAnalyticsContent extends StatefulWidget {
  const ProgressAnalyticsContent({super.key});

  @override
  State<ProgressAnalyticsContent> createState() => _ProgressAnalyticsContentState();
}

class _ProgressAnalyticsContentState extends State<ProgressAnalyticsContent> {
  int _selectedDateRangeIndex = 1; // 0: Week, 1: Month, 2: 3 Months, 3: Year
  int _hoveredWeightIndex = 3; // Highlighted data point in chart

  // Simulated weight data lists based on selected range
  final List<List<double>> _weightDataRanges = [
    [79.8, 79.2, 78.9, 78.4, 78.5, 78.1, 78.0], // Week
    [79.8, 79.5, 79.1, 78.8, 78.6, 78.2, 78.0], // Month (weekly ticks)
    [81.2, 80.5, 79.8, 79.2, 78.9, 78.4, 78.0], // 3 Months
    [84.0, 82.5, 81.6, 80.8, 79.9, 79.2, 78.0], // Year
  ];

  final List<List<String>> _weightLabelsRanges = [
    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
    ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
    ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov', 'Dec'],
  ];

  // Hydration data for last 7 days
  final List<double> _hydrationData = [3.2, 4.2, 3.5, 4.5, 3.8, 4.0, 3.9];
  final List<String> _hydrationDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App Bar & Title
        SliverToBoxAdapter(child: _buildHeader()),

        // Segmented Control for range selection
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: _buildSegmentedControl()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.05, end: 0, duration: 400.ms),
          ),
        ),

        // Main analytics body
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 130), // Padding at bottom to avoid floating nav bar
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // Transformation Overview (Hero card)
              _buildTransformationOverview()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.06, end: 0, duration: 500.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Body Metrics 2x2 section
              _buildSectionLabel('BODY METRICS'),
              const SizedBox(height: 12),
              _buildBodyMetricsGrid()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 20),

              // Weight Trend Chart Card
              _buildSectionLabel('WEIGHT TREND'),
              const SizedBox(height: 12),
              _buildWeightChartCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms),
              const SizedBox(height: 20),

              // Nutrition Performance Section
              _buildSectionLabel('NUTRITION PERFORMANCE'),
              const SizedBox(height: 12),
              _buildNutritionPerformance()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 20),

              // Hydration Analytics
              _buildSectionLabel('HYDRATION ANALYTICS'),
              const SizedBox(height: 12),
              _buildHydrationAnalytics()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms),
              const SizedBox(height: 20),

              // Streak & Achievement Highlights
              _buildSectionLabel('STREAK PERFORMANCE'),
              const SizedBox(height: 12),
              _buildStreakPerformance()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms),
              const SizedBox(height: 20),

              // Activity Insights
              _buildSectionLabel('ACTIVITY INSIGHTS'),
              const SizedBox(height: 12),
              _buildActivityInsights()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 650.ms),
              const SizedBox(height: 20),

              // AI Progress Insights
              _buildSectionLabel('AI RECOMMENDATIONS'),
              const SizedBox(height: 12),
              _buildAIInsights()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 700.ms),
              const SizedBox(height: 20),

              // Achievements Badges
              _buildSectionLabel('BADGES & AWARDS'),
              const SizedBox(height: 12),
              _buildAchievementsSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 750.ms),
              const SizedBox(height: 20),

              // Monthly Report Summary
              _buildMonthlyReportCard()
                  .animate()
                  .fadeIn(duration: 550.ms, delay: 800.ms),
              const SizedBox(height: 24),

              // Export Controls
              _buildExportSection()
                  .animate()
                  .fadeIn(duration: 550.ms, delay: 850.ms),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.accentBlue.withValues(alpha: 0.12),
            ),
            child: const Center(
              child: Icon(
                Icons.insights_rounded,
                color: AppColors.accentBlue,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Analytics',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getDateRangeLabel(),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Profile avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassBorder, width: 1.5),
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDateRangeLabel() {
    switch (_selectedDateRangeIndex) {
      case 0:
        return 'Last 7 Days (June 12 - June 18)';
      case 2:
        return 'Last 3 Months (Apr 1 - Jun 18)';
      case 3:
        return 'Year 2026 Overview';
      case 1:
      default:
        return 'This Month (June 1 - June 18)';
    }
  }

  // ─────────────────────────────────────────────
  // SEGMENTED CONTROL SELECTOR
  // ─────────────────────────────────────────────

  Widget _buildSegmentedControl() {
    final ranges = ['Week', 'Month', '3 Months', 'Year'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: List.generate(ranges.length, (index) {
          final isSelected = _selectedDateRangeIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDateRangeIndex = index;
                  // Reset hovered index to mid-point on range change
                  _hoveredWeightIndex = 3;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: AppColors.accentBlue.withValues(alpha: 0.25))
                      : Border.all(color: Colors.transparent),
                ),
                child: Center(
                  child: Text(
                    ranges[index],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TRANSFORMATION OVERVIEW HERO CARD
  // ─────────────────────────────────────────────

  Widget _buildTransformationOverview() {
    const double currentWeight = 78.0;
    const double targetWeight = 72.0;
    const double startWeight = 84.0;
    const double lostWeight = startWeight - currentWeight;
    const double totalGoal = startWeight - targetWeight;
    final double progressPercent = lostWeight / totalGoal;

    return DashboardGlassCard(
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        'WEIGHT JOURNEY',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentWeight.toStringAsFixed(1)} kg',
                          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 28),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${targetWeight.toStringAsFixed(1)} kg',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.trending_down_rounded,
                      color: AppColors.accentCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Lost ${lostWeight.toStringAsFixed(1)} kg total',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accentCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: RadialProgress(
                progress: progressPercent,
                size: 110,
                strokeWidth: 8,
                progressColor: AppColors.accentBlue,
                trackColor: AppColors.bgTertiary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progressPercent * 100).toInt()}%',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'of Goal',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BODY METRICS SECTION
  // ─────────────────────────────────────────────

  Widget _buildBodyMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Weight',
                value: '78.0 kg',
                trendText: '↓ 2.1 kg this month',
                isPositive: true, // Loss is positive for target weight loss
                icon: Icons.scale_rounded,
                accentColor: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildMetricTile(
                title: 'BMI',
                value: '24.2',
                trendText: '↓ 0.4 this month',
                isPositive: true,
                icon: Icons.accessibility_new_rounded,
                accentColor: AppColors.accentCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Body Fat %',
                value: '18.4%',
                trendText: '↓ 1.2% this month',
                isPositive: true,
                icon: Icons.local_fire_department_rounded,
                accentColor: AppColors.accentCoral,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildMetricTile(
                title: 'Muscle Mass',
                value: '60.5 kg',
                trendText: '↑ 0.8 kg this month',
                isPositive: true, // Muscle gain is positive
                icon: Icons.fitness_center_rounded,
                accentColor: AppColors.accentPurple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String trendText,
    required bool isPositive,
    required IconData icon,
    required Color accentColor,
  }) {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
              ),
              Icon(icon, color: accentColor.withValues(alpha: 0.7), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                trendText.startsWith('↑') ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                color: isPositive ? AppColors.accentCyan : AppColors.accentCoral,
                size: 14,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  trendText,
                  style: AppTextStyles.caption.copyWith(
                    color: isPositive ? AppColors.accentCyan : AppColors.accentCoral,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // WEIGHT TREND CHART CARD
  // ─────────────────────────────────────────────

  Widget _buildWeightChartCard() {
    final data = _weightDataRanges[_selectedDateRangeIndex];
    final labels = _weightLabelsRanges[_selectedDateRangeIndex];

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight Timeline',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Avg: 78.8 kg',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // The line chart canvas
          GestureDetector(
            onPanUpdate: (details) {
              // Simple gesture hit-testing for interactive hover points
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final localPos = box.globalToLocal(details.globalPosition);
                // Simple mapping of x coordinate to data index (7 items)
                final chartWidth = box.size.width - 64; // Approximate padding
                final relativeX = localPos.dx - 32;
                if (relativeX > 0 && relativeX < chartWidth) {
                  final index = ((relativeX / chartWidth) * (data.length - 1)).round();
                  if (index >= 0 && index < data.length) {
                    setState(() {
                      _hoveredWeightIndex = index;
                    });
                  }
                }
              }
            },
            child: SizedBox(
              height: 160,
              child: CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _WeightChartPainter(
                  data: data,
                  labels: labels,
                  hoveredIndex: _hoveredWeightIndex,
                  lineColor: AppColors.accentBlue,
                  glowColor: AppColors.accentPurple,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Display active hovered value details
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${labels[_hoveredWeightIndex]}: ',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
                    ),
                    Text(
                      '${data[_hoveredWeightIndex].toStringAsFixed(1)} kg',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // NUTRITION PERFORMANCE
  // ─────────────────────────────────────────────

  Widget _buildNutritionPerformance() {
    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nutrition Performance',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                'Goal Consistency',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionRing(
                progress: 0.88,
                label: 'Calories',
                value: '88%',
                color: AppColors.accentCyan,
              ),
              _buildNutritionRing(
                progress: 0.92,
                label: 'Protein',
                value: '92%',
                color: AppColors.accentBlue,
              ),
              _buildNutritionRing(
                progress: 0.76,
                label: 'Carbs',
                value: '76%',
                color: AppColors.accentOrange,
              ),
              _buildNutritionRing(
                progress: 0.82,
                label: 'Fats',
                value: '82%',
                color: AppColors.accentPurple,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.accentBlue,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Protein goal achievement is at an all-time high this month (92% average consistency).',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRing({
    required double progress,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        RadialProgress(
          progress: progress,
          size: 60,
          strokeWidth: 5,
          progressColor: color,
          trackColor: AppColors.bgTertiary,
          child: Text(
            value,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // HYDRATION ANALYTICS
  // ─────────────────────────────────────────────

  Widget _buildHydrationAnalytics() {
    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Water Habits',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentCyan,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Daily intake (L)',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Core Stats
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Average',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '3.8 Liters',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Best Hydration',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '4.5L (Thu)',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Hydration Bar Chart using Row + Containers
          SizedBox(
            height: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_hydrationData.length, (index) {
                final amount = _hydrationData[index];
                // Target is 4.0L
                final ratio = (amount / 4.5).clamp(0.0, 1.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value above bar
                        Text(
                          '${amount.toStringAsFixed(1)}L',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Bar Container
                        Container(
                          height: 60 * ratio,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.accentBlue,
                                AppColors.accentCyan,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentCyan.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Label
                        Text(
                          _hydrationDays[index],
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STREAK & ACHIEVEMENTS HIGHLIGHTS
  // ─────────────────────────────────────────────

  Widget _buildStreakPerformance() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentBlue.withValues(alpha: 0.1),
            AppColors.accentPurple.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentOrange.withValues(alpha: 0.15),
                      ),
                      child: const Center(
                        child: Text('🔥', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Achievements',
                            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Gamified consistency targets',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildStreakMetric(
                        label: 'Current Streak',
                        value: '18 Days',
                        subLabel: 'Active since Jun 1',
                        valueColor: AppColors.accentOrange,
                      ),
                    ),
                    Container(width: 1, height: 44, color: AppColors.glassBorder),
                    Expanded(
                      child: _buildStreakMetric(
                        label: 'Longest Streak',
                        value: '43 Days',
                        subLabel: 'Record set in May',
                        valueColor: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  color: AppColors.glassBorder,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStreakMetric(
                        label: 'Total XP Earned',
                        value: '12,450',
                        subLabel: 'Level 14 Veteran',
                        valueColor: AppColors.accentPurple,
                      ),
                    ),
                    Container(width: 1, height: 44, color: AppColors.glassBorder),
                    Expanded(
                      child: _buildStreakMetric(
                        label: 'Tasks Completed',
                        value: '327 Tasks',
                        subLabel: '89% weekly success',
                        valueColor: AppColors.accentBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakMetric({
    required String label,
    required String value,
    required String subLabel,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subLabel,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // ACTIVITY INSIGHTS
  // ─────────────────────────────────────────────

  Widget _buildActivityInsights() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActivityMetricCard(
                label: 'Steps Goal',
                value: '8,400 / day',
                icon: Icons.directions_run_rounded,
                progress: 0.84,
                color: AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildActivityMetricCard(
                label: 'Workout rate',
                value: '87% Completed',
                icon: Icons.check_circle_outline_rounded,
                progress: 0.87,
                color: AppColors.accentPurple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildActivityMetricCard(
                label: 'Active Days',
                value: '24 Days / Month',
                icon: Icons.calendar_month_rounded,
                progress: 0.80,
                color: AppColors.accentCyan,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildActivityMetricCard(
                label: 'Calories Burned',
                value: '650 kcal avg',
                icon: Icons.bolt_rounded,
                progress: 0.92,
                color: AppColors.accentCoral,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required double progress,
    required Color color,
  }) {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          // Clean horizontal progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 4,
              width: double.infinity,
              color: AppColors.bgTertiary,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AI PROGRESS INSIGHTS
  // ─────────────────────────────────────────────

  Widget _buildAIInsights() {
    final insights = [
      {
        'title': 'Healthy Pace Established',
        'desc': 'You are losing weight at a stable rate of 0.5kg/week, preserving muscle mass.',
        'icon': Icons.favorite_rounded,
        'color': AppColors.accentCyan,
      },
      {
        'title': 'Protein Consistency Peak',
        'desc': 'Your protein consistency improved by 18% this month, aiding in strength development.',
        'icon': Icons.trending_up_rounded,
        'color': AppColors.accentBlue,
      },
      {
        'title': 'Hydration habit stabilized',
        'desc': 'Daily water levels are up by 25% compared to May. Keep up the high fluid intake.',
        'icon': Icons.water_drop_rounded,
        'color': AppColors.accentCyan,
      },
      {
        'title': 'Weekday Habit Pattern',
        'desc': 'Your calorie and active goal completions are 30% higher on weekdays than weekends.',
        'icon': Icons.calendar_today_rounded,
        'color': AppColors.accentPurple,
      },
    ];

    return Column(
      children: insights.map((insight) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DashboardGlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (insight['color'] as Color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      insight['icon'] as IconData,
                      color: insight['color'] as Color,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        insight['title'] as String,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        insight['desc'] as String,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // ACHIEVEMENTS BADGES
  // ─────────────────────────────────────────────

  Widget _buildAchievementsSection() {
    final badges = [
      {'emoji': '🔥', 'title': '7 Day Streak', 'desc': 'Daily goals hit'},
      {'emoji': '💪', 'title': 'Protein Master', 'desc': 'Met target 14d'},
      {'emoji': '💧', 'title': 'Hydration Hero', 'desc': 'Hit 4L target'},
      {'emoji': '👑', 'title': 'Champ Status', 'desc': 'Completed all tasks'},
    ];

    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Badges & Awards',
                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '4 Unlocked',
                style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: badges.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              final badge = badges[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(badge['emoji']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(
                      badge['title']!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      badge['desc']!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MONTHLY REPORT CARD
  // ─────────────────────────────────────────────

  Widget _buildMonthlyReportCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A1B4E),
            Color(0xFF13132B),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MONTHLY REPORT CARD',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentPurple,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Overall Health Score',
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentPurple.withValues(alpha: 0.2),
                        border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.4)),
                      ),
                      child: Center(
                        child: Text(
                          '89',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  '"You\'re performing better than last month. Keep building momentum."',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _buildReportMetric(label: 'Nutrition', score: '92/100'),
                    ),
                    Expanded(
                      child: _buildReportMetric(label: 'Activity', score: '85/100'),
                    ),
                    Expanded(
                      child: _buildReportMetric(label: 'Consistency', score: '90/100'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportMetric({required String label, required String score}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
        const SizedBox(height: 2),
        Text(
          score,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // EXPORT SECTION
  // ─────────────────────────────────────────────

  Widget _buildExportSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Download Progress Report',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share_rounded, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Share Achievement',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper title label
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CUSTOM PAINTER FOR LINE CHART
// ─────────────────────────────────────────────

class _WeightChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final int hoveredIndex;
  final Color lineColor;
  final Color glowColor;

  _WeightChartPainter({
    required this.data,
    required this.labels,
    required this.hoveredIndex,
    required this.lineColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 32.0;
    const rightPadding = 16.0;
    const topPadding = 20.0;
    const bottomPadding = 24.0;

    final width = size.width - leftPadding - rightPadding;
    final height = size.height - topPadding - bottomPadding;

    if (data.isEmpty) return;

    // Determine scale limits
    double maxVal = data.reduce(max);
    double minVal = data.reduce(min);
    final valRange = maxVal - minVal;

    // Buffer range slightly
    maxVal = maxVal + (valRange > 0 ? valRange * 0.15 : 2.0);
    minVal = minVal - (valRange > 0 ? valRange * 0.15 : 2.0);
    final range = maxVal - minVal;

    final points = <Offset>[];
    final stepX = width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = leftPadding + (i * stepX);
      final yRatio = (data[i] - minVal) / (range > 0 ? range : 1.0);
      final y = size.height - bottomPadding - (yRatio * height);
      points.add(Offset(x, y));
    }

    // 1. Draw horizontal grid lines & Y labels
    final gridPaint = Paint()
      ..color = AppColors.glassBorder.withValues(alpha: 0.4)
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const int gridDivisions = 3;
    for (int i = 0; i <= gridDivisions; i++) {
      final yRatio = i / gridDivisions;
      final y = size.height - bottomPadding - (yRatio * height);
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width - rightPadding, y), gridPaint);

      // Y value text
      final val = minVal + (yRatio * range);
      textPainter.text = TextSpan(
        text: '${val.toStringAsFixed(0)}',
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontSize: 9,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(8, y - textPainter.height / 2));
    }

    // 2. Draw X-axis labels
    for (int i = 0; i < labels.length; i++) {
      final x = leftPadding + (i * stepX);
      textPainter.text = TextSpan(
        text: labels[i],
        style: AppTextStyles.caption.copyWith(
          color: i == hoveredIndex ? AppColors.accentBlue : AppColors.textTertiary,
          fontSize: 9,
          fontWeight: i == hoveredIndex ? FontWeight.bold : FontWeight.normal,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - bottomPadding + 6),
      );
    }

    // 3. Draw smooth spline line
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + stepX / 2, p0.dy);
      final controlPoint2 = Offset(p1.dx - stepX / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    // Glow under line (Shadow/Area)
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, size.height - bottomPadding);
    fillPath.lineTo(points.first.dx, size.height - bottomPadding);
    fillPath.close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        lineColor.withValues(alpha: 0.25),
        glowColor.withValues(alpha: 0.02),
      ],
    );

    final fillPaint = Paint()
      ..shader = fillGradient.createShader(
        Rect.fromLTRB(leftPadding, topPadding, size.width - rightPadding, size.height - bottomPadding),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Glow line shadow
    final lineGlowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.3)
      ..strokeWidth = 4.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, lineGlowPaint);

    // Primary line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // 4. Draw interactive hover line & indicator
    if (hoveredIndex >= 0 && hoveredIndex < points.length) {
      final activePoint = points[hoveredIndex];

      // Vertical helper line
      final hoverLinePaint = Paint()
        ..color = AppColors.accentBlue.withValues(alpha: 0.15)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(activePoint.dx, topPadding),
        Offset(activePoint.dx, size.height - bottomPadding),
        hoverLinePaint,
      );

      // Large glow circle
      final pointGlowPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(activePoint, 10, pointGlowPaint);

      // Outer point circle
      final pointOuterPaint = Paint()..color = Colors.white;
      canvas.drawCircle(activePoint, 6, pointOuterPaint);

      // Inner point circle
      final pointInnerPaint = Paint()..color = lineColor;
      canvas.drawCircle(activePoint, 4, pointInnerPaint);
    }
  }

  @override
  bool shouldRepaint(_WeightChartPainter oldDelegate) =>
      oldDelegate.hoveredIndex != hoveredIndex ||
      oldDelegate.data != data ||
      oldDelegate.labels != labels;
}
