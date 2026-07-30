import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/brilliant_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/linear_progress_bar.dart';
import '../widgets/radial_progress.dart';
import 'meal_builder_screen.dart';

/// Diet Plan content — designed to be embedded inside the DashboardShell.
class DietPlanContent extends StatefulWidget {
  const DietPlanContent({super.key});

  @override
  State<DietPlanContent> createState() => _DietPlanContentState();
}

class _DietPlanContentState extends State<DietPlanContent> {
  final int _caloriesTarget = 2500;
  final int _proteinTarget = 140;
  final int _carbsTarget = 220;
  final int _fatsTarget = 70;

  int _caloriesConsumed = 0;
  int _proteinConsumed = 0;
  int _carbsConsumed = 0;
  int _fatsConsumed = 0;

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

  final List<Map<String, dynamic>> _insights = [
    {
      'text': 'You\'re on track to reach today\'s protein goal.',
      'icon': Icons.check_circle_outline_rounded,
      'color': BrilliantColors.mint,
    },
    {
      'text': 'Drink another 500 ml of water before this afternoon.',
      'icon': Icons.water_drop_rounded,
      'color': BrilliantColors.blue,
    },
    {
      'text': 'Adding one fruit serving will improve today\'s fiber intake.',
      'icon': Icons.eco_rounded,
      'color': BrilliantColors.purple,
    },
  ];

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
        SliverToBoxAdapter(child: _buildDietHeader()),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildCombinedNutritionTracker()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms),
              const SizedBox(height: 20),

              _buildSectionLabel("TODAY'S FOOD CHECKLIST"),
              const SizedBox(height: 12),
              _buildCombinedMealChecklist()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 20),

              _buildGenerateMealButton()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 150.ms),
              const SizedBox(height: 24),

              _buildSectionLabel('AI GUIDANCE'),
              const SizedBox(height: 10),
              _buildAICoachSection()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDietHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: BrilliantColors.mint.withValues(alpha: 0.15),
              border: Border.all(color: BrilliantColors.mint.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.restaurant_menu_rounded,
                color: BrilliantColors.mint,
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
                  style: BrilliantTheme.headerStyle(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  _formattedDate,
                  style: BrilliantTheme.bodyStyle(fontSize: 12, color: BrilliantColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: BrilliantColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BrilliantColors.amber.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: BrilliantColors.amber,
                ),
                const SizedBox(width: 5),
                Text(
                  'AI Plan',
                  style: TextStyle(
                    color: BrilliantColors.amber,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: BrilliantTheme.badgeStyle(color: BrilliantColors.mint),
    );
  }

  Widget _buildCombinedNutritionTracker() {
    final totalItems = _mealItems.length;
    final checkedItems = _mealItems.where((item) => item['checked'] == true).length;
    final mealProgress = totalItems > 0 ? (checkedItems / totalItems) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: BrilliantColors.bgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✦', style: TextStyle(color: BrilliantColors.amber, fontSize: 14)),
              const SizedBox(width: 8),
              Text(
                'Stay consistent. Every meal counts.',
                style: TextStyle(
                  color: BrilliantColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        DashboardGlassCard(
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
                      Text(
                        'Meal Plan Progress',
                        style: BrilliantTheme.titleStyle(fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$checkedItems of $totalItems items eaten',
                        style: BrilliantTheme.bodyStyle(fontSize: 12, color: BrilliantColors.textMuted),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: BrilliantColors.mint.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: BrilliantColors.mint.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '${(mealProgress * 100).round()}%',
                      style: const TextStyle(
                        color: BrilliantColors.mint,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressBar(
                progress: mealProgress,
                color: BrilliantColors.mint,
                height: 8,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  height: 1.5,
                  color: BrilliantColors.surfaceBorder,
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildRadialMetric(
                    emoji: '🔥',
                    label: 'Calories',
                    progress: _caloriesConsumed / _caloriesTarget,
                    current: '$_caloriesConsumed',
                    target: '$_caloriesTarget',
                    color: BrilliantColors.coral,
                  ),
                  _buildRadialMetric(
                    emoji: '💪',
                    label: 'Protein',
                    progress: _proteinConsumed / _proteinTarget,
                    current: '${_proteinConsumed}g',
                    target: '${_proteinTarget}g',
                    color: BrilliantColors.mint,
                  ),
                  _buildRadialMetric(
                    emoji: '🌾',
                    label: 'Carbs',
                    progress: _carbsConsumed / _carbsTarget,
                    current: '${_carbsConsumed}g',
                    target: '${_carbsTarget}g',
                    color: BrilliantColors.purple,
                  ),
                  _buildRadialMetric(
                    emoji: '🥑',
                    label: 'Fats',
                    progress: _fatsConsumed / _fatsTarget,
                    current: '${_fatsConsumed}g',
                    target: '${_fatsTarget}g',
                    color: BrilliantColors.amber,
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
            size: 56,
            strokeWidth: 5,
            progressColor: color,
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: BrilliantColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$current / $target',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
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
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: BrilliantColors.mint.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.checklist_rounded,
                  color: BrilliantColors.mint,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Today's Meals",
                  style: BrilliantTheme.titleStyle(fontSize: 15),
                ),
              ),
              Text(
                '$checkedItems/$totalItems eaten',
                style: TextStyle(
                  color: BrilliantColors.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
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
                  style: TextStyle(
                    color: BrilliantColors.textMuted,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
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
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: BrilliantColors.surfaceBorder,
                ),
              ),
              itemBuilder: (context, index) {
                final item = _mealItems[index];
                final isChecked = item['checked'] == true;
                final isCustom = item['isCustom'] == true;

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
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isChecked
                                ? BrilliantColors.mint
                                : Colors.transparent,
                            border: Border.all(
                              color: isChecked
                                  ? BrilliantColors.mint
                                  : BrilliantColors.textMuted,
                              width: 2,
                            ),
                          ),
                          child: isChecked
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: BrilliantColors.textInverse,
                                  size: 16,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          (item['icon'] as String?) ?? '🍽️',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item['name'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isChecked
                                            ? BrilliantColors.textMuted
                                            : BrilliantColors.textPrimary,
                                        decoration: isChecked ? TextDecoration.lineThrough : null,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isCustom) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: BrilliantColors.coral.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['quantity'] != null ? '${item['quantity']}x' : 'Custom',
                                        style: const TextStyle(
                                          color: BrilliantColors.coral,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9,
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
                                  style: TextStyle(
                                    color: BrilliantColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item['calories']} cal',
                              style: TextStyle(
                                color: isChecked
                                    ? BrilliantColors.textMuted
                                    : BrilliantColors.mint,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '${item['protein']}g P · ${item['carbs']}g C · ${item['fat']}g F',
                              style: TextStyle(
                                color: BrilliantColors.textMuted,
                                fontSize: 10,
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

  void _navigateToMealBuilder() async {
    final remainingCal = (_caloriesTarget - _caloriesConsumed).clamp(0, _caloriesTarget);
    final remainingProt = (_proteinTarget - _proteinConsumed).clamp(0, _proteinTarget);
    final remainingCarbs = (_carbsTarget - _carbsConsumed).clamp(0, _carbsTarget);
    final remainingFats = (_fatsTarget - _fatsConsumed).clamp(0, _fatsTarget);

    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => MealBuilderScreen(
          remainingCalories: remainingCal,
          remainingProtein: remainingProt,
          remainingCarbs: remainingCarbs,
          remainingFats: remainingFats,
          totalCaloriesTarget: _caloriesTarget,
          totalProteinTarget: _proteinTarget,
          totalCarbsTarget: _carbsTarget,
          totalFatsTarget: _fatsTarget,
        ),
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
    return BrilliantButton(
      fullWidth: true,
      onPressed: _navigateToMealBuilder,
      color: BrilliantColors.mint,
      shadowColor: BrilliantColors.mintDark,
      textColor: BrilliantColors.textInverse,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 20),
          SizedBox(width: 8),
          Text(
            'Generate Custom AI Meal',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildAICoachSection() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: BrilliantColors.amber.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: BrilliantColors.amber,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Today's AI Insights",
                style: BrilliantTheme.titleStyle(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                        color: (insight['color'] as Color).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        insight['icon'] as IconData,
                        color: insight['color'] as Color,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        insight['text'] as String,
                        style: TextStyle(
                          color: BrilliantColors.textPrimary,
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: BrilliantColors.surfaceBorder,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
