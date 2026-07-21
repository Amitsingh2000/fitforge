enum UserRole { client, trainer, gymOwner }

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? token;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.token,
  });

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

    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: displayName,
      role: parsedRole,
      token: token,
    );
  }
}
