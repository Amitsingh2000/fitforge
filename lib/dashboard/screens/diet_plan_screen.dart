import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/linear_progress_bar.dart';
import '../widgets/radial_progress.dart';
import 'meal_builder_screen.dart';

/// Diet Plan content — designed to be embedded inside the DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class DietPlanContent extends StatefulWidget {
  const DietPlanContent({super.key});

  @override
  State<DietPlanContent> createState() => _DietPlanContentState();
}

class _DietPlanContentState extends State<DietPlanContent> {
  // Nutrition targets
  final int _caloriesTarget = 2500;
  final int _proteinTarget = 140;
  final int _carbsTarget = 220;
  final int _fatsTarget = 70;

  // Current consumption
  int _caloriesConsumed = 0;
  int _proteinConsumed = 0;
  int _carbsConsumed = 0;
  int _fatsConsumed = 0;

  // Meal items list — holds both original items and custom added items
  final List<Map<String, dynamic>> _mealItems = [
    {
      'name': 'Protein Oats Bowl',
      'icon': '🥣',
      'calories': 450,
      'protein': 28,
      'carbs': 45,
      'fat': 12,
      'checked': false,
      'isCustom': false,
    },
    {
      'name': 'Greek Yogurt Bowl',
      'icon': '🥛',
      'calories': 180,
      'protein': 15,
      'carbs': 12,
      'fat': 8,
      'checked': false,
      'isCustom': false,
    },
    {
      'name': 'Chicken Rice Bowl',
      'icon': '🍗',
      'calories': 620,
      'protein': 42,
      'carbs': 55,
      'fat': 18,
      'checked': false,
      'isCustom': false,
    },
    {
      'name': 'Protein Shake',
      'icon': '🥤',
      'calories': 220,
      'protein': 30,
      'carbs': 8,
      'fat': 5,
      'checked': false,
      'isCustom': false,
    },
    {
      'name': 'Salmon & Quinoa',
      'icon': '🐟',
      'calories': 580,
      'protein': 38,
      'carbs': 42,
      'fat': 22,
      'checked': false,
      'isCustom': false,
    },
  ];

  // Insights
  final List<Map<String, dynamic>> _insights = [
    {
      'text': 'You\'re on track to reach today\'s protein goal.',
      'icon': Icons.check_circle_outline_rounded,
      'color': AppColors.accentBlue,
    },
    {
      'text': 'Drink another 500 ml of water before this afternoon.',
      'icon': Icons.water_drop_rounded,
      'color': AppColors.accentCyan,
    },
    {
      'text': 'Adding one fruit serving will improve today\'s fiber intake.',
      'icon': Icons.eco_rounded,
      'color': AppColors.accentPurple,
    },
  ];


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String get _formattedDate {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Diet header
        SliverToBoxAdapter(child: _buildDietHeader()),

        // Content
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Combined Nutrition & Meal Tracker Hero
              _buildCombinedNutritionTracker()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideY(begin: 0.06, end: 0, duration: 600.ms, delay: 100.ms),
              const SizedBox(height: 24),

              // Combined checklist
              _buildSectionLabel("TODAY'S FOOD CHECKLIST"),
              const SizedBox(height: 14),
              _buildCombinedMealChecklist()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 20),

              // Generate Meal Button
              _buildGenerateMealButton()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 250.ms)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 250.ms),
              const SizedBox(height: 28),

              // Today's AI Coach
              _buildSectionLabel('AI GUIDANCE'),
              const SizedBox(height: 10),
              _buildAICoachSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // DIET HEADER (replaces back-button app bar)
  // ─────────────────────────────────────────────

  Widget _buildDietHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.accentCoral.withValues(alpha: 0.12),
            ),
            child: const Center(
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: AppColors.accentCoral,
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
                  'Today\'s Nutrition',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formattedDate,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.accentBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: AppColors.accentBlue,
                ),
                const SizedBox(width: 5),
                Text(
                  'AI Plan',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms);
  }

  // ─────────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.caption.copyWith(
        letterSpacing: 1.2,
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // COMBINED NUTRITION & MEAL TRACKER HERO
  // ─────────────────────────────────────────────

  Widget _buildCombinedNutritionTracker() {
    final totalItems = _mealItems.length;
    final checkedItems = _mealItems.where((item) => item['checked'] == true).length;
    final mealProgress = totalItems > 0 ? (checkedItems / totalItems) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Motivational text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.accentPurple.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✦', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              Text(
                'Stay consistent. Every meal counts.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.accentPurple.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Unified Glass Card
        DashboardGlassCard(
          padding: const EdgeInsets.all(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentBlue.withValues(alpha: 0.08),
              AppColors.accentPurple.withValues(alpha: 0.04),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upper Half: Meal Completion Line
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meal Plan Progress',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$checkedItems of $totalItems items eaten',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(mealProgress * 100).round()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressBar(
                progress: mealProgress,
                color: AppColors.accentBlue,
                height: 4,
              ),

              // Spacer Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  height: 1,
                  color: AppColors.glassBorder,
                ),
              ),

              // Lower Half: 4 Radial Progress Indicators arranged horizontally
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRadialMetric(
                    emoji: '🔥',
                    label: 'Calories',
                    progress: _caloriesConsumed / _caloriesTarget,
                    current: '$_caloriesConsumed',
                    target: '$_caloriesTarget',
                    color: AppColors.accentBlue,
                  ),
                  _buildRadialMetric(
                    emoji: '💪',
                    label: 'Protein',
                    progress: _proteinConsumed / _proteinTarget,
                    current: '${_proteinConsumed}g',
                    target: '${_proteinTarget}g',
                    color: AppColors.accentBlue,
                  ),
                  _buildRadialMetric(
                    emoji: '🌾',
                    label: 'Carbs',
                    progress: _carbsConsumed / _carbsTarget,
                    current: '${_carbsConsumed}g',
                    target: '${_carbsTarget}g',
                    color: AppColors.accentPurple,
                  ),
                  _buildRadialMetric(
                    emoji: '🥑',
                    label: 'Fats',
                    progress: _fatsConsumed / _fatsTarget,
                    current: '${_fatsConsumed}g',
                    target: '${_fatsTarget}g',
                    color: AppColors.accentCoral,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadialMetric({
    required String emoji,
    required String label,
    required double progress,
    required String current,
    required String target,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadialProgress(
            progress: progress,
            size: 52,
            strokeWidth: 4.5,
            progressColor: color,
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.caption.copyWith(fontSize: 9),
              children: [
                TextSpan(
                  text: current,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: '\n/$target',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 8.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedMealChecklist() {
    final totalItems = _mealItems.length;
    final checkedItems = _mealItems.where((item) => item['checked'] == true).length;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      borderColor: AppColors.glassBorder,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.bgSecondary.withValues(alpha: 0.85),
          AppColors.bgPrimary.withValues(alpha: 0.95),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: AppColors.accentBlue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Today's Food Checklist",
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              Text(
                '$checkedItems/$totalItems eaten',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_mealItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "No items added yet. Click 'Generate Meal' to start!",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _mealItems.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.glassBorder.withValues(alpha: 0.5),
                ),
              ),
              itemBuilder: (context, index) {
                final item = _mealItems[index];
                final isChecked = item['checked'] == true;
                final isCustom = item['isCustom'] == true;

                final Color itemColor = isCustom ? AppColors.accentCoral : AppColors.accentBlue;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      item['checked'] = !isChecked;
                      if (!isChecked) {
                        _caloriesConsumed += item['calories'] as int;
                        _proteinConsumed += item['protein'] as int;
                        _carbsConsumed += item['carbs'] as int;
                        _fatsConsumed += item['fat'] as int;
                      } else {
                        _caloriesConsumed -= item['calories'] as int;
                        _proteinConsumed -= item['protein'] as int;
                        _carbsConsumed -= item['carbs'] as int;
                        _fatsConsumed -= item['fat'] as int;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        // Checkbox
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: isChecked
                                ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                                : Colors.transparent,
                            border: Border.all(
                              color: isChecked
                                  ? const Color(0xFF22C55E)
                                  : AppColors.textDisabled,
                              width: 1.5,
                            ),
                          ),
                          child: isChecked
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 14,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // Emoji
                        Text(
                          (item['icon'] as String?) ?? '🍽️',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 10),
                        // Name and details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item['name'] as String,
                                      style: AppTextStyles.labelLarge.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isChecked
                                            ? AppColors.textTertiary
                                            : AppColors.textPrimary,
                                        decoration: isChecked ? TextDecoration.lineThrough : null,
                                        decorationColor: AppColors.textTertiary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCustom) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentCoral.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        item['quantity'] != null ? '${item['quantity']}x' : 'Added',
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.accentCoral,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              if (item['servingSize'] != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item['servingSize'] as String,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Macros details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item['calories']} cal',
                              style: AppTextStyles.caption.copyWith(
                                color: isChecked
                                    ? const Color(0xFF22C55E).withValues(alpha: 0.7)
                                    : itemColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              '${item['protein']}g P · ${item['carbs']}g C · ${item['fat']}g F',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary.withValues(alpha: 0.6),
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TODAY'S AI COACH
  // ─────────────────────────────────────────────

  Widget _buildAICoachSection() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      borderColor: AppColors.accentBlue.withValues(alpha: 0.2),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentBlue.withValues(alpha: 0.05),
          AppColors.accentPurple.withValues(alpha: 0.02),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accentBlue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Today's AI Coach",
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ..._insights.asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            final isLast = index == _insights.length - 1;

            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: (insight['color'] as Color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        insight['icon'] as IconData,
                        color: insight['color'] as Color,
                        size: 15,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight['text'] as String,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
                .animate()
                .fadeIn(delay: (index * 150).ms, duration: 400.ms)
                .slideX(begin: 0.05, end: 0, delay: (index * 150).ms, duration: 400.ms),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.glassBorder.withValues(alpha: 0.5),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GENERATE MEAL BUTTON & NAVIGATION
  // ─────────────────────────────────────────────

  void _navigateToMealBuilder() async {
    final remainingCal = (_caloriesTarget - _caloriesConsumed).clamp(0, _caloriesTarget);
    final remainingProt = (_proteinTarget - _proteinConsumed).clamp(0, _proteinTarget);
    final remainingCarbs = (_carbsTarget - _carbsConsumed).clamp(0, _carbsTarget);
    final remainingFats = (_fatsTarget - _fatsConsumed).clamp(0, _fatsTarget);

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MealBuilderScreen(
          remainingCalories: remainingCal,
          remainingProtein: remainingProt,
          remainingCarbs: remainingCarbs,
          remainingFats: remainingFats,
          totalCaloriesTarget: _caloriesTarget,
          totalProteinTarget: _proteinTarget,
          totalCarbsTarget: _carbsTarget,
          totalFatsTarget: _fatsTarget,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        final customItems = result['customItems'] as List<dynamic>;
        for (var item in customItems) {
          _mealItems.add({
            'name': item['name'],
            'icon': item['emoji'],
            'calories': item['calories'],
            'protein': item['protein'],
            'carbs': item['carbs'],
            'fat': item['fat'],
            'checked': false,
            'isCustom': true,
            'quantity': item['quantity'],
            'servingSize': item['servingSize'],
          });
        }
      });
    }
  }

  Widget _buildGenerateMealButton() {
    return InteractivePressCard(
      onTap: _navigateToMealBuilder,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.accentCoral.withValues(alpha: 0.08),
          border: Border.all(
            color: AppColors.accentCoral.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.accentCoral,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'Generate Meal',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.accentCoral,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.accentCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'NEW',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentCoral,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ─────────────────────────────────────────────
// DAY PHASE THEME & INTEGRATED WIDGETS
// ─────────────────────────────────────────────

class DayPhaseTheme {
  final List<Color> skyGradient;
  final Color accentColor;
  final Color glowColor;
  final IconData phaseIcon;
  final String title;
  final String description;

  const DayPhaseTheme({
    required this.skyGradient,
    required this.accentColor,
    required this.glowColor,
    required this.phaseIcon,
    required this.title,
    required this.description,
  });

  static const List<DayPhaseTheme> phases = [
    DayPhaseTheme(
      skyGradient: [Color(0xFF16223F), Color(0xFF38BDF8), Color(0xFFFCD34D)],
      accentColor: Color(0xFFFB923C),
      glowColor: Color(0xFFFB923C),
      phaseIcon: Icons.wb_twilight_rounded,
      title: 'Sunrise',
      description: 'Fuel your day',
    ),
    DayPhaseTheme(
      skyGradient: [Color(0xFF0369A1), Color(0xFF38BDF8), Color(0xFFE0F2FE)],
      accentColor: Color(0xFF0284C7),
      glowColor: Color(0xFF7DD3FC),
      phaseIcon: Icons.wb_cloudy_rounded,
      title: 'Morning Light',
      description: 'Keep going strong',
    ),
    DayPhaseTheme(
      skyGradient: [Color(0xFF1E3A8A), Color(0xFF0284C7), Color(0xFF22D3EE)],
      accentColor: Color(0xFF06B6D4),
      glowColor: Color(0xFFFDE047),
      phaseIcon: Icons.wb_sunny_rounded,
      title: 'High Noon',
      description: 'Power through the peak',
    ),
    DayPhaseTheme(
      skyGradient: [Color(0xFF140D1F), Color(0xFF2D1225), Color(0xFF4C1C24)],
      accentColor: Color(0xFFF97066),
      glowColor: Color(0xFFF97066),
      phaseIcon: Icons.wb_twilight_outlined,
      title: 'Sunset',
      description: 'Unwind and replenish',
    ),
    DayPhaseTheme(
      skyGradient: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1E1B4B)],
      accentColor: Color(0xFF818CF8),
      glowColor: Color(0xFF6366F1),
      phaseIcon: Icons.bedtime_rounded,
      title: 'Nightfall',
      description: 'Recover and rebuild',
    ),
  ];

  static DayPhaseTheme getInterpolated(double progress) {
    final double clampedProgress = progress.clamp(0.0, 4.0);
    final idx = clampedProgress.floor().clamp(0, 3);
    final t = clampedProgress - idx;
    final start = phases[idx];
    final end = phases[idx + 1];

    final sky = [
      Color.lerp(start.skyGradient[0], end.skyGradient[0], t)!,
      Color.lerp(start.skyGradient[1], end.skyGradient[1], t)!,
      Color.lerp(start.skyGradient[2], end.skyGradient[2], t)!,
    ];
    final accent = Color.lerp(start.accentColor, end.accentColor, t)!;
    final glow = Color.lerp(start.glowColor, end.glowColor, t)!;
    final icon = t < 0.5 ? start.phaseIcon : end.phaseIcon;
    final title = t < 0.5 ? start.title : end.title;
    final desc = t < 0.5 ? start.description : end.description;

    return DayPhaseTheme(
      skyGradient: sky,
      accentColor: accent,
      glowColor: glow,
      phaseIcon: icon,
      title: title,
      description: desc,
    );
  }
}

class SkyBackdropPainter extends CustomPainter {
  final double progress;
  final List<double> cardCenters;

  SkyBackdropPainter({required this.progress, required this.cardCenters});

  @override
  void paint(Canvas canvas, Size size) {
    final double clampedProgress = progress.clamp(0.0, 4.0);
    final theme = DayPhaseTheme.getInterpolated(clampedProgress);
    
    // 1. Paint dark app-matching background (transparent — the container gradient shows through)
    final rect = Offset.zero & size;
    final bgPaint = Paint()..color = const Color(0x00000000);
    canvas.drawRect(rect, bgPaint);

    // 2. Draw a soft, subtle accent glow behind the active meal area
    double activeY = size.height / 2;
    if (cardCenters.length == 5) {
      int idx = clampedProgress.floor().clamp(0, 3);
      double t = clampedProgress - idx;
      double yA = cardCenters[idx];
      double yB = cardCenters[idx + 1];
      activeY = yA + (yB - yA) * t;
    }

    final double glowX = size.width * 0.45;
    final double glowY = activeY;

    // Subtle phase-colored glow that blends with the dark background
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          theme.glowColor.withValues(alpha: 0.12),
          theme.glowColor.withValues(alpha: 0.03),
          theme.glowColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        radius: 0.55,
      ).createShader(Rect.fromCircle(center: Offset(glowX, glowY), radius: size.width * 0.85));
    
    canvas.drawCircle(Offset(glowX, glowY), size.width * 0.85, glowPaint);

    // 3. Add a very subtle top-edge gradient tint for depth
    final topTintPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          theme.accentColor.withValues(alpha: 0.04),
          theme.accentColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.3],
      ).createShader(rect);
    canvas.drawRect(rect, topTintPaint);
  }

  @override
  bool shouldRepaint(covariant SkyBackdropPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.cardCenters != cardCenters;
  }
}

class TimelineSegment extends StatefulWidget {
  final int index;
  final ValueNotifier<double> progressNotifier;
  final DayPhaseTheme phase;
  final bool isExpanded;
  final bool isEaten;

  const TimelineSegment({
    super.key,
    required this.index,
    required this.progressNotifier,
    required this.phase,
    required this.isExpanded,
    required this.isEaten,
  });

  @override
  State<TimelineSegment> createState() => _TimelineSegmentState();
}

class _TimelineSegmentState extends State<TimelineSegment> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );
    if (widget.isExpanded) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(TimelineSegment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _pulseController.reset();
        _pulseController.repeat();
      } else {
        _pulseController.animateTo(1.0, duration: const Duration(milliseconds: 300)).then((_) {
          if (mounted && !widget.isExpanded) {
            _pulseController.stop();
            _pulseController.reset();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextPhaseIndex = (widget.index + 1).clamp(0, 4);
    final nextPhase = DayPhaseTheme.phases[nextPhaseIndex];
    final phaseColor = widget.phase.accentColor;

    return ValueListenableBuilder<double>(
      valueListenable: widget.progressNotifier,
      builder: (context, progress, child) {
        return CustomPaint(
          painter: TimelinePainter(
            progress: progress,
            index: widget.index,
            activeColorStart: phaseColor,
            activeColorEnd: nextPhase.accentColor,
            inactiveColor: AppColors.glassBorder.withValues(alpha: 0.4),
            isExpanded: widget.isExpanded,
            isEaten: widget.isEaten,
          ),
          child: SizedBox(
            width: 40,
            child: Center(
              child: _buildNode(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNode() {
    final phaseColor = widget.phase.accentColor;

    // Determine sizes based on state
    final double nodeSize = widget.isExpanded ? 28.0 : (widget.isEaten ? 18.0 : 14.0);

    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing outer ring (expanded only)
          if (widget.isExpanded)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final double scale = 1.0 + (0.35 * _pulseController.value);
                final double opacity = (1.0 - _pulseController.value).clamp(0.0, 1.0);
                return Container(
                  width: nodeSize * scale,
                  height: nodeSize * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: phaseColor.withValues(alpha: 0.25 * opacity),
                      width: 1.5,
                    ),
                  ),
                );
              },
            ),

          // Main node circle
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              double breathe = 0.0;
              if (widget.isExpanded) {
                breathe = (math.sin(_pulseController.value * 2 * math.pi) + 1.0) / 2.0;
              }
              final double size = nodeSize + (widget.isExpanded ? 2.0 * breathe : 0.0);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  // Expanded: solid accent fill
                  // Eaten: softer accent fill
                  // Inactive: dark bg with subtle border
                  color: widget.isExpanded
                      ? phaseColor
                      : (widget.isEaten
                          ? phaseColor.withValues(alpha: 0.7)
                          : AppColors.bgTertiary),
                  border: Border.all(
                    color: widget.isExpanded
                        ? phaseColor
                        : (widget.isEaten
                            ? phaseColor.withValues(alpha: 0.5)
                            : AppColors.textDisabled.withValues(alpha: 0.35)),
                    width: widget.isExpanded ? 2.0 : 1.5,
                  ),
                  boxShadow: widget.isExpanded
                      ? [
                          BoxShadow(
                            color: phaseColor.withValues(alpha: 0.4 + 0.1 * breathe),
                            blurRadius: 12.0 + 4.0 * breathe,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: _buildNodeIcon(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget? _buildNodeIcon() {
    if (widget.isExpanded) {
      return Center(
        child: Icon(
          widget.phase.phaseIcon,
          color: Colors.white,
          size: 13,
        ),
      );
    }

    if (widget.isEaten) {
      return const Center(
        child: Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 11,
        ),
      );
    }

    // Inactive: small center dot
    return Center(
      child: Container(
        width: 4,
        height: 4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.textDisabled.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class TimelinePainter extends CustomPainter {
  final double progress;
  final int index;
  final Color activeColorStart;
  final Color activeColorEnd;
  final Color inactiveColor;
  final bool isExpanded;
  final bool isEaten;

  TimelinePainter({
    required this.progress,
    required this.index,
    required this.activeColorStart,
    required this.activeColorEnd,
    required this.inactiveColor,
    required this.isExpanded,
    required this.isEaten,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    // Inactive track paint — thin and subtle
    final paintTrack = Paint()
      ..color = inactiveColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Active track paint — uses the segment's own color, no inter-phase blending
    final paintActive = Paint()
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // 1. Draw vertical inactive track lines
    if (index > 0) {
      canvas.drawLine(Offset(centerX, 0), Offset(centerX, centerY - 8), paintTrack);
    }
    if (index < 4) {
      canvas.drawLine(Offset(centerX, centerY + 8), Offset(centerX, size.height), paintTrack);
    }

    // 2. Draw vertical active track lines (solid color per segment)
    // Top active line — uses this segment's color
    if (index > 0) {
      double topProgress = 0.0;
      if (progress >= index) {
        topProgress = 1.0;
      } else if (progress > index - 1) {
        topProgress = progress - (index - 1);
      }

      if (topProgress > 0.0) {
        paintActive.color = activeColorStart.withValues(alpha: 0.7);
        paintActive.shader = null;
        canvas.drawLine(
          Offset(centerX, 0),
          Offset(centerX, (centerY - 8) * topProgress),
          paintActive,
        );
      }
    }

    // Bottom active line — uses this segment's color
    if (index < 4) {
      double bottomProgress = 0.0;
      if (progress >= index + 1) {
        bottomProgress = 1.0;
      } else if (progress > index) {
        bottomProgress = progress - index;
      }

      if (bottomProgress > 0.0) {
        paintActive.color = activeColorStart.withValues(alpha: 0.7);
        paintActive.shader = null;
        canvas.drawLine(
          Offset(centerX, centerY + 8),
          Offset(centerX, (centerY + 8) + (size.height - centerY - 8) * bottomProgress),
          paintActive,
        );
      }
    }

    // 3. Draw horizontal connector line to the card
    final connectorPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = isExpanded ? 2.0 : 1.5;

    if (isExpanded) {
      connectorPaint.color = activeColorStart.withValues(alpha: 0.6);
    } else if (isEaten) {
      connectorPaint.color = activeColorStart.withValues(alpha: 0.35);
    } else {
      connectorPaint.color = inactiveColor.withValues(alpha: 0.4);
    }

    canvas.drawLine(
      Offset(centerX + 6, centerY),
      Offset(size.width, centerY),
      connectorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant TimelinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.index != index ||
        oldDelegate.activeColorStart != activeColorStart ||
        oldDelegate.activeColorEnd != activeColorEnd ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.isExpanded != isExpanded ||
        oldDelegate.isEaten != isEaten;
  }
}

// ─────────────────────────────────────────────
// INTERACTIVE PRESS SCALE ANIMATOR
// ─────────────────────────────────────────────

class InteractivePressCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const InteractivePressCard({super.key, required this.child, required this.onTap});

  @override
  State<InteractivePressCard> createState() => _InteractivePressCardState();
}

class _InteractivePressCardState extends State<InteractivePressCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
