enum UserRole { client, trainer, gymOwner }

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
    final memberships = json['gymMemberships'] as List?;
    UserRole parsedRole = UserRole.client;

    if (memberships != null) {
      for (var m in memberships) {
        final roleStr = m['role'] as String?;
        if (roleStr == 'GYM_OWNER' || roleStr == 'GYM_MANAGER') {
          parsedRole = UserRole.gymOwner;
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
    );
  }
}
