import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnimatedCounter extends StatelessWidget {
  final double targetValue;
  final String suffix;
  final TextStyle? style;
  final Duration duration;
  final int decimals;

  const AnimatedCounter({
    super.key,
    required this.targetValue,
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 800),
    this.decimals = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: targetValue),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final formatted = decimals > 0
            ? value.toStringAsFixed(decimals)
            : value.toInt().toString();
        return Text(
          '$formatted$suffix',
          style: style ??
              AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
        );
      },
    );
  }
}
