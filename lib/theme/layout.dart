import 'package:flutter/material.dart';

/// Shared breakpoints for phone / tablet / desktop.
///
/// Compact: bottom glass nav, 2-up cards.
/// Medium+: side rail, fluid grids, more page padding.
/// Expanded: wider rail labels + content capped at [appMax].
class Layout {
  static const compact = 600.0;
  static const medium = 840.0;
  static const expanded = 1200.0;
  static const appMax = 1440.0;

  /// Login / settings / single-column forms.
  static const formMax = 520.0;

  static bool useRail(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= expanded;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  /// Space so lists clear the floating bottom nav. Rail layouts need little.
  static double navClearance(BuildContext context) =>
      useRail(context) ? 24.0 : 130.0;

  static double pageGutter(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium ? 32.0 : 20.0;

  static EdgeInsets scroll(
    BuildContext context, {
    double top = 8,
    double? horizontal,
  }) {
    final h = horizontal ?? pageGutter(context);
    return EdgeInsets.fromLTRB(h, top, h, navClearance(context));
  }

  static EdgeInsets page(
    BuildContext context, {
    double top = 16,
    double bottom = 40,
  }) {
    final h = pageGutter(context);
    return EdgeInsets.fromLTRB(h, top, h, bottom);
  }

  static SliverGridDelegate cards({
    double maxCrossAxisExtent = 280,
    double childAspectRatio = 1.38,
    double spacing = 12,
  }) {
    return SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: maxCrossAxisExtent,
      childAspectRatio: childAspectRatio,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
    );
  }
}

/// Centers content and caps width so desktop/web does not stretch edge-to-edge.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = Layout.appMax,
  });

  final Widget child;
  final double maxWidth;

  /// Narrow column for auth / settings-style forms.
  const ResponsiveBody.form({super.key, required this.child})
      : maxWidth = Layout.formMax;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}
