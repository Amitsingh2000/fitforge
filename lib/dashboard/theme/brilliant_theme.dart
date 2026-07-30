import 'package:flutter/material.dart';

/// Design tokens, colors, card styling, typography, and interactive button styles
/// matching the visual aesthetic of the Brilliant.org mobile app in an Ultra-Dark Electric Blue theme.
class BrilliantColors {
  // Canvas & Backgrounds (Ultra-Dark Slate / Obsidian Theme)
  static const Color bgPrimary = Color(0xFF070A12); // Deep Obsidian Canvas (Darker)
  static const Color bgSecondary = Color(0xFF0F172A); // Dark Slate 900 Surface Card
  static const Color bgTertiary = Color(0xFF1E293B); // Slate 800 Surface Highlight
  static const Color surfaceBorder = Color(0xFF243042); // Crisp Subtle Dark Border
  static const Color surfaceBorderSubtle = Color(0xFF172030);

  // Core Brand Accents (Blue Primary Theme)
  static const Color mint = Color(0xFF2563EB); // Brilliant Electric Sapphire Blue (Primary Accent)
  static const Color mintDark = Color(0xFF1D4ED8); // Blue 3D Depth Shadow
  static const Color amber = Color(0xFFF59E0B); // Brilliant Streak & XP Amber
  static const Color amberDark = Color(0xFFD97706); // Amber 3D Depth Shadow
  
  // Feature Accents
  static const Color blue = Color(0xFF3B82F6); // Hydration / Primary Blue
  static const Color blueDark = Color(0xFF1D4ED8);
  static const Color purple = Color(0xFF8B5CF6); // Activity / Steps
  static const Color purpleDark = Color(0xFF6D28D9);
  static const Color coral = Color(0xFFF43F5E); // Calories / Alert
  static const Color coralDark = Color(0xFFBE123C);
  static const Color green = Color(0xFF0EA5E9); // Bright Cyan Blue for Success
  static const Color greenDark = Color(0xFF0284C7);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFFF8FAFC); // High Contrast White
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textInverse = Color(0xFFFFFFFF); // White text on solid blue buttons
}

class BrilliantTheme {
  // Card Decorator
  static BoxDecoration cardDecoration({
    Color backgroundColor = BrilliantColors.bgSecondary,
    Color borderColor = BrilliantColors.surfaceBorder,
    double borderRadius = 20,
    bool showTactileDepth = true,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.5),
      boxShadow: showTactileDepth
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 14,
                offset: const Offset(0, 5),
              )
            ]
          : null,
    );
  }

  // Text Styles
  static TextStyle headerStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w800,
    Color color = BrilliantColors.textPrimary,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.5,
      height: 1.2,
    );
  }

  static TextStyle titleStyle({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w700,
    Color color = BrilliantColors.textPrimary,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle bodyStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color color = BrilliantColors.textSecondary,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle badgeStyle({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w800,
    Color color = BrilliantColors.mint,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.5,
    );
  }
}

/// Signature Brilliant.org 3D Pressable Button Widget
class BrilliantButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool fullWidth;

  const BrilliantButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = BrilliantColors.mint,
    this.shadowColor = BrilliantColors.mintDark,
    this.textColor = BrilliantColors.textInverse,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.fullWidth = false,
  });

  @override
  State<BrilliantButton> createState() => _BrilliantButtonState();
}

class _BrilliantButtonState extends State<BrilliantButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double depth = _isPressed ? 1.5 : 4.0;
    final double topMargin = _isPressed ? 2.5 : 0.0;

    Widget buttonContent = AnimatedContainer(
      duration: const Duration(milliseconds: 60),
      margin: EdgeInsets.only(top: topMargin, bottom: 4.0 - topMargin),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.onPressed == null
            ? BrilliantColors.surfaceBorder
            : widget.color,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: widget.onPressed == null
            ? null
            : [
                BoxShadow(
                  color: widget.shadowColor,
                  offset: Offset(0, depth),
                  blurRadius: 0,
                ),
              ],
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: widget.onPressed == null
              ? BrilliantColors.textMuted
              : widget.textColor,
          letterSpacing: 0.2,
        ),
        child: IconTheme(
          data: IconThemeData(
            color: widget.onPressed == null
                ? BrilliantColors.textMuted
                : widget.textColor,
            size: 20,
          ),
          child: Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [widget.child],
          ),
        ),
      ),
    );

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onPressed != null) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (widget.onPressed != null) setState(() => _isPressed = false);
      },
      onTap: widget.onPressed,
      child: widget.fullWidth
          ? SizedBox(width: double.infinity, child: buttonContent)
          : buttonContent,
    );
  }
}
