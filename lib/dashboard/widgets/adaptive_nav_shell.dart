import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';

class AdaptiveNavItem {
  final IconData icon;
  final String label;
  const AdaptiveNavItem({required this.icon, required this.label});
}

/// Phone: existing glass bottom bar. Tablet/desktop: [NavigationRail].
class AdaptiveNavShell extends StatelessWidget {
  const AdaptiveNavShell({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.onSelect,
    required this.body,
    this.accent = AppColors.accentBlue,
  });

  final int selectedIndex;
  final List<AdaptiveNavItem> items;
  final ValueChanged<int> onSelect;
  final Widget body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final capped = ResponsiveBody(child: body);

    if (!Layout.useRail(context)) {
      return Stack(
        children: [
          capped,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _GlassBottomNav(
              selectedIndex: selectedIndex,
              items: items,
              onSelect: onSelect,
              accent: accent,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        NavigationRail(
          extended: Layout.isExpanded(context),
          minExtendedWidth: 196,
          backgroundColor: AppColors.bgSecondary.withValues(alpha: 0.92),
          selectedIndex: selectedIndex.clamp(0, items.length - 1),
          onDestinationSelected: onSelect,
          labelType: Layout.isExpanded(context)
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.all,
          selectedIconTheme: IconThemeData(color: accent, size: 22),
          unselectedIconTheme:
              const IconThemeData(color: AppColors.textTertiary, size: 22),
          selectedLabelTextStyle: AppTextStyles.caption.copyWith(
            color: accent,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelTextStyle: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
          indicatorColor: accent.withValues(alpha: 0.14),
          destinations: [
            for (final item in items)
              NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.icon),
                label: Text(item.label),
              ),
          ],
        ),
        VerticalDivider(width: 1, color: AppColors.glassBorder),
        Expanded(child: capped),
      ],
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.selectedIndex,
    required this.items,
    required this.onSelect,
    required this.accent,
  });

  final int selectedIndex;
  final List<AdaptiveNavItem> items;
  final ValueChanged<int> onSelect;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isActive = index == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? accent.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: isActive ? accent : AppColors.textTertiary,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: isActive ? accent : AppColors.textTertiary,
                              fontSize: 10,
                              fontWeight:
                                  isActive ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
