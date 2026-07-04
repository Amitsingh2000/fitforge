import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';

class TrainerGlassStatCard extends StatelessWidget {
  final String title;
  final dynamic value; // can be String, int, double
  final IconData icon;
  final Color color;
  final String trendText;
  final bool isTrendPositive;
  final String prefix;
  final String suffix;
  final bool isAnimated;

  const TrainerGlassStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.trendText = '',
    this.isTrendPositive = true,
    this.prefix = '',
    this.suffix = '',
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget valueWidget;
    if (isAnimated && value is num) {
      valueWidget = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: (value as num).toDouble()),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, val, _) {
          String displayValue;
          if (value is int) {
            displayValue = '$prefix${val.toInt()}$suffix';
          } else {
            displayValue = '$prefix${val.toStringAsFixed(1)}$suffix';
          }
          return Text(
            displayValue,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          );
        },
      );
    } else {
      valueWidget = Text(
        '$prefix$value$suffix',
        style: AppTextStyles.titleLarge.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 22,
          color: AppColors.textPrimary,
        ),
      );
    }

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon and Trend Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
              ),
              if (trendText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: (isTrendPositive ? AppColors.accentCyan : AppColors.accentCoral)
                        .withValues(alpha: 0.1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isTrendPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: isTrendPositive ? AppColors.accentCyan : AppColors.accentCoral,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trendText,
                        style: AppTextStyles.caption.copyWith(
                          color: isTrendPositive ? AppColors.accentCyan : AppColors.accentCoral,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Value and Title
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              valueWidget,
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
