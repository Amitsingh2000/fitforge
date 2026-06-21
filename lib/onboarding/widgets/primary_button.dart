import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool showShimmer;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isEnabled = true,
    this.showShimmer = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.showShimmer) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(PrimaryButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showShimmer && !_shimmerController.isAnimating) {
      _shimmerController.repeat();
    } else if (!widget.showShimmer && _shimmerController.isAnimating) {
      _shimmerController.stop();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.isEnabled && widget.onTap != null;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _isPressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(_isPressed ? 0.97 : 1.0, _isPressed ? 0.97 : 1.0, 1.0),
        transformAlignment: Alignment.center,
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentBlue,
                    Color(0xFF6366F1),
                  ],
                )
              : null,
          color: enabled ? null : AppColors.bgTertiary,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Shimmer overlay
            if (widget.showShimmer && enabled)
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          begin: Alignment(-1.0 + 3.0 * _shimmerController.value, 0),
                          end: Alignment(0.0 + 3.0 * _shimmerController.value, 0),
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.srcATop,
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  );
                },
              ),
            Center(
              child: Text(
                widget.label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: enabled
                      ? Colors.white
                      : AppColors.textDisabled,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
