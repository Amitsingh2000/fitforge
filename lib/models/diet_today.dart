class MacroTotals {
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const MacroTotals({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });

  factory MacroTotals.fromJson(Map<String, dynamic> json) {
    return MacroTotals(
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
    );
  }
}

class DietMealToday {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final bool checked;
  final List<Map<String, dynamic>> items;

  const DietMealToday({
    required this.id,
    required this.name,
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.checked = false,
    this.items = const [],
  });

  factory DietMealToday.fromJson(Map<String, dynamic> json) {
    return DietMealToday(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0,
      checked: json['checked'] as bool? ?? false,
      items: (json['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }
}

/// From `GET /members/me/diet/today`.
class DietToday {
  final String date;
  final String? planId;
  final MacroTotals targets;
  final MacroTotals consumed;
  final List<DietMealToday> meals;

  const DietToday({
    required this.date,
    this.planId,
    this.targets = const MacroTotals(),
    this.consumed = const MacroTotals(),
    this.meals = const [],
  });

  factory DietToday.fromJson(Map<String, dynamic> json) {
    return DietToday(
      date: json['date'] as String? ?? '',
      planId: json['planId'] as String?,
      targets: MacroTotals.fromJson(
        Map<String, dynamic>.from(json['targets'] as Map? ?? const {}),
      ),
      consumed: MacroTotals.fromJson(
        Map<String, dynamic>.from(json['consumed'] as Map? ?? const {}),
      ),
      meals: (json['meals'] as List? ?? [])
          .whereType<Map>()
          .map((e) => DietMealToday.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class DietMealCheckResult {
  final String mealId;
  final bool checked;
  final MacroTotals updatedConsumed;

  const DietMealCheckResult({
    required this.mealId,
    this.checked = false,
    this.updatedConsumed = const MacroTotals(),
  });

  factory DietMealCheckResult.fromJson(Map<String, dynamic> json) {
    return DietMealCheckResult(
      mealId: json['mealId'] as String? ?? '',
      checked: json['checked'] as bool? ?? false,
      updatedConsumed: MacroTotals.fromJson(
        Map<String, dynamic>.from(json['updatedConsumed'] as Map? ?? const {}),
      ),
    );
  }
}
