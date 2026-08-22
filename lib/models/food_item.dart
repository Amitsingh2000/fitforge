/// Food catalog item from `GET /food-items`.
class FoodItem {
  final String id;
  final String name;
  final String? category;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String? servingUnit;

  const FoodItem({
    required this.id,
    required this.name,
    this.category,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.servingUnit,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String?,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0,
      servingUnit: json['servingUnit'] as String?,
    );
  }
}

class AiMealSuggestion {
  final String name;
  final int calories;
  final int proteinG;
  final int carbsG;
  final int fatG;
  final List<String> items;

  const AiMealSuggestion({
    required this.name,
    this.calories = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.items = const [],
  });

  factory AiMealSuggestion.fromJson(Map<String, dynamic> json) {
    return AiMealSuggestion(
      name: json['name'] as String? ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toInt() ?? 0,
      carbsG: (json['carbsG'] as num?)?.toInt() ?? 0,
      fatG: (json['fatG'] as num?)?.toInt() ?? 0,
      items: (json['items'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

class AiMealGenerationResult {
  final String provider;
  final String date;
  final List<AiMealSuggestion> suggestions;

  const AiMealGenerationResult({
    required this.provider,
    required this.date,
    this.suggestions = const [],
  });

  factory AiMealGenerationResult.fromJson(Map<String, dynamic> json) {
    return AiMealGenerationResult(
      provider: json['provider'] as String? ?? '',
      date: json['date'] as String? ?? '',
      suggestions: (json['suggestions'] as List? ?? [])
          .whereType<Map>()
          .map((e) => AiMealSuggestion.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class PaginatedFoodItems {
  final List<FoodItem> items;
  final int total;
  final int page;
  final int limit;

  const PaginatedFoodItems({
    this.items = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 20,
  });

  factory PaginatedFoodItems.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map?;
    return PaginatedFoodItems(
      items: (json['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => FoodItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: (meta?['total'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ??
          0,
      page: (meta?['page'] as num?)?.toInt() ??
          (json['page'] as num?)?.toInt() ??
          1,
      limit: (meta?['limit'] as num?)?.toInt() ??
          (json['limit'] as num?)?.toInt() ??
          20,
    );
  }
}
