import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// The small grab-handle bar at the top of every bottom sheet in the app —
/// previously copy-pasted per sheet; centralized so new sheets match
/// automatically.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.glassBorder,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
