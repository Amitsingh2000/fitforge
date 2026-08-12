/// A pending member join request from `GET /gyms/:gymId/join-requests`.
class JoinRequest {
  final String membershipId;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final DateTime? requestedAt;

  const JoinRequest({
    required this.membershipId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.requestedAt,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>? ?? {};
    final fName = userMap['firstName'] as String? ?? '';
    final lName = userMap['lastName'] as String? ?? '';

    return JoinRequest(
      membershipId: json['id'] as String? ?? '',
      userId: userMap['id'] as String? ?? '',
      firstName: fName.isNotEmpty ? fName : 'Member',
      lastName: lName,
      email: userMap['email'] as String? ?? '',
      phone: userMap['phone'] as String?,
      avatarUrl: userMap['avatarUrl'] as String?,
      requestedAt: _tryParseDate(json['joinedAt']),
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    final combined = '$f$l'.toUpperCase();
    return combined.isNotEmpty ? combined : '?';
  }

  static DateTime? _tryParseDate(dynamic val) {
    if (val is String) return DateTime.tryParse(val);
    return null;
  }
}
