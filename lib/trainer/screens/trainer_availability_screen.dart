import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trainer_profile.dart';
import '../../services/trainer_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/ambient_glow_background.dart';
import '../../dashboard/widgets/state_views.dart';

/// `PATCH /trainers/me/profile { availability }` — same 7-day
/// isClosed/opensAt/closesAt shape as the gym's own working-hours editor.
class TrainerAvailabilityScreen extends ConsumerStatefulWidget {
  const TrainerAvailabilityScreen({super.key, required this.initial});
  final TrainerProfile initial;

  @override
  ConsumerState<TrainerAvailabilityScreen> createState() => _TrainerAvailabilityScreenState();
}

class _TrainerAvailabilityScreenState extends ConsumerState<TrainerAvailabilityScreen> {
  static const _weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  late List<Map<String, dynamic>> _availability;
  bool _saving = false;
  String? _error;

  List<Map<String, dynamic>> _defaults() => _weekDays
      .map((d) => {'day': d, 'isClosed': false, 'opensAt': '09:00', 'closesAt': '18:00'})
      .toList();

  @override
  void initState() {
    super.initState();
    final existing = widget.initial.availability;
    _availability = (existing != null && existing.isNotEmpty)
        ? existing.map((e) => Map<String, dynamic>.from(e)).toList()
        : _defaults();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(trainerServiceProvider).updateMyProfile(availability: _availability);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = friendlyApiError(e); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Availability', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: Stack(
        children: [
          const AmbientGlowBackground(bottomColor: null),
          SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              'Set the hours you\'re available to train — shown to clients booking a session.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < _availability.length; i++)
              _buildDayRow(i).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: i * 30)),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentCoral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.3)),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.accentCoral, fontSize: 13)),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Save Availability', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }

  Widget _buildDayRow(int index) {
    final day = _availability[index];
    final isClosed = day['isClosed'] as bool? ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            SizedBox(width: 40, child: Text(day['day'] as String, style: AppTextStyles.labelLarge.copyWith(fontSize: 12, fontWeight: FontWeight.w700))),
            Expanded(
              child: isClosed
                  ? Text('Unavailable', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary))
                  : Row(
                      children: [
                        Expanded(child: _timeField(day, 'opensAt', index)),
                        const SizedBox(width: 8),
                        const Text('–', style: TextStyle(color: AppColors.textTertiary)),
                        const SizedBox(width: 8),
                        Expanded(child: _timeField(day, 'closesAt', index)),
                      ],
                    ),
            ),
            Switch(
              value: !isClosed,
              activeThumbColor: AppColors.accentBlue,
              onChanged: (available) => setState(() => _availability[index]['isClosed'] = !available),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeField(Map<String, dynamic> day, String key, int index) {
    return GestureDetector(
      onTap: () async {
        final current = (day[key] as String? ?? '09:00').split(':');
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.tryParse(current[0]) ?? 9,
            minute: int.tryParse(current.length > 1 ? current[1] : '0') ?? 0,
          ),
        );
        if (picked != null) {
          setState(() {
            _availability[index][key] =
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          day[key] as String? ?? '--:--',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
        ),
      ),
    );
  }
}
