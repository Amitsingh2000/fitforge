import 'gym_membership.dart';

enum UserRole { client, trainer, gymOwner, frontDesk }

class User {
  final String id;
  final String email;
  final String name;
  final String firstName;
  final String lastName;
  final UserRole role;
  final String? token;
  final String? avatarUrl;
  final String? phone;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final bool isSuperAdmin;
  final DateTime? createdAt;
  final List<GymMembership> gymMemberships;

  /// Whether this user has ever started the member goal-intake profile
  /// (`memberProfile` is non-null on the backend once any field is saved).
  /// `false` for a brand-new registrant who hasn't touched onboarding yet.
  final bool hasMemberProfile;

  /// Whether `POST /members/me/complete-onboarding` has been called —
  /// drives whether a standalone member is routed into the onboarding
  /// wizard or straight to their dashboard on app start/login.
  final bool isOnboardingComplete;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.firstName = '',
    this.lastName = '',
    required this.role,
    this.token,
    this.avatarUrl,
    this.phone,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.isSuperAdmin = false,
    this.createdAt,
    this.gymMemberships = const [],
    this.hasMemberProfile = false,
    this.isOnboardingComplete = false,
  });

  /// Formatted "Member Since" string, e.g. "July 2026"
  String get memberSince {
    if (createdAt == null) return 'Unknown';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[createdAt!.month - 1]} ${createdAt!.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'token': token,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? 'User',
      role: UserRole.values.byName(json['role'] as String? ?? 'client'),
      token: json['token'] as String?,
    );
  }

  factory User.fromBackendJson(Map<String, dynamic> json, {String? token}) {
    final membershipsRaw = json['gymMemberships'] as List?;
    UserRole parsedRole = UserRole.client;

    // Parse the full gym-membership objects (§2 — preserve gymId etc.)
    final List<GymMembership> parsedMemberships = membershipsRaw
            ?.map((m) =>
                GymMembership.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList() ??
        [];

    // Derive the top-level role from the richest membership (existing logic,
    // now also handles FRONT_DESK)
    if (membershipsRaw != null) {
      for (var m in membershipsRaw) {
        final roleStr = m['role'] as String?;
        if (roleStr == 'GYM_OWNER' || roleStr == 'GYM_MANAGER') {
          parsedRole = UserRole.gymOwner;
          break;
        } else if (roleStr == 'FRONT_DESK') {
          parsedRole = UserRole.frontDesk;
          break;
        } else if (roleStr == 'TRAINER') {
          parsedRole = UserRole.trainer;
          break;
        }
      }
    }

    // Double-check platform admin
    if (json['isSuperAdmin'] == true) {
      parsedRole = UserRole.gymOwner;
    }

    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final fullName = '$firstName $lastName'.trim();
    final displayName = fullName.isNotEmpty
        ? fullName
        : (json['fullName'] as String? ?? json['name'] as String? ?? 'User');

    DateTime? createdAt;
    final createdAtStr = json['createdAt'] as String?;
    if (createdAtStr != null) {
      createdAt = DateTime.tryParse(createdAtStr);
    }

    final memberProfile = json['memberProfile'] as Map<String, dynamic>?;

    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: displayName,
      firstName: firstName,
      lastName: lastName,
      role: parsedRole,
      token: token,
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isPhoneVerified: json['isPhoneVerified'] as bool? ?? false,
      isSuperAdmin: json['isSuperAdmin'] as bool? ?? false,
      createdAt: createdAt,
      gymMemberships: parsedMemberships,
      hasMemberProfile: memberProfile != null,
      isOnboardingComplete: memberProfile?['onboardingCompletedAt'] != null,
    );
  }
}
