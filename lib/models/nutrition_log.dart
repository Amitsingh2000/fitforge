/// One day's logged nutrition from `GET /gyms/:gymId/members/:userId/nutrition-logs`.
///
/// Food items are **freeform** — `foodName` + manually entered macros, no food
/// database autocomplete. Daily totals are derived client-side from items when
/// the backend doesn't send them (and simply read through when it does).
class NutritionLog {
  final String id;
  final DateTime? loggedAt;

  /// Meal label if the log is per-meal rather than a whole-day rollup
  /// (Breakfast / Lunch / ...).
  final String? mealType;

  final List<NutritionLogItem> items;

  /// Backend-supplied daily totals override item sums when present.
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  const NutritionLog({
    required this.id,
    this.loggedAt,
    this.mealType,
    this.items = const [],
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  double get totalCalories => calories ?? items.fold(0, (sum, i) => sum + (i.calories ?? 0));
  double get totalProteinG => proteinG ?? items.fold(0, (sum, i) => sum + (i.proteinG ?? 0));
  double get totalCarbsG => carbsG ?? items.fold(0, (sum, i) => sum + (i.carbsG ?? 0));
  double get totalFatG => fatG ?? items.fold(0, (sum, i) => sum + (i.fatG ?? 0));

  factory NutritionLog.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? json['foodItems'] as List?;
    return NutritionLog(
      id: json['id'] as String? ?? '',
      loggedAt: _date(json['loggedAt'] ?? json['loggedOn'] ?? json['date']),
      mealType: json['mealType'] as String?,
      items: (rawItems ?? [])
          .whereType<Map>()
          .map((e) => NutritionLogItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      calories: (json['totalCalories'] as num?)?.toDouble() ??
          (json['calories'] as num?)?.toDouble(),
      proteinG: (json['totalProteinG'] as num?)?.toDouble() ??
          (json['proteinG'] as num?)?.toDouble(),
      carbsG: (json['totalCarbsG'] as num?)?.toDouble() ??
          (json['carbsG'] as num?)?.toDouble(),
      fatG: (json['totalFatG'] as num?)?.toDouble() ??
          (json['fatG'] as num?)?.toDouble(),
    );
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}

/// A freeform food item (`foodName` + manually entered macros).
class NutritionLogItem {
  final String foodName;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  const NutritionLogItem({
    required this.foodName,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  factory NutritionLogItem.fromJson(Map<String, dynamic> json) {
    return NutritionLogItem(
      foodName: json['foodName'] as String? ?? json['name'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble(),
      proteinG: (json['proteinG'] as num?)?.toDouble(),
      carbsG: (json['carbsG'] as num?)?.toDouble(),
      fatG: (json['fatG'] as num?)?.toDouble(),
    );
  }
}