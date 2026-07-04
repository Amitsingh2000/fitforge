import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';

class GymOwnerAnalyticsTab extends StatefulWidget {
  const GymOwnerAnalyticsTab({super.key});

  @override
  State<GymOwnerAnalyticsTab> createState() => _GymOwnerAnalyticsTabState();
}

class _GymOwnerAnalyticsTabState extends State<GymOwnerAnalyticsTab> {
  String _selectedPeriod = 'This Month';
  final List<String> _periods = ['This Week', 'This Month', 'This Year'];

  // Revenue data (last 7 months)
  final List<Map<String, dynamic>> _revenueData = [
    {'month': 'Jan', 'value': 3.2},
    {'month': 'Feb', 'value': 3.5},
    {'month': 'Mar', 'value': 3.8},
    {'month': 'Apr', 'value': 4.1},
    {'month': 'May', 'value': 4.5},
    {'month': 'Jun', 'value': 4.8},
    {'month': 'Jul', 'value': 5.1},
  ];

  // Membership growth
  final List<Map<String, dynamic>> _membershipGrowth = [
    {'month': 'Jan', 'value': 180},
    {'month': 'Feb', 'value': 195},
    {'month': 'Mar', 'value': 208},
    {'month': 'Apr', 'value': 220},
    {'month': 'May', 'value': 232},
    {'month': 'Jun', 'value': 241},
    {'month': 'Jul', 'value': 248},
  ];

  // Attendance by day of week
  final List<Map<String, dynamic>> _weeklyAttendance = [
    {'day': 'Mon', 'value': 0.85},
    {'day': 'Tue', 'value': 0.78},
    {'day': 'Wed', 'value': 0.92},
    {'day': 'Thu', 'value': 0.70},
    {'day': 'Fri', 'value': 0.88},
    {'day': 'Sat', 'value': 0.95},
    {'day': 'Sun', 'value': 0.55},
  ];

  // Plan distribution
  final List<Map<String, dynamic>> _planDistribution = [
    {
      'plan': 'Premium',
      'count': 98,
      'percent': 0.40,
      'color': AppColors.accentBlue,
    },
    {
      'plan': 'Standard',
      'count': 86,
      'percent': 0.35,
      'color': AppColors.accentPurple,
    },
    {
      'plan': 'Basic',
      'count': 64,
      'percent': 0.25,
      'color': AppColors.accentCyan,
    },
  ];

  // Top metrics
  final List<Map<String, dynamic>> _topMetrics = [
    {
      'title': 'Avg. Daily Attendance',
      'value': '142',
      'change': '+12%',
      'isUp': true,
      'icon': Icons.trending_up_rounded,
      'color': AppColors.accentCyan,
    },
    {
      'title': 'Member Retention',
      'value': '94%',
      'change': '+3%',
      'isUp': true,
      'icon': Icons.loyalty_rounded,
      'color': AppColors.accentPurple,
    },
    {
      'title': 'Revenue Growth',
      'value': '+18%',
      'change': '+5%',
      'isUp': true,
      'icon': Icons.show_chart_rounded,
      'color': AppColors.accentBlue,
    },
    {
      'title': 'Churn Rate',
      'value': '6%',
      'change': '-2%',
      'isUp': false,
      'icon': Icons.trending_down_rounded,
      'color': AppColors.accentCoral,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your gym\'s performance at a glance',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.05, end: 0, duration: 500.ms),
        ),

        // Period selector
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: _periods.map((period) {
                final isSelected = period == _selectedPeriod;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = period),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? AppColors.accentBlue.withValues(alpha: 0.15)
                            : AppColors.glassBg,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentBlue.withValues(alpha: 0.4)
                              : AppColors.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        period,
                        style: AppTextStyles.caption.copyWith(
                          color: isSelected
                              ? AppColors.accentBlue
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 100.ms),
        ),

        // Top metrics row
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _topMetrics.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final metric = _topMetrics[index];
                return _buildTopMetricCard(metric);
              },
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 150.ms)
              .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 150.ms),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Revenue chart
              _buildSectionLabel('REVENUE TREND'),
              const SizedBox(height: 12),
              _buildRevenueChart()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 250.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 250.ms),
              const SizedBox(height: 24),

              // Membership growth
              _buildSectionLabel('MEMBERSHIP GROWTH'),
              const SizedBox(height: 12),
              _buildMembershipGrowthChart()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 350.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 350.ms),
              const SizedBox(height: 24),

              // Weekly attendance heatmap
              _buildSectionLabel('WEEKLY ATTENDANCE'),
              const SizedBox(height: 12),
              _buildWeeklyAttendanceChart()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 450.ms),
              const SizedBox(height: 24),

              // Plan distribution
              _buildSectionLabel('PLAN DISTRIBUTION'),
              const SizedBox(height: 12),
              _buildPlanDistribution()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 550.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 550.ms),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: AppColors.primaryGradient,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTopMetricCard(Map<String, dynamic> metric) {
    final color = metric['color'] as Color;
    return DashboardGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: SizedBox(
        width: 130,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(metric['icon'] as IconData, color: color, size: 16),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: (metric['isUp'] as bool)
                        ? AppColors.accentCyan.withValues(alpha: 0.1)
                        : AppColors.accentCoral.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    metric['change'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: (metric['isUp'] as bool)
                          ? AppColors.accentCyan
                          : AppColors.accentCoral,
                      fontWeight: FontWeight.w600,
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              metric['value'] as String,
              style: AppTextStyles.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            Text(
              metric['title'] as String,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Revenue Chart (Bar chart) ──
  Widget _buildRevenueChart() {
    final maxVal = _revenueData
        .map((e) => e['value'] as double)
        .reduce((a, b) => a > b ? a : b);

    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '₹4.8L',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.accentCyan.withValues(alpha: 0.1),
                ),
                child: Text(
                  '+18% vs last month',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _revenueData.map((data) {
                final height = (data['value'] as double) / maxVal;
                final isLast =
                    data == _revenueData.last;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: height),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) {
                            return Container(
                              height: 100 * value,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: isLast
                                    ? AppColors.primaryGradient
                                    : null,
                                color: isLast
                                    ? null
                                    : AppColors.accentBlue
                                        .withValues(alpha: 0.25),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data['month'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: isLast
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                            fontSize: 10,
                            fontWeight:
                                isLast ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Membership Growth (Line-like bar chart) ──
  Widget _buildMembershipGrowthChart() {
    final maxVal = _membershipGrowth
        .map((e) => e['value'] as int)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '248',
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'total members',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.accentCyan.withValues(alpha: 0.1),
                ),
                child: Text(
                  '+38 this year',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentCyan,
                    fontWeight: FontWeight.w600,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _MembershipChartPainter(
                data: _membershipGrowth
                    .map((e) => (e['value'] as int).toDouble())
                    .toList(),
                maxVal: maxVal,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _membershipGrowth
                .map((data) => Text(
                      data['month'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Weekly Attendance ──
  Widget _buildWeeklyAttendanceChart() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        children: [
          ..._weeklyAttendance.map((data) {
            final value = data['value'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      data['day'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LinearProgressBar(
                      progress: value,
                      color: _attendanceColor(value),
                      height: 8,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${(value * 100).toInt()}%',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _attendanceColor(double value) {
    if (value >= 0.85) return AppColors.accentCyan;
    if (value >= 0.70) return AppColors.accentBlue;
    if (value >= 0.55) return AppColors.accentOrange;
    return AppColors.accentCoral;
  }

  // ── Plan Distribution ──
  Widget _buildPlanDistribution() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 18,
      child: Column(
        children: _planDistribution.map((plan) {
          final color = plan['color'] as Color;
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 70,
                  child: Text(
                    plan['plan'] as String,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressBar(
                    progress: plan['percent'] as double,
                    color: color,
                    height: 6,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${plan['count']}',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${((plan['percent'] as double) * 100).toInt()}%)',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Custom painter for membership growth line chart ──
class _MembershipChartPainter extends CustomPainter {
  final List<double> data;
  final double maxVal;

  _MembershipChartPainter({required this.data, required this.maxVal});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = AppColors.accentPurple
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accentPurple.withValues(alpha: 0.25),
          AppColors.accentPurple.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    final minVal = data.reduce((a, b) => a < b ? a : b) * 0.9;
    final range = maxVal - minVal;

    for (var i = 0; i < data.length; i++) {
      final x = i * size.width / (data.length - 1);
      final y = size.height - ((data[i] - minVal) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Smooth curve
        final prevX = (i - 1) * size.width / (data.length - 1);
        final prevY = size.height -
            ((data[i - 1] - minVal) / range) * size.height;
        final controlX1 = prevX + (x - prevX) * 0.4;
        final controlX2 = x - (x - prevX) * 0.4;
        path.cubicTo(controlX1, prevY, controlX2, y, x, y);
        fillPath.cubicTo(controlX1, prevY, controlX2, y, x, y);
      }

      // Dot at each data point
      canvas.drawCircle(
        Offset(x, y),
        3,
        Paint()..color = AppColors.accentPurple,
      );
    }

    // Fill
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Stroke
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
