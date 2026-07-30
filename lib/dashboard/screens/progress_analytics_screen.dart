import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/brilliant_theme.dart';
import '../widgets/dashboard_glass_card.dart';

/// Progress Analytics Content — designed to be embedded inside the DashboardShell.
class ProgressAnalyticsContent extends StatefulWidget {
  const ProgressAnalyticsContent({super.key});

  @override
  State<ProgressAnalyticsContent> createState() => _ProgressAnalyticsContentState();
}

class _ProgressAnalyticsContentState extends State<ProgressAnalyticsContent> {
  int _selectedDateRangeIndex = 1;
  int _hoveredWeightIndex = 3;

  final List<List<double>> _weightDataRanges = [
    [79.8, 79.2, 78.9, 78.4, 78.5, 78.1, 78.0],
    [79.8, 79.5, 79.1, 78.8, 78.6, 78.2, 78.0],
    [81.2, 80.5, 79.8, 79.2, 78.9, 78.4, 78.0],
    [84.0, 82.5, 81.6, 80.8, 79.9, 79.2, 78.0],
  ];

  final List<List<String>> _weightLabelsRanges = [
    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
    ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct'],
    ['Jan', 'Mar', 'May', 'Jul', 'Sep', 'Nov', 'Dec'],
  ];

  final List<double> _hydrationData = [3.2, 4.2, 3.5, 4.5, 3.8, 4.0, 3.9];
  final List<String> _hydrationDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSegmentedControl()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.05, end: 0, duration: 400.ms),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),
              _buildBodyMetricsWithTrend()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('NUTRITION PERFORMANCE'),
              const SizedBox(height: 10),
              _buildNutritionPerformance()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('HYDRATION ANALYTICS'),
              const SizedBox(height: 10),
              _buildHydrationAnalytics()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('ACTIVITY INSIGHTS'),
              const SizedBox(height: 10),
              _buildActivityInsights()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('BADGES & AWARDS'),
              const SizedBox(height: 10),
              _buildAchievementsSection()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms),
              const SizedBox(height: 20),

              _buildMonthlyReportCard()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 550.ms),
              const SizedBox(height: 20),

              _buildExportSection()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 600.ms),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress & Analytics',
            style: BrilliantTheme.headerStyle(fontSize: 22),
          ),
          const SizedBox(height: 2),
          Text(
            'Track your long-term fitness transformation',
            style: BrilliantTheme.bodyStyle(fontSize: 12, color: BrilliantColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl() {
    final options = ['Week', 'Month', '3 Months', 'Year'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BrilliantColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
      ),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = _selectedDateRangeIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedDateRangeIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? BrilliantColors.mint : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  options[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? BrilliantColors.textInverse : BrilliantColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBodyMetricsWithTrend() {
    final activeData = _weightDataRanges[_selectedDateRangeIndex];
    final activeLabels = _weightLabelsRanges[_selectedDateRangeIndex];
    final currentWeight = activeData.isNotEmpty ? activeData.last : 78.0;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Target Weight Goal', style: BrilliantTheme.titleStyle(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text('75.0 kg Target · Start 84.0 kg', style: BrilliantTheme.bodyStyle(fontSize: 11, color: BrilliantColors.textMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BrilliantColors.mint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: BrilliantColors.mint.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '66% Met',
                  style: TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              _buildMetricTile('Weight', '${currentWeight}kg', '-1.8kg', BrilliantColors.mint),
              const SizedBox(width: 8),
              _buildMetricTile('BMI', '23.4', 'Normal', BrilliantColors.blue),
              const SizedBox(width: 8),
              _buildMetricTile('Body Fat', '16.2%', '-0.8%', BrilliantColors.purple),
              const SizedBox(width: 8),
              _buildMetricTile('Muscle', '34.5kg', '+0.4kg', BrilliantColors.amber),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weight Trend', style: BrilliantTheme.badgeStyle(color: BrilliantColors.mint)),
              Text(
                'Avg: ${(activeData.reduce((a, b) => a + b) / activeData.length).toStringAsFixed(1)} kg',
                style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: GestureDetector(
              onPanUpdate: (details) => _handleChartTouch(details.localPosition, activeData.length),
              onTapDown: (details) => _handleChartTouch(details.localPosition, activeData.length),
              child: CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _WeightChartPainter(
                  data: activeData,
                  labels: activeLabels,
                  hoveredIndex: _hoveredWeightIndex,
                  lineColor: BrilliantColors.mint,
                  glowColor: BrilliantColors.mintDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleChartTouch(Offset pos, int dataCount) {
    const leftPadding = 32.0;
    const rightPadding = 16.0;
    final width = context.size?.width ?? 300 - leftPadding - rightPadding;
    final stepX = width / (dataCount - 1);
    int idx = ((pos.dx - leftPadding) / stepX).round().clamp(0, dataCount - 1);
    setState(() => _hoveredWeightIndex = idx);
  }

  Widget _buildMetricTile(String label, String value, String delta, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: BrilliantColors.bgPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BrilliantColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: BrilliantColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(delta, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: BrilliantTheme.badgeStyle(color: BrilliantColors.mint));
  }

  Widget _buildNutritionPerformance() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Macronutrient Consistency', style: BrilliantTheme.titleStyle(fontSize: 14)),
              const Text('88% Avg', style: TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          _buildMacroRow('Protein Target (140g)', 0.92, BrilliantColors.mint),
          const SizedBox(height: 8),
          _buildMacroRow('Carbs Target (220g)', 0.85, BrilliantColors.purple),
          const SizedBox(height: 8),
          _buildMacroRow('Fats Target (70g)', 0.78, BrilliantColors.amber),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String title, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: BrilliantColors.textSecondary, fontSize: 11)),
            Text('${(pct * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(color: BrilliantColors.bgTertiary, borderRadius: BorderRadius.circular(3)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: pct,
            child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          ),
        ),
      ],
    );
  }

  Widget _buildHydrationAnalytics() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('7-Day Water Intake', style: BrilliantTheme.titleStyle(fontSize: 14)),
              const Text('Avg 3.9L / Day', style: TextStyle(color: BrilliantColors.blue, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_hydrationData.length, (i) {
                final double val = _hydrationData[i];
                final double pct = (val / 5.0).clamp(0.0, 1.0);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${val}L', style: const TextStyle(color: BrilliantColors.blue, fontSize: 9, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Container(
                      width: 14,
                      height: 65 * pct,
                      decoration: BoxDecoration(
                        color: BrilliantColors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(_hydrationDays[i], style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 10)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityInsights() {
    return Row(
      children: [
        Expanded(child: _buildActivityCard('Step Goal', '92%', Icons.directions_walk, BrilliantColors.purple)),
        const SizedBox(width: 10),
        Expanded(child: _buildActivityCard('Workouts', '14 Done', Icons.fitness_center, BrilliantColors.coral)),
        const SizedBox(width: 10),
        Expanded(child: _buildActivityCard('Active Days', '26 / 30', Icons.calendar_month, BrilliantColors.mint)),
      ],
    );
  }

  Widget _buildActivityCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BrilliantColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: BrilliantColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final badges = [
      {'emoji': '🔥', 'title': '10-Day Streak', 'desc': 'Logged activity 10 days straight'},
      {'emoji': '💧', 'title': 'Hydration Hero', 'desc': 'Reached 4L target 5 times'},
      {'emoji': '🥗', 'title': 'Clean Eater', 'desc': 'Hit macro targets 7 days in a row'},
    ];

    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Unlocked Badges', style: BrilliantTheme.titleStyle(fontSize: 14)),
              const Text('3 Earned', style: TextStyle(color: BrilliantColors.amber, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: badges.map((b) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BrilliantColors.bgPrimary,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: BrilliantColors.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      Text(b['emoji']!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 6),
                      Text(b['title']!, style: const TextStyle(color: BrilliantColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyReportCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: BrilliantColors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: BrilliantColors.mint),
            alignment: Alignment.center,
            child: const Text('94', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: BrilliantColors.textInverse)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Health Score', style: BrilliantTheme.titleStyle(fontSize: 15)),
                const SizedBox(height: 2),
                Text('Outstanding consistency! You are in the top 5% of active athletes.', style: BrilliantTheme.bodyStyle(fontSize: 11, color: BrilliantColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return Row(
      children: [
        Expanded(
          child: BrilliantButton(
            onPressed: () {},
            color: BrilliantColors.mint,
            shadowColor: BrilliantColors.mintDark,
            textColor: BrilliantColors.textInverse,
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download_rounded, size: 18),
                SizedBox(width: 6),
                Text('Download Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BrilliantButton(
            onPressed: () {},
            color: BrilliantColors.bgTertiary,
            shadowColor: BrilliantColors.surfaceBorder,
            textColor: BrilliantColors.mint,
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.share_rounded, size: 18),
                SizedBox(width: 6),
                Text('Share Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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

    double maxVal = data.reduce(max);
    double minVal = data.reduce(min);
    final valRange = maxVal - minVal;

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

    final gridPaint = Paint()
      ..color = BrilliantColors.surfaceBorder
      ..strokeWidth = 1;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const int gridDivisions = 3;
    for (int i = 0; i <= gridDivisions; i++) {
      final yRatio = i / gridDivisions;
      final y = size.height - bottomPadding - (yRatio * height);
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width - rightPadding, y), gridPaint);

      final val = minVal + (yRatio * range);
      textPainter.text = TextSpan(
        text: val.toStringAsFixed(0),
        style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 9),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(8, y - textPainter.height / 2));
    }

    for (int i = 0; i < labels.length; i++) {
      final x = leftPadding + (i * stepX);
      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: i == hoveredIndex ? BrilliantColors.mint : BrilliantColors.textMuted,
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

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    if (hoveredIndex >= 0 && hoveredIndex < points.length) {
      final activePoint = points[hoveredIndex];
      final pointOuterPaint = Paint()..color = Colors.white;
      canvas.drawCircle(activePoint, 6, pointOuterPaint);
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
