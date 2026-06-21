import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/goal_card.dart';
import '../widgets/primary_button.dart';

class GoalSelectionScreen extends StatefulWidget {
  final String? initialGoal;
  final ValueChanged<String> onGoalSelected;
  final VoidCallback onContinue;

  const GoalSelectionScreen({
    super.key,
    this.initialGoal,
    required this.onGoalSelected,
    required this.onContinue,
  });

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  late String? _selectedGoal;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.initialGoal;
  }

  static const _goals = [
    {
      'icon': Icons.trending_down_rounded,
      'title': 'Lose Weight',
      'subtitle': 'Burn fat and get leaner with a structured plan',
    },
    {
      'icon': Icons.fitness_center_rounded,
      'title': 'Build Muscle',
      'subtitle': 'Gain strength and build lean muscle mass',
    },
    {
      'icon': Icons.favorite_rounded,
      'title': 'Stay Fit',
      'subtitle': 'Maintain your current fitness and stay active',
    },
    {
      'icon': Icons.self_improvement_rounded,
      'title': 'Improve Lifestyle',
      'subtitle': 'Better habits, nutrition, and daily wellness',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 72),
            Text(
              'What\'s your goal?',
              style: AppTextStyles.headlineMedium,
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .slideX(begin: -0.1, end: 0, duration: 500.ms),
            const SizedBox(height: 8),
            Text(
              'Choose the focus area that matches where you are right now.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 100.ms)
                .slideX(begin: -0.1, end: 0, duration: 500.ms, delay: 100.ms),
            const SizedBox(height: 32),
            ...List.generate(_goals.length, (index) {
              final goal = _goals[index];
              return Padding(
                padding: EdgeInsets.only(bottom: index < _goals.length - 1 ? 14 : 0),
                child: GoalCard(
                  icon: goal['icon'] as IconData,
                  title: goal['title'] as String,
                  subtitle: goal['subtitle'] as String,
                  isSelected: _selectedGoal == goal['title'],
                  onTap: () {
                    setState(() => _selectedGoal = goal['title'] as String);
                    widget.onGoalSelected(goal['title'] as String);
                  },
                )
                    .animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: Duration(milliseconds: 200 + (index * 80)),
                    )
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 400.ms,
                      delay: Duration(milliseconds: 200 + (index * 80)),
                    ),
              );
            }),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Continue',
              isEnabled: _selectedGoal != null,
              onTap: _selectedGoal != null ? widget.onContinue : null,
            )
                .animate()
                .fadeIn(duration: 500.ms, delay: 600.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms, delay: 600.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
