import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as xls;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

enum _Step { pick, preview, done }

/// `POST /gyms/:gymId/members/import` — parse the owner's CSV/Excel register
/// client-side, dry-run against the backend for a preview, then commit.
/// The backend is intentionally tolerant of messy column names — this screen
/// does not attempt to validate rows itself, only to parse them into
/// key/value objects and let the backend's per-row report drive the UI.
class BulkImportScreen extends ConsumerStatefulWidget {
  const BulkImportScreen({super.key});

  @override
  ConsumerState<BulkImportScreen> createState() => _BulkImportScreenState();
}

class _BulkImportScreenState extends ConsumerState<BulkImportScreen> {
  _Step _step = _Step.pick;
  String? _fileName;
  List<Map<String, dynamic>> _rows = [];
  Map<String, dynamic>? _dryRunResult;
  Map<String, dynamic>? _finalResult;
  bool _busy = false;
  String? _error;

  Future<void> _pickFile() async {
    setState(() { _error = null; });
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final name = result.files.single.name;
    setState(() { _busy = true; _fileName = name; });

    try {
      final rows = name.toLowerCase().endsWith('.csv')
          ? await _parseCsv(path)
          : await _parseExcel(path);
      if (rows.isEmpty) {
        throw Exception('No data rows found in this file.');
      }
      if (mounted) {
        setState(() { _rows = rows; _busy = false; });
        await _runDryRun();
      }
    } catch (e) {
      if (mounted) {
        setState(() { _busy = false; _error = 'Could not read file: ${e.toString().replaceFirst('Exception: ', '')}'; });
      }
    }
  }

  Future<List<Map<String, dynamic>>> _parseCsv(String path) async {
    final content = await File(path).readAsString();
    final table = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(content, shouldParseNumbers: false);
    if (table.isEmpty) return [];
    final headers = table.first.map((h) => h.toString().trim()).toList();
    final rows = <Map<String, dynamic>>[];
    for (final row in table.skip(1)) {
      if (row.every((c) => c.toString().trim().isEmpty)) continue;
      final map = <String, dynamic>{};
      for (var i = 0; i < headers.length && i < row.length; i++) {
        final value = row[i].toString().trim();
        if (headers[i].isNotEmpty && value.isNotEmpty) map[headers[i]] = value;
      }
      if (map.isNotEmpty) rows.add(map);
    }
    return rows.take(500).toList();
  }

  Future<List<Map<String, dynamic>>> _parseExcel(String path) async {
    final bytes = await File(path).readAsBytes();
    final book = xls.Excel.decodeBytes(bytes);
    if (book.tables.isEmpty) return [];
    final sheet = book.tables.values.first;
    final rowsRaw = sheet.rows;
    if (rowsRaw.isEmpty) return [];
    final headers = rowsRaw.first.map((c) => (c?.value?.toString() ?? '').trim()).toList();
    final rows = <Map<String, dynamic>>[];
    for (final row in rowsRaw.skip(1)) {
      final map = <String, dynamic>{};
      for (var i = 0; i < headers.length && i < row.length; i++) {
        final value = row[i]?.value?.toString().trim() ?? '';
        if (headers[i].isNotEmpty && value.isNotEmpty) map[headers[i]] = value;
      }
      if (map.isNotEmpty) rows.add(map);
    }
    return rows.take(500).toList();
  }

  Future<void> _runDryRun() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    setState(() { _busy = true; _error = null; });
    try {
      final result = await ref.read(gymOwnerServiceProvider).importMembers(gymId, rows: _rows, dryRun: true);
      if (mounted) setState(() { _dryRunResult = result; _step = _Step.preview; _busy = false; });
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _confirmImport() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    setState(() { _busy = true; _error = null; });
    try {
      final result = await ref.read(gymOwnerServiceProvider).importMembers(gymId, rows: _rows, dryRun: false);
      if (mounted) setState(() { _finalResult = result; _step = _Step.done; _busy = false; });
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = friendlyApiError(e); });
    }
  }

  void _reset() {
    setState(() {
      _step = _Step.pick;
      _fileName = null;
      _rows = [];
      _dryRunResult = null;
      _finalResult = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Bulk Import Members', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_busy) return const LoadingView(message: 'Working…');

    switch (_step) {
      case _Step.pick:
        return _buildPickStep();
      case _Step.preview:
        return _buildPreviewStep();
      case _Step.done:
        return _buildDoneStep();
    }
  }

  Widget _buildPickStep() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        Icon(Icons.upload_file_rounded, color: AppColors.accentBlue, size: 56),
        const SizedBox(height: 16),
        Text('Import from CSV or Excel', style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          "Bring your existing member register. Messy column names are fine — we'll match "
          "name, phone, and email columns automatically. You'll preview everything before anything is saved.",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentCoral.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.3)),
            ),
            child: Text(_error!, style: const TextStyle(color: AppColors.accentCoral, fontSize: 13)),
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.folder_open_rounded),
          label: const Text('Choose File', style: TextStyle(fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentBlue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 12),
        Text('Supports .csv, .xlsx, .xls — up to 500 rows per import',
            textAlign: TextAlign.center, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
      ],
    );
  }

  Widget _buildPreviewStep() {
    final result = _dryRunResult!;
    final rows = (result['rows'] as List? ?? []).cast<Map>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Preview — $_fileName', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Nothing has been saved yet. Review below, then confirm.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 12),
              _buildCountsRow(result),
            ],
          ),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(_error!, style: const TextStyle(color: AppColors.accentCoral, fontSize: 13)),
          ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _rowTile(Map<String, dynamic>.from(rows[i])),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.textTertiary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Start Over', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _confirmImport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Import ${_rows.length} Member${_rows.length == 1 ? '' : 's'}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDoneStep() {
    final result = _finalResult!;
    final rows = (result['rows'] as List? ?? []).cast<Map>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.accentCyan, size: 22),
                  const SizedBox(width: 8),
                  Text('Import complete', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 12),
              _buildCountsRow(result),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            itemCount: rows.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _rowTile(Map<String, dynamic>.from(rows[i])),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountsRow(Map<String, dynamic> result) {
    Widget chip(String label, int count, Color color) {
      if (count == 0) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
        child: Text('$label: $count', style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700)),
      );
    }

    return Wrap(
      children: [
        chip('New', result['created'] as int? ?? 0, AppColors.accentCyan),
        chip('Linked', result['linkedExisting'] as int? ?? 0, AppColors.accentBlue),
        chip('Already member', result['alreadyMember'] as int? ?? 0, AppColors.accentOrange),
        chip('Errors', result['errors'] as int? ?? 0, AppColors.accentCoral),
      ],
    );
  }

  Widget _rowTile(Map<String, dynamic> row) {
    final status = row['status'] as String? ?? '';
    final (color, icon) = switch (status) {
      'CREATED' => (AppColors.accentCyan, Icons.person_add_rounded),
      'LINKED_EXISTING' => (AppColors.accentBlue, Icons.link_rounded),
      'ALREADY_MEMBER' => (AppColors.accentOrange, Icons.check_rounded),
      'ERROR' => (AppColors.accentCoral, Icons.error_outline_rounded),
      _ => (AppColors.textTertiary, Icons.help_outline_rounded),
    };
    final name = row['fullName'] as String? ?? row['firstName'] as String? ?? 'Row ${(row['index'] as int? ?? 0) + 1}';

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 12,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (row['message'] != null)
                  Text(row['message'] as String, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (row['phone'] != null || row['email'] != null)
                  Text([row['phone'], row['email']].whereType<String>().join(' • '),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(status.replaceAll('_', ' '), style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 9)),
          ),
        ],
      ),
    );
  }
}
