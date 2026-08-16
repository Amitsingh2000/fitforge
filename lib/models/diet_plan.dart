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

  const DietPlan({
    required this.id,
    this.gymId,
    this.memberId,
    this.status = 'DRAFT',
    this.title,
    this.description,
    this.createdAt,
    this.meals = const [],
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
    );
  }

  Map<String, dynamic> toCreatePayload({String? memberId}) {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (memberId != null) 'memberId': memberId,
      'meals': meals.map((m) => m.toJson()).toList(),
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      'status': status,
      'meals': meals.map((m) => m.toJson()).toList(),
    };
  }

  static DateTime? _date(dynamic v) => v is String ? DateTime.tryParse(v) : null;
}

/// One meal (Breakfast / Lunch / ...) inside a [DietPlan].
class Meal {
  final String name;
  final String? time;
  final String? note;
  final double? targetCalories;
  final List<FoodItem> items;

  const Meal({
    required this.name,
    this.time,
    this.note,
    this.targetCalories,
    this.items = const [],
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      name: json['name'] as String? ?? json['mealName'] as String? ?? '',
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
      'name': name,
      if (time != null) 'time': time,
      if (note != null) 'note': note,
      if (targetCalories != null) 'targetCalories': targetCalories,
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
      if (calories != null) 'calories': calories,
      if (proteinG != null) 'proteinG': proteinG,
      if (carbsG != null) 'carbsG': carbsG,
      if (fatG != null) 'fatG': fatG,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
    };
  }
}