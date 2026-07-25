/// Roles a user can hold within a specific gym.
///
/// Maps 1-to-1 with the backend's per-gym role strings:
///   GYM_OWNER, GYM_MANAGER, FRONT_DESK, TRAINER, MEMBER
enum GymRole { gymOwner, gymManager, frontDesk, trainer, member }

/// One entry from `GET /users/me → gymMemberships[]`.
///
/// Represents a user's association with a single gym, including their role
/// at that gym and the membership record ID needed for gym-scoped API calls.
class GymMembership {
  final String gymId;
  final String? gymName;
  final GymRole role;
  final String membershipId;
  final String status; // 'ACTIVE', 'INACTIVE', etc.

  const GymMembership({
    required this.gymId,
    this.gymName,
    required this.role,
    required this.membershipId,
    this.status = 'ACTIVE',
  });

  /// Parse a single gym-membership object from the `/users/me` response.
  factory GymMembership.fromJson(Map<String, dynamic> json) {
    return GymMembership(
      gymId: json['gymId'] as String? ?? '',
      gymName: json['gymName'] as String?,
      role: _parseGymRole(json['role'] as String?),
      membershipId: json['membershipId'] as String? ??
          json['id'] as String? ??
          '',
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() => {
        'gymId': gymId,
        'gymName': gymName,
        'role': role.name,
        'membershipId': membershipId,
        'status': status,
      };

  /// Whether this membership grants staff-level access (gym owner screens).
  bool get isStaff =>
      role == GymRole.gymOwner ||
      role == GymRole.gymManager ||
      role == GymRole.frontDesk;

  /// Whether this membership grants owner/manager-level access.
  bool get isOwnerOrManager =>
      role == GymRole.gymOwner || role == GymRole.gymManager;

  static GymRole _parseGymRole(String? raw) {
    switch (raw) {
      case 'GYM_OWNER':
        return GymRole.gymOwner;
      case 'GYM_MANAGER':
        return GymRole.gymManager;
      case 'FRONT_DESK':
        return GymRole.frontDesk;
      case 'TRAINER':
        return GymRole.trainer;
      case 'MEMBER':
      default:
        return GymRole.member;
    }
  }
}
