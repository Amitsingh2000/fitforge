import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gym_membership.dart';
import '../providers/auth_provider.dart';

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
/// - 1 membership  → auto-select
/// - 0 memberships → leave null (join/create gym flow will set it)
/// - >1 membership → leave null (a gym-picker will be shown)
void autoSelectGym(WidgetRef ref) {
  final memberships = ref.read(gymMembershipsProvider);
  if (memberships.length == 1) {
    ref.read(selectedGymProvider.notifier).state = memberships.first;
  }
}

/// Variant for use inside a Ref context (e.g. inside a Notifier or Provider).
void autoSelectGymFromRef(Ref ref) {
  final user = ref.read(authProvider).user;
  final memberships = user?.gymMemberships ?? [];
  if (memberships.length == 1) {
    ref.read(selectedGymProvider.notifier).state = memberships.first;
  }
}
