import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/brilliant_theme.dart';

/// Animated flame icon for streak display inspired by Brilliant Amber Streak counter
class StreakFlame extends StatefulWidget {
  final double size;

  const StreakFlame({super.key, this.size = 24});

  @override
  State<StreakFlame> createState() => _StreakFlameState();
}

class _StreakFlameState extends State<StreakFlame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
        final scale = 1.0 + sin(_controller.value * pi) * 0.08;
        return Transform.scale(
          scale: scale,
          child: ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  BrilliantColors.amber,
                  Color(0xFFFF7A00),
                ],
              ).createShader(bounds);
            },
            child: Text(
              '🔥',
              style: TextStyle(fontSize: widget.size),
            ),
          ),
        );
      },
    );
  }
}
