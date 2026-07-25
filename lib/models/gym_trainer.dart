/// Represents a trainer in a gym from `GET /gyms/:gymId/dashboard/trainers` or `GET /gyms/:gymId/members?role=TRAINER`.
class GymTrainer {
  final String trainerId;
  final String membershipId;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String specialization;
  final int activeClientsCount;
  final String status; // 'ACTIVE', 'INACTIVE'

  const GymTrainer({
    required this.trainerId,
    required this.membershipId,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    this.specialization = 'General Trainer',
    this.activeClientsCount = 0,
    this.status = 'ACTIVE',
  });

  factory GymTrainer.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>? ?? {};
    final fName = json['firstName'] as String? ?? userMap['firstName'] as String? ?? '';
    final lName = json['lastName'] as String? ?? userMap['lastName'] as String? ?? '';
    final full = '$fName $lName'.trim();
    final displayName = full.isNotEmpty
        ? full
        : (json['name'] as String? ?? userMap['fullName'] as String? ?? 'Trainer');

    return GymTrainer(
      trainerId: json['trainerId'] as String? ?? json['userId'] as String? ?? userMap['id'] as String? ?? '',
      membershipId: json['membershipId'] as String? ?? json['id'] as String? ?? '',
      name: displayName,
      email: json['email'] as String? ?? userMap['email'] as String?,
      phone: json['phone'] as String? ?? userMap['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? userMap['avatarUrl'] as String?,
      specialization: json['specialization'] as String? ?? json['spec'] as String? ?? 'Fitness Trainer',
      activeClientsCount: json['activeClientsCount'] as int? ?? json['clientsCount'] as int? ?? json['assignedClients'] as int? ?? 0,
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }
}
