import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class RadialProgress extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color progressColor;
  final Color? trackColor;
  final Widget? child;

  const RadialProgress({
    super.key,
    required this.progress,
    this.size = 200,
    this.strokeWidth = 12,
    this.progressColor = AppColors.accentBlue,
    this.trackColor,
    this.child,
  });

  double get _safeProgress {
    if (progress.isNaN || progress.isInfinite) return 0.0;
    return progress.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final validProgress = _safeProgress;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RadialPainter(
              progress: validProgress,
              strokeWidth: strokeWidth,
              progressColor: progressColor,
              trackColor: trackColor ?? AppColors.bgTertiary,
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  _RadialPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (radius <= 0) return;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);

    // Progress arc
    if (sweepAngle > 0) {
      final progressPaint = Paint()
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: -pi / 2,
          endAngle: 3 * pi / 2,
          colors: [
            progressColor,
            progressColor.withValues(alpha: 0.7),
            progressColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: const GradientRotation(-pi / 2),
        ).createShader(
          Rect.fromCircle(center: center, radius: radius),
        );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }

    // Glow dot at end of progress arc
    if (progress > 0.02) {
      final dotAngle = -pi / 2 + sweepAngle;
      final dotCenter = Offset(
        center.dx + radius * cos(dotAngle),
        center.dy + radius * sin(dotAngle),
      );

      final glowPaint = Paint()
        ..color = progressColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(dotCenter, strokeWidth / 2 + 4, glowPaint);

      final dotPaint = Paint()..color = progressColor;
      canvas.drawCircle(dotCenter, (strokeWidth / 2 - 1).clamp(1.0, 100.0), dotPaint);
    }
  }

  @override
  bool shouldRepaint(_RadialPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.progressColor != progressColor;
}
