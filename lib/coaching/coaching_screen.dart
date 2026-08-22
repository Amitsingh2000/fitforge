import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../dashboard/widgets/dashboard_glass_card.dart';
import '../dashboard/widgets/member_async_value.dart';
import '../dashboard/widgets/state_views.dart';
import '../models/coaching_assignment.dart';
import '../providers/member_flow_providers.dart';
import '../services/coaching_service.dart';
import '../theme/app_theme.dart';

/// Online coaching assignment for individual premium members.
class CoachingScreen extends ConsumerWidget {
  const CoachingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachingAsync = ref.watch(coachingProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: MemberAsyncValue<CoachingAssignment?>(
                value: coachingAsync,
                loadingMessage: 'Loading your coach…',
                onRetry: () => ref.invalidate(coachingProvider),
                builder: (assignment) => _CoachingBody(
                  assignment: assignment,
                  onRequestSwitch: () => _requestSwitch(context, ref),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.bgTertiary,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Online Coaching',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Your assigned fitness coach',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestSwitch(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(coachingServiceProvider).requestSwitch();
      ref.invalidate(coachingProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Coach switch requested. We\'ll match you soon.'),
            backgroundColor: AppColors.accentBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyApiError(e))),
        );
      }
    }
  }
}

class _CoachingBody extends StatefulWidget {
  const _CoachingBody({
    required this.assignment,
    required this.onRequestSwitch,
  });

  final CoachingAssignment? assignment;
  final Future<void> Function() onRequestSwitch;

  @override
  State<_CoachingBody> createState() => _CoachingBodyState();
}

class _CoachingBodyState extends State<_CoachingBody> {
  bool _switchBusy = false;

  Future<void> _handleSwitch() async {
    if (_switchBusy) return;
    setState(() => _switchBusy = true);
    try {
      await widget.onRequestSwitch();
    } finally {
      if (mounted) setState(() => _switchBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    if (assignment == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: EmptyStateView(
            icon: Icons.person_search_rounded,
            title: 'No coach assigned yet',
            subtitle:
                'Complete premium checkout and we\'ll match you with a certified online coach.',
          ),
        ),
      );
    }

    final trainer = assignment.trainer;
    final name = trainer?.displayName.isNotEmpty == true
        ? trainer!.displayName
        : 'Your coach';
    final bio = trainer?.bio?.trim();
    final status = assignment.status;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      physics: const BouncingScrollPhysics(),
      children: [
        DashboardGlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 20,
          borderColor: AppColors.accentBlue.withValues(alpha: 0.25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentBlue.withValues(alpha: 0.08),
              AppColors.accentPurple.withValues(alpha: 0.04),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.bgTertiary,
                    backgroundImage: trainer?.avatarUrl != null
                        ? NetworkImage(trainer!.avatarUrl!)
                        : null,
                    child: trainer?.avatarUrl == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.accentBlue,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _StatusChip(status: status),
                      ],
                    ),
                  ),
                ],
              ),
              if (bio != null && bio.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'About',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  bio,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
              if (trainer != null && trainer.specializations.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: trainer.specializations
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Text(
                            s,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _switchBusy ? null : _handleSwitch,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_switchBusy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentBlue),
                  )
                else
                  const Icon(Icons.swap_horiz_rounded, color: AppColors.accentBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  _switchBusy ? 'Requesting…' : 'Request Coach Switch',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color get _color {
    return switch (status.toUpperCase()) {
      'ACTIVE' => const Color(0xFF22C55E),
      'PENDING' || 'SWITCH_REQUESTED' => AppColors.accentOrange,
      _ => AppColors.textTertiary,
    };
  }

  String get _label {
    return switch (status.toUpperCase()) {
      'ACTIVE' => 'Active',
      'PENDING' => 'Pending',
      'SWITCH_REQUESTED' => 'Switch requested',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Text(
        _label,
        style: AppTextStyles.caption.copyWith(
          color: _color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
