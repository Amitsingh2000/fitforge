/// Represents a member join request.
/// Source: `GET /gyms/:gymId/join-requests`
class JoinRequest {
  final String id;
  final String membershipId;
  final String userId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String status; // PENDING_APPROVAL, APPROVED, REJECTED
  final DateTime requestedAt;
  final String? preferredTrainerName;
  final String? fitnessGoal;
  final String? age;
  final String? weight;

  const JoinRequest({
    required this.id,
    required this.membershipId,
    required this.userId,
    required this.firstName,
    this.lastName = '',
    this.email,
    this.phone,
    this.avatarUrl,
    this.status = 'PENDING_APPROVAL',
    required this.requestedAt,
    this.preferredTrainerName,
    this.fitnessGoal,
    this.age,
    this.weight,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic> ? json['user'] as Map<String, dynamic> : json;
    final profile = user['profile'] is Map<String, dynamic> ? user['profile'] as Map<String, dynamic> : {};

    return JoinRequest(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      membershipId: json['membershipId'] as String? ?? json['id'] as String? ?? '',
      userId: user['id'] as String? ?? user['userId'] as String? ?? '',
      firstName: user['firstName'] as String? ?? json['firstName'] as String? ?? 'Member',
      lastName: user['lastName'] as String? ?? json['lastName'] as String? ?? '',
      email: user['email'] as String? ?? json['email'] as String?,
      phone: user['phone'] as String? ?? json['phone'] as String?,
      avatarUrl: user['avatarUrl'] as String? ?? profile['photoUrl'] as String?,
      status: json['status'] as String? ?? 'PENDING_APPROVAL',
      requestedAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      preferredTrainerName: json['preferredTrainer'] as String? ?? json['preferredTrainerName'] as String?,
      fitnessGoal: profile['goal'] as String? ?? json['goal'] as String?,
      age: profile['age']?.toString() ?? json['age']?.toString(),
      weight: profile['weightKg']?.toString() ?? json['weight']?.toString(),
    );
  }
}
