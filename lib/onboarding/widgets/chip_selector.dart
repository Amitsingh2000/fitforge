import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ChipSelector extends StatelessWidget {
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String> onSelected;
  final bool wrap;

  const ChipSelector({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    this.wrap = true,
  });

  @override
  Widget build(BuildContext context) {
    if (wrap) {
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options.map((option) => _buildChip(option)).toList(),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options
            .map((option) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildChip(option),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildChip(String option) {
    final isSelected = selectedOption == option;
    return GestureDetector(
      onTap: () => onSelected(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue.withValues(alpha: 0.15)
              : AppColors.bgTertiary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.accentBlue.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          option,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
