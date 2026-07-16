import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class PersonalDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final ValueChanged<Map<String, dynamic>> onDataChanged;
  final VoidCallback onContinue;

  const PersonalDetailsScreen({
    super.key,
    required this.initialData,
    required this.onDataChanged,
    required this.onContinue,
  });

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late String _gender;
  late double _age;
  late double _height; // cm
  late double _weight; // kg
  bool _isMetric = true;

  @override
  void initState() {
    super.initState();
    _gender = widget.initialData['gender'] ?? 'Male';
    _age = (widget.initialData['age'] ?? 25).toDouble();
    _height = (widget.initialData['height'] ?? 170).toDouble();
    _weight = (widget.initialData['weight'] ?? 70).toDouble();
  }

  double get _bmi {
    final heightM = _height / 100;
    if (heightM <= 0) return 0;
    return _weight / (heightM * heightM);
  }

  String get _bmiCategory {
    final bmi = _bmi;
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color get _bmiColor {
    final bmi = _bmi;
    if (bmi < 18.5) return AppColors.accentCyan;
    if (bmi < 25) return AppColors.accentBlue;
    if (bmi < 30) return AppColors.accentOrange;
    return AppColors.accentCoral;
  }

  int get _estimatedCalories {
    double bmr;
    if (_gender == 'Male') {
      bmr = 88.362 + (13.397 * _weight) + (4.799 * _height) - (5.677 * _age);
    } else {
      bmr = 447.593 + (9.247 * _weight) + (3.098 * _height) - (4.330 * _age);
    }
    return (bmr * 1.55).round();
  }

  void _updateData() {
    widget.onDataChanged({
      'gender': _gender,
      'age': _age.round(),
      'height': _height.round(),
      'weight': _weight.round(),
    });
  }

  String _displayHeight(double cm) {
    if (_isMetric) return '${cm.round()} cm';
    final totalInches = cm / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return '$feet\'$inches"';
  }

  String _displayWeight(double kg) {
    if (_isMetric) return '${kg.round()} kg';
    return '${(kg * 2.205).round()} lbs';
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Tell us about you',
                    style: AppTextStyles.headlineMedium,
                  ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1, end: 0),
                ),
                const SizedBox(width: 8),
                _buildUnitToggle()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 200.ms),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll use this to personalize your targets.',
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
            ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
            const SizedBox(height: 28),

            _buildSectionLabel('Gender')
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 12),
            _buildGenderSelector()
                .animate()
                .fadeIn(duration: 400.ms, delay: 250.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 250.ms),
            const SizedBox(height: 28),

            _buildSectionLabel('Age')
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 12),
            _buildSliderCard(
              value: _age,
              min: 15,
              max: 80,
              displayValue: '${_age.round()}',
              unit: 'years',
              activeColor: AppColors.accentBlue,
              onChanged: (v) {
                setState(() => _age = v);
                _updateData();
              },
            ).animate().fadeIn(duration: 400.ms, delay: 350.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 350.ms),
            const SizedBox(height: 24),

            _buildSectionLabel('Height')
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms),
            const SizedBox(height: 12),
            _buildSliderCard(
              value: _height,
              min: 120,
              max: 220,
              displayValue: _displayHeight(_height),
              unit: '',
              activeColor: AppColors.accentPurple,
              onChanged: (v) {
                setState(() => _height = v);
                _updateData();
              },
            ).animate().fadeIn(duration: 400.ms, delay: 450.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 450.ms),
            const SizedBox(height: 24),

            _buildSectionLabel('Weight')
                .animate()
                .fadeIn(duration: 400.ms, delay: 500.ms),
            const SizedBox(height: 12),
            _buildSliderCard(
              value: _weight,
              min: 30,
              max: 180,
              displayValue: _displayWeight(_weight),
              unit: '',
              activeColor: AppColors.accentCoral,
              onChanged: (v) {
                setState(() => _weight = v);
                _updateData();
              },
            ).animate().fadeIn(duration: 400.ms, delay: 550.ms)
                .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 550.ms),
            const SizedBox(height: 28),

            _buildBmiCard()
                .animate()
                .fadeIn(duration: 500.ms, delay: 600.ms)
                .slideY(begin: 0.15, end: 0, duration: 500.ms, delay: 600.ms),
            const SizedBox(height: 28),

            PrimaryButton(
              label: 'Continue',
              onTap: widget.onContinue,
            ).animate().fadeIn(duration: 500.ms, delay: 700.ms),
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

  Widget _buildUnitToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleOption('Metric', _isMetric, () {
            setState(() => _isMetric = true);
          }),
          _buildToggleOption('Imperial', !_isMetric, () {
            setState(() => _isMetric = false);
          }),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bgElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          _buildGenderOption('Male', Icons.male_rounded),
          _buildGenderOption('Female', Icons.female_rounded),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String label, IconData icon) {
    final isSelected = _gender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _gender = label);
          _updateData();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.accentBlue.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentBlue.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.accentBlue : AppColors.textTertiary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required double value,
    required double min,
    required double max,
    required String displayValue,
    required String unit,
    required Color activeColor,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayValue,
                style: AppTextStyles.titleLarge.copyWith(
                  color: activeColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(
                  unit,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: activeColor,
              inactiveTrackColor: AppColors.bgTertiary,
              thumbColor: activeColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayColor: activeColor.withValues(alpha: 0.15),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  min.round().toString(),
                  style: AppTextStyles.caption,
                ),
                Text(
                  max.round().toString(),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildBmiCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _bmiColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: _bmiColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    _bmi.toStringAsFixed(1),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: _bmiColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your BMI',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _bmiCategory,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: _bmiColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: AppColors.accentCoral,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '~$_estimatedCalories kcal/day',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
