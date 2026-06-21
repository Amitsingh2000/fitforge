import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/linear_progress_bar.dart';
import '../widgets/radial_progress.dart';

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
  final double _waterTarget = 4.0;

  // Current consumption
  int _caloriesConsumed = 1250;
  int _proteinConsumed = 68;
  int _carbsConsumed = 105;
  int _fatsConsumed = 34;

  // Meals data
  final List<Map<String, dynamic>> _meals = [
    {
      'type': 'Breakfast',
      'time': '8:00 AM',
      'name': 'Protein Oats Bowl',
      'icon': '🥣',
      'calories': 450,
      'protein': 28,
      'carbs': 45,
      'fat': 12,
      'eaten': true,
      'ingredients': ['Rolled Oats', 'Whey Protein', 'Banana', 'Almond Butter', 'Chia Seeds'],
    },
    {
      'type': 'Morning Snack',
      'time': '10:30 AM',
      'name': 'Greek Yogurt Bowl',
      'icon': '🥛',
      'calories': 180,
      'protein': 15,
      'carbs': 12,
      'fat': 8,
      'eaten': true,
      'isSnack': true,
      'ingredients': ['Greek Yogurt', 'Honey', 'Mixed Berries'],
    },
    {
      'type': 'Lunch',
      'time': '1:00 PM',
      'name': 'Chicken Rice Bowl',
      'icon': '🍗',
      'calories': 620,
      'protein': 42,
      'carbs': 55,
      'fat': 18,
      'eaten': true,
      'ingredients': ['Grilled Chicken', 'Brown Rice', 'Broccoli', 'Olive Oil', 'Spices'],
    },
    {
      'type': 'Evening Snack',
      'time': '4:30 PM',
      'name': 'Protein Shake',
      'icon': '🥤',
      'calories': 220,
      'protein': 30,
      'carbs': 8,
      'fat': 5,
      'eaten': false,
      'isSnack': true,
      'ingredients': ['Whey Protein', 'Almond Milk', 'Peanut Butter'],
    },
    {
      'type': 'Dinner',
      'time': '7:30 PM',
      'name': 'Salmon & Quinoa',
      'icon': '🐟',
      'calories': 580,
      'protein': 38,
      'carbs': 42,
      'fat': 22,
      'eaten': false,
      'ingredients': ['Atlantic Salmon', 'Quinoa', 'Asparagus', 'Lemon', 'Dill'],
    },
  ];

  // Insights
  final List<Map<String, dynamic>> _insights = [
    {
      'text': 'You\'re on track to reach today\'s protein goal.',
      'icon': Icons.trending_up_rounded,
      'color': AppColors.accentBlue,
    },
    {
      'text': 'Increase water intake by 500ml this afternoon.',
      'icon': Icons.water_drop_rounded,
      'color': AppColors.accentCyan,
    },
    {
      'text': 'Adding one fruit serving will improve fiber intake.',
      'icon': Icons.eco_rounded,
      'color': AppColors.accentPurple,
    },
  ];

  int get _mealsCompleted => _meals.where((m) => m['eaten'] == true).length;

  void _toggleMealEaten(int index) {
    setState(() {
      final meal = _meals[index];
      final wasEaten = meal['eaten'] as bool;
      meal['eaten'] = !wasEaten;

      if (!wasEaten) {
        _caloriesConsumed += meal['calories'] as int;
        _proteinConsumed += meal['protein'] as int;
        _carbsConsumed += meal['carbs'] as int;
        _fatsConsumed += meal['fat'] as int;
      } else {
        _caloriesConsumed -= meal['calories'] as int;
        _proteinConsumed -= meal['protein'] as int;
        _carbsConsumed -= meal['carbs'] as int;
        _fatsConsumed -= meal['fat'] as int;
      }
    });
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
              // Nutrition summary hero
              _buildNutritionSummary()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideY(begin: 0.06, end: 0, duration: 600.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Meal completion progress
              _buildMealCompletionBar()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.06, end: 0, duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 24),

              // Meal timeline
              _buildSectionLabel('MEAL PLAN'),
              const SizedBox(height: 14),
              ..._buildMealTimeline(),
              const SizedBox(height: 24),

              // AI Replacement section
              _buildAIReplacementCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms)
                  .slideY(begin: 0.06, end: 0, duration: 500.ms, delay: 600.ms),
              const SizedBox(height: 24),

              // Nutrition Insights
              _buildSectionLabel('NUTRITION INSIGHTS'),
              const SizedBox(height: 14),
              _buildInsightsSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 700.ms)
                  .slideY(begin: 0.06, end: 0, duration: 500.ms, delay: 700.ms),
              const SizedBox(height: 24),

              // Bottom CTAs
              _buildLogFoodButton()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 800.ms)
                  .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 800.ms),
              const SizedBox(height: 12),
              _buildTomorrowPreview()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 850.ms),
              const SizedBox(height: 24),
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
  // NUTRITION SUMMARY HERO
  // ─────────────────────────────────────────────

  Widget _buildNutritionSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Motivational text
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.accentPurple.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✦', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                'Stay consistent. Every meal counts.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.accentPurple.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Hero nutrition card
        DashboardGlassCard(
          padding: const EdgeInsets.all(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentBlue.withValues(alpha: 0.07),
              AppColors.accentPurple.withValues(alpha: 0.04),
            ],
          ),
          child: Column(
            children: [
              // Calorie ring + label
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _caloriesConsumed / _caloriesTarget),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) {
                  return RadialProgress(
                    progress: progress,
                    size: 160,
                    strokeWidth: 12,
                    progressColor: AppColors.accentBlue,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: _caloriesConsumed.toDouble()),
                          duration: const Duration(milliseconds: 1200),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, _) {
                            return Text(
                              '${val.toInt()}',
                              style: AppTextStyles.headlineMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                height: 1,
                              ),
                            );
                          },
                        ),
                        Text(
                          '/ $_caloriesTarget cal',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Macro row
              Row(
                children: [
                  _buildMiniMacro(
                    emoji: '💪',
                    label: 'Protein',
                    current: _proteinConsumed,
                    target: _proteinTarget,
                    unit: 'g',
                    color: AppColors.accentBlue,
                  ),
                  _buildMacroDivider(),
                  _buildMiniMacro(
                    emoji: '🌾',
                    label: 'Carbs',
                    current: _carbsConsumed,
                    target: _carbsTarget,
                    unit: 'g',
                    color: AppColors.accentPurple,
                  ),
                  _buildMacroDivider(),
                  _buildMiniMacro(
                    emoji: '🥑',
                    label: 'Fats',
                    current: _fatsConsumed,
                    target: _fatsTarget,
                    unit: 'g',
                    color: AppColors.accentCoral,
                  ),
                  _buildMacroDivider(),
                  _buildMiniMacro(
                    emoji: '💧',
                    label: 'Water',
                    current: 2,
                    target: _waterTarget.toInt(),
                    unit: 'L',
                    color: AppColors.accentCyan,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bars for each macro
              _buildMacroProgressRow('Protein', _proteinConsumed, _proteinTarget, AppColors.accentBlue),
              const SizedBox(height: 8),
              _buildMacroProgressRow('Carbs', _carbsConsumed, _carbsTarget, AppColors.accentPurple),
              const SizedBox(height: 8),
              _buildMacroProgressRow('Fats', _fatsConsumed, _fatsTarget, AppColors.accentCoral),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniMacro({
    required String emoji,
    required String label,
    required int current,
    required int target,
    required String unit,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 6),
          Text(
            '$current$unit',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: color,
            ),
          ),
          Text(
            '/ $target$unit',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.glassBorder,
    );
  }

  Widget _buildMacroProgressRow(String label, int current, int target, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ),
        Expanded(
          child: LinearProgressBar(
            progress: current / target,
            color: color,
            height: 5,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(current / target * 100).round()}%',
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // MEAL COMPLETION BAR
  // ─────────────────────────────────────────────

  Widget _buildMealCompletionBar() {
    final progress = _mealsCompleted / _meals.length;

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: AppColors.accentBlue.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text(
                '$_mealsCompleted',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentBlue,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$_mealsCompleted / ${_meals.length} ',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: 'Meals Completed',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressBar(
                  progress: progress,
                  color: AppColors.accentBlue,
                  height: 5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(progress * 100).round()}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // MEAL TIMELINE
  // ─────────────────────────────────────────────

  List<Widget> _buildMealTimeline() {
    return _meals.asMap().entries.map((entry) {
      final index = entry.key;
      final meal = entry.value;
      final isSnack = meal['isSnack'] == true;
      final delay = 300 + (index * 80);

      return Padding(
        padding: EdgeInsets.only(bottom: index < _meals.length - 1 ? 12 : 0),
        child: (isSnack
            ? _buildSnackCard(meal, index)
            : _buildFullMealCard(meal, index))
            .animate()
            .fadeIn(duration: 500.ms, delay: Duration(milliseconds: delay))
            .slideY(begin: 0.06, end: 0, duration: 500.ms, delay: Duration(milliseconds: delay)),
      );
    }).toList();
  }

  Widget _buildFullMealCard(Map<String, dynamic> meal, int index) {
    final isEaten = meal['eaten'] as bool;
    final ingredients = (meal['ingredients'] as List<String>);

    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      borderColor: isEaten
          ? AppColors.accentBlue.withValues(alpha: 0.2)
          : AppColors.glassBorder,
      gradient: isEaten
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentBlue.withValues(alpha: 0.05),
                AppColors.glassBg,
              ],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.bgTertiary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    meal['icon'],
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            meal['type'],
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          meal['time'],
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                        if (isEaten) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: AppColors.accentBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meal['name'],
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Macro chips
          Row(
            children: [
              _buildNutrientChip('${meal['calories']}', 'cal', AppColors.accentCoral),
              const SizedBox(width: 8),
              _buildNutrientChip('${meal['protein']}g', 'protein', AppColors.accentBlue),
              const SizedBox(width: 8),
              _buildNutrientChip('${meal['carbs']}g', 'carbs', AppColors.accentPurple),
              const SizedBox(width: 8),
              _buildNutrientChip('${meal['fat']}g', 'fat', AppColors.accentOrange),
            ],
          ),
          const SizedBox(height: 14),

          // Ingredients preview
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ingredients.map((ing) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                ing,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildMealAction(
                  label: isEaten ? 'Eaten ✓' : 'Mark as Eaten',
                  color: isEaten ? AppColors.accentBlue : AppColors.textTertiary,
                  filled: isEaten,
                  onTap: () => _toggleMealEaten(index),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMealAction(
                  label: 'Replace',
                  color: AppColors.textTertiary,
                  filled: false,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMealAction(
                  label: 'Recipe',
                  color: AppColors.textTertiary,
                  filled: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnackCard(Map<String, dynamic> meal, int index) {
    final isEaten = meal['eaten'] as bool;

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      borderColor: isEaten
          ? AppColors.accentBlue.withValues(alpha: 0.18)
          : AppColors.glassBorder,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(meal['icon'], style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        meal['type'],
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      meal['time'],
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  meal['name'],
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${meal['calories']} cal',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.accentBlue,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${meal['protein']}g protein',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _toggleMealEaten(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isEaten ? AppColors.accentBlue : Colors.transparent,
                border: Border.all(
                  color: isEaten ? AppColors.accentBlue : AppColors.textDisabled,
                  width: 2,
                ),
              ),
              child: isEaten
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientChip(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color.withValues(alpha: 0.7),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealAction({
    required String label,
    required Color color,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: filled
              ? color.withValues(alpha: 0.12)
              : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: filled
                ? color.withValues(alpha: 0.3)
                : AppColors.glassBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: filled ? color : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // AI MEAL REPLACEMENT
  // ─────────────────────────────────────────────

  Widget _buildAIReplacementCard() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentPurple.withValues(alpha: 0.08),
          AppColors.accentBlue.withValues(alpha: 0.05),
        ],
      ),
      borderColor: AppColors.accentPurple.withValues(alpha: 0.2),
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
                  AppColors.accentPurple.withValues(alpha: 0.2),
                  AppColors.accentBlue.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.accentPurple,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need something different?',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'AI will regenerate meals matching your macros',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accentPurple, AppColors.accentBlue],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentPurple.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Replace',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // NUTRITION INSIGHTS
  // ─────────────────────────────────────────────

  Widget _buildInsightsSection() {
    return Column(
      children: _insights.asMap().entries.map((entry) {
        final index = entry.key;
        final insight = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index < _insights.length - 1 ? 10 : 0),
          child: DashboardGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (insight['color'] as Color).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    insight['icon'] as IconData,
                    color: insight['color'] as Color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    insight['text'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
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
  // BOTTOM CTAS
  // ─────────────────────────────────────────────

  Widget _buildLogFoodButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentBlue, Color(0xFF6366F1)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Log Food Manually',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTomorrowPreview() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.bgSecondary,
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: AppColors.textTertiary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Generate Tomorrow\'s Preview',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
