import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gym_membership.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────
// Active gym context — every gym-scoped screen reads gymId from here
// ─────────────────────────────────────────────

/// The currently selected gym. Set after login if the user has gym memberships.
/// Screens use [currentGymIdProvider] for the gymId string.
final selectedGymProvider = StateProvider<GymMembership?>((ref) => null);

/// Convenience: the current user's full list of gym memberships.
final gymMembershipsProvider = Provider<List<GymMembership>>((ref) {
  final user = ref.watch(authProvider).user;
  return user?.gymMemberships ?? [];
});

/// Convenience: the gymId of the currently selected gym (or null).
final currentGymIdProvider = Provider<String?>((ref) {
  return ref.watch(selectedGymProvider)?.gymId;
});

/// Convenience: the membershipId at the currently selected gym (or null).
final currentMembershipIdProvider = Provider<String?>((ref) {
  return ref.watch(selectedGymProvider)?.membershipId;
});

/// Convenience: the GymRole at the currently selected gym (or null).
final currentGymRoleProvider = Provider<GymRole?>((ref) {
  return ref.watch(selectedGymProvider)?.role;
});

/// Auto-selects a gym after login/session-restore.
///
/// Call this once after the user object is available.
/// - >0 memberships → auto-select the first if nothing is selected yet, so
///   gym-scoped screens always have a gymId (a gym picker can override).
/// - 0 memberships  → leave null (join/create gym flow will set it)
void autoSelectGym(WidgetRef ref) {
  final memberships = ref.read(gymMembershipsProvider);
  if (memberships.isNotEmpty) {
    ref.read(selectedGymProvider.notifier).state ??= memberships.first;
  }
}

/// Variant for use inside a Ref context (e.g. inside a Notifier or Provider).
void autoSelectGymFromRef(Ref ref) {
  final user = ref.read(authProvider).user;
  final memberships = user?.gymMemberships ?? [];
  if (memberships.isNotEmpty) {
    ref.read(selectedGymProvider.notifier).state ??= memberships.first;
  }
}

/// Owner and trainer dashboards share this — auto-select pins the first gym.
Future<void> showGymSwitcherSheet(
  BuildContext context,
  WidgetRef ref, {
  VoidCallback? onSwitched,
}) async {
  final memberships = ref.read(gymMembershipsProvider);
  if (memberships.length < 2) return;
  final current = ref.read(selectedGymProvider);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.bgSecondary,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetCtx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text('Switch Gym',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...memberships.map((m) {
            final isCurrent = m.gymId == current?.gymId;
            return ListTile(
              leading: const Icon(Icons.fitness_center_rounded,
                  color: AppColors.accentBlue),
              title: Text(m.gymName ?? 'Unnamed Gym',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500)),
              trailing: isCurrent
                  ? const Icon(Icons.check_rounded, color: AppColors.accentCyan)
                  : null,
              onTap: () {
                Navigator.of(sheetCtx).pop();
                if (!isCurrent) {
                  ref.read(selectedGymProvider.notifier).state = m;
                  onSwitched?.call();
                }
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
