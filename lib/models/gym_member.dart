/// Represents a gym member record from `GET /gyms/:gymId/members`.
class GymMember {
  final String membershipId;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String role; // 'MEMBER', 'TRAINER', 'GYM_OWNER', 'FRONT_DESK'
  final String status; // 'ACTIVE', 'EXPIRED', 'FROZEN', 'PENDING'
  final String? planName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? assignedTrainerName;
  final String? assignedTrainerId;

  const GymMember({
    required this.membershipId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.role = 'MEMBER',
    this.status = 'ACTIVE',
    this.planName,
    this.startDate,
    this.endDate,
    this.assignedTrainerName,
    this.assignedTrainerId,
  });

  factory GymMember.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>? ?? {};
    final fName = json['firstName'] as String? ?? userMap['firstName'] as String? ?? '';
    final lName = json['lastName'] as String? ?? userMap['lastName'] as String? ?? '';
    final emailStr = json['email'] as String? ?? userMap['email'] as String? ?? '';

    return GymMember(
      membershipId: json['membershipId'] as String? ?? json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? userMap['id'] as String? ?? '',
      firstName: fName.isNotEmpty ? fName : 'Member',
      lastName: lName,
      email: emailStr,
      phone: json['phone'] as String? ?? userMap['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? userMap['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'MEMBER',
      status: json['status'] as String? ?? 'ACTIVE',
      planName: json['planName'] as String? ?? json['plan']?['name'] as String?,
      startDate: _tryParseDate(json['startDate']),
      endDate: _tryParseDate(json['endDate']),
      assignedTrainerName: json['assignedTrainerName'] as String? ?? json['trainer']?['name'] as String?,
      assignedTrainerId: json['assignedTrainerId'] as String? ?? json['trainer']?['id'] as String?,
    );
  }

  String get fullName => '$firstName $lastName'.trim();

  static DateTime? _tryParseDate(dynamic val) {
    if (val == null) return null;
    if (val is String) return DateTime.tryParse(val);
    return null;
  }
}
