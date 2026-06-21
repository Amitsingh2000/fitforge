import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/chip_selector.dart';
import '../widgets/primary_button.dart';

class LifestyleScreen extends StatefulWidget {
  final Map<String, String?> initialData;
  final ValueChanged<Map<String, String?>> onDataChanged;
  final VoidCallback onContinue;

  const LifestyleScreen({
    super.key,
    required this.initialData,
    required this.onDataChanged,
    required this.onContinue,
  });

  @override
  State<LifestyleScreen> createState() => _LifestyleScreenState();
}

class _LifestyleScreenState extends State<LifestyleScreen> {
  late String? _activityLevel;
  late String? _dietPreference;
  late String? _experience;
  late String? _sleepSchedule;

  @override
  void initState() {
    super.initState();
    _activityLevel = widget.initialData['activityLevel'];
    _dietPreference = widget.initialData['dietPreference'];
    _experience = widget.initialData['experience'];
    _sleepSchedule = widget.initialData['sleepSchedule'];
  }

  bool get _isComplete =>
      _activityLevel != null &&
      _dietPreference != null &&
      _experience != null &&
      _sleepSchedule != null;

  void _emitData() {
    widget.onDataChanged({
      'activityLevel': _activityLevel,
      'dietPreference': _dietPreference,
      'experience': _experience,
      'sleepSchedule': _sleepSchedule,
    });
  }

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
              'Your lifestyle',
              style: AppTextStyles.headlineMedium,
            ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
            const SizedBox(height: 8),
            Text(
              'Help us tailor your plan to fit your daily routine.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            const SizedBox(height: 32),

            _buildSectionLabel('Activity Level')
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 12),
            ChipSelector(
              options: const [
                'Sedentary',
                'Light',
                'Moderate',
                'Active',
                'Very Active',
              ],
              selectedOption: _activityLevel,
              onSelected: (v) {
                setState(() => _activityLevel = v);
                _emitData();
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 250.ms),
            const SizedBox(height: 28),

            _buildSectionLabel('Diet Preference')
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 12),
            ChipSelector(
              options: const [
                'No Preference',
                'Vegetarian',
                'Vegan',
                'Keto',
                'Paleo',
                'Mediterranean',
              ],
              selectedOption: _dietPreference,
              onSelected: (v) {
                setState(() => _dietPreference = v);
                _emitData();
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 350.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 350.ms),
            const SizedBox(height: 28),

            _buildSectionLabel('Workout Experience')
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms),
            const SizedBox(height: 12),
            _buildExperienceCards()
                .animate()
                .fadeIn(duration: 400.ms, delay: 450.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 450.ms),
            const SizedBox(height: 28),

            _buildSectionLabel('Sleep Duration')
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms),
            const SizedBox(height: 12),
            ChipSelector(
              options: const [
                '< 5h',
                '5–6h',
                '6–7h',
                '7–8h',
                '8h+',
              ],
              selectedOption: _sleepSchedule,
              onSelected: (v) {
                setState(() => _sleepSchedule = v);
                _emitData();
              },
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 550.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 550.ms),
            const SizedBox(height: 36),

            PrimaryButton(
              label: 'Continue',
              isEnabled: _isComplete,
              onTap: _isComplete ? widget.onContinue : null,
            ).animate().fadeIn(duration: 500.ms, delay: 600.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        letterSpacing: 1.2,
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildExperienceCards() {
    const experiences = [
      {
        'level': 'Beginner',
        'desc': 'New to working out',
        'icon': Icons.directions_walk_rounded,
      },
      {
        'level': 'Intermediate',
        'desc': '1–3 years of training',
        'icon': Icons.directions_run_rounded,
      },
      {
        'level': 'Advanced',
        'desc': '3+ years of training',
        'icon': Icons.bolt_rounded,
      },
    ];

    return Row(
      children: experiences.map((exp) {
        final isSelected = _experience == exp['level'];
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _experience = exp['level'] as String);
              _emitData();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: exp != experiences.last ? 10 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentBlue.withValues(alpha: 0.1)
                    : AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentBlue.withValues(alpha: 0.4)
                      : AppColors.glassBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    exp['icon'] as IconData,
                    color: isSelected
                        ? AppColors.accentBlue
                        : AppColors.textTertiary,
                    size: 28,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    exp['level'] as String,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isSelected
                          ? AppColors.accentBlue
                          : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exp['desc'] as String,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
