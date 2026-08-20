/// The goal-intake profile from `GET/PATCH /members/me/profile`.
/// Field names/enums match `UpdateMemberProfileDto` on the backend exactly.
class MemberProfile {
  final DateTime? dateOfBirth;
  final String? sex; // 'MALE' | 'FEMALE'
  final double? heightCm;
  final double? weightKg;
  final String? goal; // FitnessGoal enum
  final String? experienceLevel; // ExperienceLevel enum
  final String? dietaryPreference; // DietaryPreference enum
  final String? budgetBand; // BudgetBand enum
  final String? equipmentAccess; // EquipmentAccess enum
  final String? injuriesNotes;
  final String? weeklyFocus;
  final DateTime? onboardingCompletedAt;

  const MemberProfile({
    this.dateOfBirth,
    this.sex,
    this.heightCm,
    this.weightKg,
    this.goal,
    this.experienceLevel,
    this.dietaryPreference,
    this.budgetBand,
    this.equipmentAccess,
    this.injuriesNotes,
    this.weeklyFocus,
    this.onboardingCompletedAt,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    return MemberProfile(
      dateOfBirth: _tryParseDate(json['dateOfBirth']),
      sex: json['sex'] as String?,
      heightCm: _tryParseDouble(json['heightCm']),
      weightKg: _tryParseDouble(json['weightKg']),
      goal: json['goal'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      dietaryPreference: json['dietaryPreference'] as String?,
      budgetBand: json['budgetBand'] as String?,
      equipmentAccess: json['equipmentAccess'] as String?,
      injuriesNotes: json['injuriesNotes'] as String?,
      weeklyFocus: json['weeklyFocus'] as String?,
      onboardingCompletedAt: _tryParseDate(json['onboardingCompletedAt']),
    );
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int a = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      a--;
    }
    return a;
  }

  String get goalLabel => switch (goal) {
        'FAT_LOSS' => 'Fat Loss',
        'MUSCLE_GAIN' => 'Muscle Gain',
        'STRENGTH' => 'Strength',
        'SPORT_SPECIFIC' => 'Sport Specific',
        'GENERAL_FITNESS' => 'General Fitness',
        _ => 'Not set',
      };

  static DateTime? _tryParseDate(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }

  static double? _tryParseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
