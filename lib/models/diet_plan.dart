/// A diet plan from `POST/PATCH /gyms/:gymId/diet-plans[/:id]`.
///
/// Food items are **freeform** — `foodName` + manual macros, no food database.
/// Daily macro totals still work; they're just never looked up from a catalog.
///
/// ⚠️ PATCH semantics: sending `meals[]` **replaces the entire meal/item tree**
/// (no partial diffing). Payload builders always emit the full current
/// structure.
class DietPlan {
  final String id;
  final String? gymId;
  final String? memberId;
  final String status;
  final String? title;
  final String? description;
  final DateTime? createdAt;
  final List<Meal> meals;

  /// Daily macro targets the trainer sets for this plan — read by the
  /// member/trainer UI as the real target instead of a hardcoded guess.
  final double? dailyCalorieTarget;
  final double? dailyProteinTargetG;
  final double? dailyCarbsTargetG;
  final double? dailyFatTargetG;

  const DietPlan({
    required this.id,
    this.gymId,
    this.memberId,
    this.status = 'DRAFT',
    this.title,
    this.description,
    this.createdAt,
    this.meals = const [],
    this.dailyCalorieTarget,
    this.dailyProteinTargetG,
    this.dailyCarbsTargetG,
    this.dailyFatTargetG,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      id: json['id'] as String? ?? '',
      gymId: json['gymId'] as String?,
      memberId: json['memberId'] as String?,
      status: json['status'] as String? ?? 'DRAFT',
      title: json['title'] as String? ?? json['name'] as String?,
      description: json['description'] as String?,
      createdAt: _date(json['createdAt']),
      meals: (json['meals'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Meal.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      dailyCalorieTarget: (json['dailyCalorieTarget'] as num?)?.toDouble(),
      dailyProteinTargetG: (json['dailyProteinTargetG'] as num?)?.toDouble(),
      dailyCarbsTargetG: (json['dailyCarbsTargetG'] as num?)?.toDouble(),
      dailyFatTargetG: (json['dailyFatTargetG'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toCreatePayload({String? memberId}) {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (memberId != null) 'memberId': memberId,
      if (dailyCalorieTarget != null) 'dailyCalorieTarget': dailyCalorieTarget,
      if (dailyProteinTargetG != null) 'dailyProteinTargetG': dailyProteinTargetG,
      if (dailyCarbsTargetG != null) 'dailyCarbsTargetG': dailyCarbsTargetG,
      if (dailyFatTargetG != null) 'dailyFatTargetG': dailyFatTargetG,
      'meals': meals.map((m) => m.toJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      'status': status,
      if (dailyCalorieTarget != null) 'dailyCalorieTarget': dailyCalorieTarget,
      if (dailyProteinTargetG != null) 'dailyProteinTargetG': dailyProteinTargetG,
      if (dailyCarbsTargetG != null) 'dailyCarbsTargetG': dailyCarbsTargetG,
      if (dailyFatTargetG != null) 'dailyFatTargetG': dailyFatTargetG,
      'meals': meals.map((m) => m.toJson()).toList(),
    };
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}

/// One meal (Breakfast / Lunch / ...) inside a [DietPlan].
class Meal {
  final String name;
  final int order;
  final String? time;
  final String? note;
  final double? targetCalories;
  final List<FoodItem> items;

  const Meal({
    required this.name,
    this.order = 0,
    this.time,
    this.note,
    this.targetCalories,
    this.items = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['mealSlot'] as String? ??
          json['name'] as String? ??
          json['mealName'] as String? ??
          '',
      order: (json['order'] as num?)?.toInt() ?? 0,
      time: json['time'] as String?,
      note: json['note'] as String?,
      targetCalories: (json['targetCalories'] as num?)?.toDouble(),
      items: (json['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => FoodItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mealSlot': name,
      'order': order,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

/// A freeform food item (`foodName` + manual macros).
class FoodItem {
  final String foodName;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? quantity;
  final String? unit;

  const FoodItem({
    required this.foodName,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.quantity,
    this.unit,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      foodName: json['foodName'] as String? ?? json['name'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble(),
      proteinG: (json['proteinG'] as num?)?.toDouble(),
      carbsG: (json['carbsG'] as num?)?.toDouble(),
      fatG: (json['fatG'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      if (unit != null || quantity != null)
        'portion': [quantity?.toString(), unit].whereType<String>().join(' ').trim(),
      if (calories != null) 'calories': calories!.round(),
      if (proteinG != null) 'proteinG': proteinG!.round(),
      if (carbsG != null) 'carbsG': carbsG!.round(),
      if (fatG != null) 'fatG': fatG!.round(),
    };
  }
}