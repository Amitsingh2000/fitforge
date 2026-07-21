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
    );
  }

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
    };
  }

  Map<String, dynamic> toBackendJson() {
    // Goal mapping
    String mappedGoal = 'GENERAL_FITNESS';
    if (goal == 'Lose Weight') mappedGoal = 'FAT_LOSS';
    if (goal == 'Build Muscle') mappedGoal = 'MUSCLE_GAIN';
    if (goal == 'Stay Fit') mappedGoal = 'GENERAL_FITNESS';
    if (goal == 'Improve Lifestyle') mappedGoal = 'GENERAL_FITNESS';

    // Sex mapping
    String mappedSex = 'MALE';
    if (gender == 'Female') mappedSex = 'FEMALE';

    // Date of Birth mapping from age
    final currentYear = DateTime.now().year;
    final birthYear = currentYear - age;
    final mappedDob = '$birthYear-01-01';

    // Experience mapping
    String mappedExp = 'BEGINNER';
    if (experience == 'Intermediate') mappedExp = 'INTERMEDIATE';
    if (experience == 'Advanced') mappedExp = 'ADVANCED';

    // Diet mapping
    String mappedDiet = 'NON_VEG';
    if (dietPreference == 'Vegetarian') mappedDiet = 'VEG';
    if (dietPreference == 'Vegan') mappedDiet = 'VEGAN';

    return {
      'goal': mappedGoal,
      'sex': mappedSex,
      'dateOfBirth': mappedDob,
      'heightCm': height,
      'weightKg': weight,
      'experienceLevel': mappedExp,
      'dietaryPreference': mappedDiet,
      // Add safe default fields required by the backend to pass validations
      'budgetBand': 'MEDIUM',
      'equipmentAccess': 'FULL_GYM',
      'weeklyFocus': 'Train 4x this week; hit targets daily.',
    };
  }
}
