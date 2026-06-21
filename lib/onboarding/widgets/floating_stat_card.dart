import 'dart:math';
import 'package:flutter/material.dart';
import 'glass_card.dart';
import '../../theme/app_theme.dart';

class FloatingStatCard extends StatefulWidget {
  final String emoji;
  final String label;
  final String value;
  final Color accentColor;
  final double floatAmplitude;
  final double floatSpeed;
  final double initialPhase;

  const FloatingStatCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.value,
    required this.accentColor,
    this.floatAmplitude = 8,
    this.floatSpeed = 1.5,
    this.initialPhase = 0,
  });

  @override
  State<FloatingStatCard> createState() => _FloatingStatCardState();
}

class _FloatingStatCardState extends State<FloatingStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.floatSpeed * 1000).toInt()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = sin(
              (_controller.value * 2 * pi) + widget.initialPhase,
            ) *
            widget.floatAmplitude;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 16,
        blurSigma: 12,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.value,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
