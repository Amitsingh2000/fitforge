import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/analytics_summary.dart';
import '../../providers/member_flow_providers.dart';
import '../../services/member_dashboard_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/member_async_value.dart';
import '../widgets/radial_progress.dart';

/// Progress Analytics Content — designed to be embedded inside the DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class ProgressAnalyticsContent extends ConsumerStatefulWidget {
  const ProgressAnalyticsContent({super.key});

  @override
  ConsumerState<ProgressAnalyticsContent> createState() =>
      _ProgressAnalyticsContentState();
}

class _ProgressAnalyticsContentState
    extends ConsumerState<ProgressAnalyticsContent> {
  static const _rangeKeys = ['week', 'month', '3months', 'year'];

  int _selectedDateRangeIndex = 1; // 0: Week, 1: Month, 2: 3 Months, 3: Year
  int _hoveredWeightIndex = 3;

  String get _selectedRange => _rangeKeys[_selectedDateRangeIndex];

  Future<void> _handleExport() async {
    try {
      final csv =
          await ref.read(memberDashboardServiceProvider).exportAnalyticsCsv();
      final lineCount =
          csv.split('\n').where((line) => line.trim().isNotEmpty).length;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report exported ($lineCount rows)'),
          backgroundColor: AppColors.accentBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppColors.accentCoral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(analyticsSummaryProvider(_selectedRange));
    return MemberAsyncValue<AnalyticsSummary>(
      value: analyticsAsync,
      loadingMessage: 'Loading analytics…',
      onRetry: () => ref.invalidate(analyticsSummaryProvider(_selectedRange)),
      builder: (summary) => _buildContent(summary),
    );
  }

  Widget _buildContent(AnalyticsSummary summary) {
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
          padding: EdgeInsets.fromLTRB(20, 8, 20, Layout.navClearance(context)), // Padding at bottom to avoid floating nav bar
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // Combined Body Metrics + Weight Trend Hero Card
              _buildBodyMetricsWithTrend(summary)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.06, end: 0, duration: 500.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Nutrition Performance Section
              _buildSectionLabel('NUTRITION PERFORMANCE'),
              const SizedBox(height: 12),
              _buildNutritionPerformance()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms),
              const SizedBox(height: 20),

              // Hydration Analytics
              _buildSectionLabel('HYDRATION ANALYTICS'),
              const SizedBox(height: 12),
              _buildHydrationAnalytics(summary)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 20),

              // Activity Insights
              _buildSectionLabel('ACTIVITY INSIGHTS'),
              const SizedBox(height: 12),
              _buildActivityInsights(summary)
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms),
              const SizedBox(height: 20),

              // Achievements Badges
              _buildSectionLabel('BADGES & AWARDS'),
              const SizedBox(height: 12),
              _buildAchievementsSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms),
              const SizedBox(height: 20),

              // Monthly Report Summary
              _buildMonthlyReportCard()
                  .animate()
                  .fadeIn(duration: 550.ms, delay: 650.ms),
              const SizedBox(height: 24),

              // Export Controls
              _buildExportSection()
                  .animate()
                  .fadeIn(duration: 550.ms, delay: 700.ms),
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
  // COMBINED BODY METRICS + WEIGHT TREND
  // ─────────────────────────────────────────────

  Widget _buildBodyMetricsWithTrend(AnalyticsSummary summary) {
    final weight = summary.weight;
    final currentWeight = weight.currentKg ?? 78.0;
    final targetWeight = weight.targetKg ?? 72.0;
    final startWeight = weight.startKg ?? currentWeight + 6;
    final lostWeight = startWeight - currentWeight;
    final totalGoal = (startWeight - targetWeight).abs();
    final progressPercent =
        totalGoal > 0 ? (lostWeight / totalGoal).clamp(0.0, 1.0) : 0.0;

    final data = weight.history.map((p) => p.weightKg).toList();
    final labels = weight.history.map(_formatChartLabel).toList();
    final chartData = data.length >= 2
        ? data
        : data.isEmpty
            ? [currentWeight, currentWeight]
            : [data.first, data.first];
    final chartLabels = labels.length >= 2
        ? labels
        : labels.isEmpty
            ? ['Start', 'Now']
            : [labels.first, labels.first];
    final hoverIndex =
        _hoveredWeightIndex.clamp(0, chartData.length - 1);
    final avgWeight = chartData.isEmpty
        ? currentWeight
        : chartData.reduce((a, b) => a + b) / chartData.length;

    final metrics = [
      {
        'title': 'Weight',
        'value': '${currentWeight.toStringAsFixed(1)} kg',
        'trend': '↓ 2.1 kg',
        'positive': true,
        'icon': Icons.scale_rounded,
        'color': AppColors.accentBlue,
      },
      {
        'title': 'BMI',
        'value': '24.2',
        'trend': '↓ 0.4',
        'positive': true,
        'icon': Icons.accessibility_new_rounded,
        'color': AppColors.accentCyan,
      },
      {
        'title': 'Body Fat',
        'value': '18.4%',
        'trend': '↓ 1.2%',
        'positive': true,
        'icon': Icons.local_fire_department_rounded,
        'color': AppColors.accentCoral,
      },
      {
        'title': 'Muscle',
        'value': '60.5 kg',
        'trend': '↑ 0.8 kg',
        'positive': true,
        'icon': Icons.fitness_center_rounded,
        'color': AppColors.accentPurple,
      },
    ];

    return DashboardGlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top: Goal progress bar + key numbers ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accentBlue.withValues(alpha: 0.08),
                  AppColors.accentPurple.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                // Radial goal ring
                RadialProgress(
                  progress: progressPercent,
                  size: 88,
                  strokeWidth: 7,
                  progressColor: AppColors.accentBlue,
                  trackColor: AppColors.bgTertiary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(progressPercent * 100).toInt()}%',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Goal',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.accentCyan.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.trending_down_rounded, color: AppColors.accentCyan, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  'Lost ${lostWeight.toStringAsFixed(1)} kg',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accentCyan,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Current', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                              Text(
                                '${currentWeight.toStringAsFixed(1)} kg',
                                style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, color: AppColors.textTertiary, size: 14),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Target', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                              Text(
                                '${targetWeight.toStringAsFixed(1)} kg',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Middle: 4 metric chips ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: metrics.map((m) {
                final color = m['color'] as Color;
                final positive = m['positive'] as bool;
                final trend = m['trend'] as String;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(m['icon'] as IconData, color: color, size: 15),
                        const SizedBox(height: 6),
                        Text(
                          m['value'] as String,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          m['title'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trend,
                          style: AppTextStyles.caption.copyWith(
                            color: positive ? AppColors.accentCyan : AppColors.accentCoral,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Bottom: Weight Trend Chart ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weight Trend',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.bgTertiary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Avg: ${avgWeight.toStringAsFixed(1)} kg',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onPanUpdate: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final localPos = box.globalToLocal(details.globalPosition);
                final chartWidth = box.size.width - 64;
                final relativeX = localPos.dx - 32;
                if (relativeX > 0 && relativeX < chartWidth) {
                  final index = ((relativeX / chartWidth) * (chartData.length - 1)).round();
                  if (index >= 0 && index < chartData.length) {
                    setState(() => _hoveredWeightIndex = index);
                  }
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 140,
                child: CustomPaint(
                  size: const Size(double.infinity, 140),
                  painter: _WeightChartPainter(
                    data: chartData,
                    labels: chartLabels,
                    hoveredIndex: hoverIndex,
                    lineColor: AppColors.accentBlue,
                    glowColor: AppColors.accentPurple,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                    width: 8, height: 8,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentBlue),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${chartLabels[hoverIndex]}: ',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    '${chartData[hoverIndex].toStringAsFixed(1)} kg',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }



  // ─────────────────────────────────────────────
  // NUTRITION PERFORMANCE (Simplified)
  // ─────────────────────────────────────────────

  Widget _buildNutritionPerformance() {
    final nutrients = [
      {'label': 'Calories', 'value': '2,200', 'target': '2,500 kcal', 'progress': 0.88, 'emoji': '🔥', 'color': AppColors.accentCyan},
      {'label': 'Protein',  'value': '138g',   'target': '150g goal',   'progress': 0.92, 'emoji': '💪', 'color': AppColors.accentBlue},
      {'label': 'Carbs',    'value': '228g',   'target': '300g goal',   'progress': 0.76, 'emoji': '🌾', 'color': AppColors.accentOrange},
      {'label': 'Fats',     'value': '57g',    'target': '70g goal',    'progress': 0.82, 'emoji': '🥑', 'color': AppColors.accentPurple},
    ];

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sample',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...nutrients.map((n) {
            final color = n['color'] as Color;
            final progress = n['progress'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Text(n['emoji'] as String, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              n['label'] as String,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  n['value'] as String,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  ' / ${n['target']}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.bgTertiary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [color.withValues(alpha: 0.7), color],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${(progress * 100).round()}%',
                    style: AppTextStyles.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          }),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.star_rounded, color: AppColors.accentBlue, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Protein at all-time high · 92% consistency this month',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HYDRATION ANALYTICS
  // ─────────────────────────────────────────────

  Widget _buildHydrationAnalytics(AnalyticsSummary summary) {
    final hydrationData = summary.hydration7Days;
    final hydrationDays = _hydrationDayLabels(hydrationData.length);
    final dailyAvg = hydrationData.isEmpty
        ? 0.0
        : hydrationData.reduce((a, b) => a + b) / hydrationData.length;
    final bestIdx = hydrationData.isEmpty
        ? 0
        : hydrationData.indexOf(hydrationData.reduce(max));
    final bestAmount = hydrationData.isEmpty ? 0.0 : hydrationData[bestIdx];
    final bestDay =
        bestIdx < hydrationDays.length ? hydrationDays[bestIdx] : '';

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
                      '${dailyAvg.toStringAsFixed(1)} Liters',
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
                      '${bestAmount.toStringAsFixed(1)}L ($bestDay)',
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
              children: List.generate(hydrationData.length, (index) {
                final amount = hydrationData[index];
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
                          hydrationDays[index],
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
  // ACTIVITY INSIGHTS
  // ─────────────────────────────────────────────

  Widget _buildActivityInsights(AnalyticsSummary summary) {
    final activity = summary.activity;
    final consistency = (activity.consistencyRatePercent / 100).clamp(0.0, 1.0);
    final workoutProgress =
        (activity.workoutsCompleted / 30).clamp(0.0, 1.0);

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
                label: 'Consistency',
                value: '${activity.consistencyRatePercent.toStringAsFixed(0)}%',
                icon: Icons.check_circle_outline_rounded,
                progress: consistency,
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
                label: 'Workouts',
                value: '${activity.workoutsCompleted} completed',
                icon: Icons.calendar_month_rounded,
                progress: workoutProgress,
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
                'Sample badges',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.bold),
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
          onTap: _handleExport,
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

  String _formatChartLabel(WeightHistoryPoint point) {
    final d = DateTime.tryParse(point.date);
    if (d != null) {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[d.month - 1]} ${d.day}';
    }
    return point.date.length > 5 ? point.date.substring(5) : point.date;
  }

  List<String> _hydrationDayLabels(int count) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (count <= 0) return const [];
    return List.generate(count, (i) {
      final d = DateTime.now().subtract(Duration(days: count - 1 - i));
      return days[d.weekday - 1];
    });
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
        text: val.toStringAsFixed(0),
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
