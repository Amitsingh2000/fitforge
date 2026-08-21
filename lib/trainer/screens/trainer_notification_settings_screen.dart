import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trainer_profile.dart';
import '../../services/trainer_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/ambient_glow_background.dart';
import '../../dashboard/widgets/state_views.dart';

/// `PATCH /trainers/me/profile { mutedAlertTypes }` — suppresses alert types
/// on the trainer's own in-app feed. Was a "coming soon" toast despite the
/// backend already shipping this field.
class TrainerNotificationSettingsScreen extends ConsumerStatefulWidget {
  const TrainerNotificationSettingsScreen({super.key, required this.initial});
  final TrainerProfile initial;

  @override
  ConsumerState<TrainerNotificationSettingsScreen> createState() =>
      _TrainerNotificationSettingsScreenState();
}

class _TrainerNotificationSettingsScreenState
    extends ConsumerState<TrainerNotificationSettingsScreen> {
  static const _alertTypeLabels = {
    'TRAINER_NEW_MESSAGE': 'New messages from members',
    'TRAINER_NEW_CLIENT_ASSIGNED': 'New client assignments',
  };

  late Set<String> _mutedAlertTypes;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _mutedAlertTypes = Set.of(widget.initial.mutedAlertTypes);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(trainerServiceProvider).updateMyProfile(mutedAlertTypes: _mutedAlertTypes.toList());
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
        title: const Text('Notification Settings', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: Stack(
        children: [
          const AmbientGlowBackground(topColor: AppColors.accentBlue, bottomColor: null),
          SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Text(
              'Choose which alerts appear on your notification feed.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            ..._alertTypeLabels.entries.toList().asMap().entries.map((indexed) {
              final index = indexed.key;
              final entry = indexed.value;
              final isMuted = _mutedAlertTypes.contains(entry.key);
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: !isMuted,
                activeThumbColor: AppColors.accentBlue,
                title: Text(entry.value, style: AppTextStyles.bodyMedium.copyWith(fontSize: 14, color: AppColors.textPrimary)),
                onChanged: (enabled) => setState(() {
                  if (enabled) {
                    _mutedAlertTypes.remove(entry.key);
                  } else {
                    _mutedAlertTypes.add(entry.key);
                  }
                }),
              ).animate().fadeIn(duration: 350.ms, delay: Duration(milliseconds: index * 60));
            }),
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
                    : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
        ],
      ),
    );
  }
}
