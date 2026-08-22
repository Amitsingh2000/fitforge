import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/food_item.dart';
import 'api_client.dart';
import 'api_data.dart';

/// Nutrition API — food catalog, custom meals, AI generation.
class NutritionService {
  final Dio dio;
  NutritionService(this.dio);

  Future<PaginatedFoodItems> listFoodItems({
    String? search,
    String? category,
    int page = 1,
    int limit = 50,
  }) async {
    final res = await dio.get('/food-items', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (category != null && category.isNotEmpty) 'category': category,
      'page': page,
      'limit': limit,
    });
    return PaginatedFoodItems.fromJson(asMap(res.data));
  }

  Future<Map<String, dynamic>> createCustomMeal({
    required String name,
    required List<Map<String, dynamic>> items,
    bool logToToday = true,
    String? mealSlot,
    String? date,
  }) async {
    final res = await dio.post('/members/me/diet/meals', data: {
      'name': name,
      'items': items,
      'logToToday': logToToday,
      if (mealSlot != null) 'mealSlot': mealSlot,
      if (date != null) 'date': date,
    });
    return asMap(res.data);
  }

  Future<AiMealGenerationResult> generateMeals({
    required int remainingCalories,
    required int remainingProtein,
    required int remainingCarbs,
    required int remainingFat,
    String? dietaryPreference,
    String? budgetBand,
    int maxSuggestions = 2,
  }) async {
    final res = await dio.post('/members/me/ai/generate-meals', data: {
      'remainingCalories': remainingCalories,
      'remainingProtein': remainingProtein,
      'remainingCarbs': remainingCarbs,
      'remainingFat': remainingFat,
      if (dietaryPreference != null) 'dietaryPreference': dietaryPreference,
      if (budgetBand != null) 'budgetBand': budgetBand,
      'maxSuggestions': maxSuggestions,
    });
    return AiMealGenerationResult.fromJson(asMap(res.data));
  }
}

final nutritionServiceProvider = Provider<NutritionService>((ref) {
  return NutritionService(ref.watch(dioProvider));
});
