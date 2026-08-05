import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LinearProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final Color color;
  final double height;

  const LinearProgressBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 6,
  });

  double get _safeProgress {
    if (progress.isNaN || progress.isInfinite) return 0.0;
    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final targetProgress = _safeProgress;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: AppColors.bgTertiary,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: targetProgress),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          final widthFactor = (value.isNaN || value.isInfinite) ? 0.0 : value.clamp(0.0, 1.0);
          return FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
