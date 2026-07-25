class OnboardingState {
  final String? goal;
  final String gender;
  final int age;
  final int height;
  final int weight;
  final String? activityLevel;
  final String? dietPreference;
  final String? experience;
  final String? sleepSchedule;
  final String? equipmentAccess;
  final String? budgetBand;

  const OnboardingState({
    this.goal,
    this.gender = 'Male',
    this.age = 25,
    this.height = 170,
    this.weight = 70,
    this.activityLevel,
    this.dietPreference,
    this.experience,
    this.sleepSchedule,
    this.equipmentAccess,
    this.budgetBand,
  });

  OnboardingState copyWith({
    String? goal,
    String? gender,
    int? age,
    int? height,
    int? weight,
    String? activityLevel,
    String? dietPreference,
    String? experience,
    String? sleepSchedule,
    String? equipmentAccess,
    String? budgetBand,
  }) {
    return OnboardingState(
      goal: goal ?? this.goal,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
      dietPreference: dietPreference ?? this.dietPreference,
      experience: experience ?? this.experience,
      sleepSchedule: sleepSchedule ?? this.sleepSchedule,
      equipmentAccess: equipmentAccess ?? this.equipmentAccess,
      budgetBand: budgetBand ?? this.budgetBand,
    );
  }

  /// Whether every backend-required field has been collected — mirrors what
  /// `POST /members/me/complete-onboarding` itself checks, so the UI can
  /// gate the final step accurately instead of discovering gaps from a 400.
  bool get isCompleteForBackend =>
      goal != null &&
      experience != null &&
      dietPreference != null &&
      equipmentAccess != null &&
      budgetBand != null;

  // Dynamic calculations moved from FinalScreen

  int get dailyCalories {
    double bmr;
    if (gender == 'Male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    final activity = activityLevel ?? 'Moderate';
    double factor;
    switch (activity) {
      case 'Sedentary':
        factor = 1.2;
        break;
      case 'Light':
        factor = 1.375;
        break;
      case 'Active':
        factor = 1.725;
        break;
      case 'Very Active':
        factor = 1.9;
        break;
      default:
        factor = 1.55;
    }

    final activeGoal = goal ?? 'Stay Fit';
    int adjustment = 0;
    if (activeGoal == 'Lose Weight') adjustment = -300;
    if (activeGoal == 'Build Muscle') adjustment = 250;

    return (bmr * factor + adjustment).round();
  }

  int get protein {
    final activeGoal = goal ?? 'Stay Fit';
    if (activeGoal == 'Build Muscle') return (weight * 2.0).round();
    if (activeGoal == 'Lose Weight') return (weight * 1.8).round();
    return (weight * 1.6).round();
  }

  int get carbs {
    return (dailyCalories * 0.45 / 4).round();
  }

  double get water {
    return (weight * 0.033 * 10).roundToDouble() / 10;
  }

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'gender': gender,
      'age': age,
      'height': height,
      'weight': weight,
      'activityLevel': activityLevel,
      'dietPreference': dietPreference,
      'experience': experience,
      'sleepSchedule': sleepSchedule,
      'equipmentAccess': equipmentAccess,
      'budgetBand': budgetBand,
    };
  }

  /// Maps to `UpdateMemberProfileDto` — used for progressive per-step PATCHes
  /// as well as the final submit. Only includes fields the user has actually
  /// set (plus the always-present numeric fields, which carry sane defaults
  /// even before the user touches them) — never fabricates values for fields
  /// with no real default, so a partial wizard produces a partial PATCH
  /// instead of silently writing made-up data.
  Map<String, dynamic> toBackendJson() {
    final json = <String, dynamic>{
      'sex': gender == 'Female' ? 'FEMALE' : 'MALE',
      'dateOfBirth': '${DateTime.now().year - age}-01-01',
      'heightCm': height,
      'weightKg': weight,
    };

    if (goal != null) {
      json['goal'] = switch (goal) {
        'Lose Weight' => 'FAT_LOSS',
        'Build Muscle' => 'MUSCLE_GAIN',
        'Stay Fit' => 'GENERAL_FITNESS',
        'Improve Lifestyle' => 'GENERAL_FITNESS',
        _ => 'GENERAL_FITNESS',
      };
    }

    if (experience != null) {
      json['experienceLevel'] = switch (experience) {
        'Intermediate' => 'INTERMEDIATE',
        'Advanced' => 'ADVANCED',
        _ => 'BEGINNER',
      };
    }

    if (dietPreference != null) {
      json['dietaryPreference'] = switch (dietPreference) {
        'Vegetarian' => 'VEG',
        'Vegan' => 'VEGAN',
        _ => 'NON_VEG',
      };
    }

    if (equipmentAccess != null) {
      json['equipmentAccess'] = switch (equipmentAccess) {
        'Home Equipment' => 'HOME_EQUIPMENT',
        'No Equipment' => 'NO_EQUIPMENT',
        _ => 'FULL_GYM',
      };
    }

    if (budgetBand != null) {
      json['budgetBand'] = switch (budgetBand) {
        'Low' => 'LOW',
        'High' => 'HIGH',
        _ => 'MEDIUM',
      };
    }

    return json;
  }
}
