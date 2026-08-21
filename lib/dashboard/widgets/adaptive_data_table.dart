import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'dashboard_glass_card.dart';

class AdaptiveDataColumn {
  final String label;
  final int flex;
  const AdaptiveDataColumn(this.label, {this.flex = 1});
}

/// Dense glass table for tablet/desktop. Use cards on phone via [Layout.useRail].
class AdaptiveDataTable extends StatelessWidget {
  const AdaptiveDataTable({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.cellsBuilder,
    this.onRowTap,
    this.trailingBuilder,
  });

  final List<AdaptiveDataColumn> columns;
  final int rowCount;
  final List<Widget> Function(BuildContext context, int index) cellsBuilder;
  final void Function(int index)? onRowTap;
  final Widget? Function(BuildContext context, int index)? trailingBuilder;

  @override
  Widget build(BuildContext context) {
    return DashboardGlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 18,
      child: Column(
        children: [
          _header(),
          for (var i = 0; i < rowCount; i++) ...[
            if (i > 0) Divider(height: 1, color: AppColors.glassBorder),
            _row(context, i),
          ],
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgTertiary.withValues(alpha: 0.55),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: [
          for (final col in columns)
            Expanded(
              flex: col.flex,
              child: Text(
                col.label.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  fontSize: 10,
                ),
              ),
            ),
          if (trailingBuilder != null) const SizedBox(width: 104),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, int index) {
    final cells = cellsBuilder(context, index);
    assert(cells.length == columns.length);
    final trailing = trailingBuilder?.call(context, index);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onRowTap == null ? null : () => onRowTap!(index),
        hoverColor: AppColors.accentBlue.withValues(alpha: 0.06),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              for (var c = 0; c < columns.length; c++)
                Expanded(
                  flex: columns[c].flex,
                  child: DefaultTextStyle(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    child: cells[c],
                  ),
                ),
              // Reserve the trailing column whenever a builder is wired at
              // all, not just when this particular row has something to show
              // — otherwise rows that opt out (e.g. a voided payment with no
              // void button) render with wider cell columns than their
              // neighbors and the table's edges no longer line up.
              if (trailingBuilder != null)
                SizedBox(
                  width: 104,
                  child: trailing == null
                      ? const SizedBox.shrink()
                      : Align(alignment: Alignment.centerRight, child: trailing),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status chip reused by table rows.
class AdaptiveStatusChip extends StatelessWidget {
  const AdaptiveStatusChip(this.label, {super.key, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      ),
    );
  }
}
