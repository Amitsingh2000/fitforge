import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// The soft radial-gradient background blobs used behind nearly every screen
/// in the app (top-right + bottom-left glow) — previously copy-pasted inline
/// on each screen; centralized here so new screens match automatically.
class AmbientGlowBackground extends StatelessWidget {
  const AmbientGlowBackground({
    super.key,
    this.topColor = AppColors.accentCyan,
    this.bottomColor = AppColors.accentPurple,
  });

  final Color topColor;

  /// Pass `null` for a single-glow background (e.g. detail screens that only
  /// need one accent in the corner).
  final Color? bottomColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [topColor.withValues(alpha: 0.06), Colors.transparent],
              ),
            ),
          ),
        ),
        if (bottomColor != null)
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [bottomColor!.withValues(alpha: 0.04), Colors.transparent],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
