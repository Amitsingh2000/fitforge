import 'package:flutter/material.dart';
import '../theme/brilliant_theme.dart';

/// Data model for a single food item in the catalog.
class FoodItem {
  final String name;
  final String emoji;
  final String category;
  final int caloriesPerServing;
  final int proteinPerServing;
  final int carbsPerServing;
  final int fatPerServing;
  final String servingSize;

  const FoodItem({
    required this.name,
    required this.emoji,
    required this.category,
    required this.caloriesPerServing,
    required this.proteinPerServing,
    required this.carbsPerServing,
    required this.fatPerServing,
    required this.servingSize,
  });
}

/// Data model for a cart entry (food item + quantity).
class CartEntry {
  final FoodItem item;
  int quantity;

  CartEntry({required this.item, this.quantity = 1});

  int get totalCalories => item.caloriesPerServing * quantity;
  int get totalProtein => item.proteinPerServing * quantity;
  int get totalCarbs => item.carbsPerServing * quantity;
  int get totalFat => item.fatPerServing * quantity;
}

/// Meal Builder Screen — full-screen cart-based meal customization inspired by Brilliant.org wizard.
class MealBuilderScreen extends StatefulWidget {
  final int remainingCalories;
  final int remainingProtein;
  final int remainingCarbs;
  final int remainingFats;
  final int totalCaloriesTarget;
  final int totalProteinTarget;
  final int totalCarbsTarget;
  final int totalFatsTarget;

  const MealBuilderScreen({
    super.key,
    required this.remainingCalories,
    required this.remainingProtein,
    required this.remainingCarbs,
    required this.remainingFats,
    required this.totalCaloriesTarget,
    required this.totalProteinTarget,
    required this.totalCarbsTarget,
    required this.totalFatsTarget,
  });

  @override
  State<MealBuilderScreen> createState() => _MealBuilderScreenState();
}

class _MealBuilderScreenState extends State<MealBuilderScreen>
    with TickerProviderStateMixin {
  // ── Categories ──
  static const List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'emoji': '🍽️', 'color': BrilliantColors.mint},
    {'name': 'Proteins', 'emoji': '🥩', 'color': BrilliantColors.coral},
    {'name': 'Grains', 'emoji': '🌾', 'color': BrilliantColors.amber},
    {'name': 'Vegetables', 'emoji': '🥦', 'color': BrilliantColors.green},
    {'name': 'Fruits', 'emoji': '🍎', 'color': BrilliantColors.purple},
    {'name': 'Dairy', 'emoji': '🥛', 'color': BrilliantColors.blue},
    {'name': 'Snacks', 'emoji': '🥜', 'color': Color(0xFFEAB308)},
  ];

  // ── Food Catalog ──
  static const List<FoodItem> _foodCatalog = [
    // Proteins
    FoodItem(name: 'Grilled Chicken', emoji: '🍗', category: 'Proteins', caloriesPerServing: 165, proteinPerServing: 31, carbsPerServing: 0, fatPerServing: 4, servingSize: '100g'),
    FoodItem(name: 'Boiled Eggs', emoji: '🥚', category: 'Proteins', caloriesPerServing: 155, proteinPerServing: 13, carbsPerServing: 1, fatPerServing: 11, servingSize: '2 eggs'),
    FoodItem(name: 'Paneer', emoji: '🧀', category: 'Proteins', caloriesPerServing: 265, proteinPerServing: 18, carbsPerServing: 1, fatPerServing: 21, servingSize: '100g'),
    FoodItem(name: 'Tofu', emoji: '🫘', category: 'Proteins', caloriesPerServing: 76, proteinPerServing: 8, carbsPerServing: 2, fatPerServing: 5, servingSize: '100g'),
    FoodItem(name: 'Fish Fillet', emoji: '🐟', category: 'Proteins', caloriesPerServing: 206, proteinPerServing: 22, carbsPerServing: 0, fatPerServing: 12, servingSize: '100g'),
    FoodItem(name: 'Whey Protein', emoji: '🥤', category: 'Proteins', caloriesPerServing: 120, proteinPerServing: 24, carbsPerServing: 3, fatPerServing: 1, servingSize: '1 scoop'),
    // Grains
    FoodItem(name: 'Brown Rice', emoji: '🍚', category: 'Grains', caloriesPerServing: 216, proteinPerServing: 5, carbsPerServing: 45, fatPerServing: 2, servingSize: '1 cup'),
    FoodItem(name: 'Oats', emoji: '🥣', category: 'Grains', caloriesPerServing: 154, proteinPerServing: 5, carbsPerServing: 27, fatPerServing: 3, servingSize: '1/2 cup'),
    FoodItem(name: 'Whole Wheat Roti', emoji: '🫓', category: 'Grains', caloriesPerServing: 120, proteinPerServing: 4, carbsPerServing: 22, fatPerServing: 2, servingSize: '1 roti'),
    FoodItem(name: 'Quinoa', emoji: '🌿', category: 'Grains', caloriesPerServing: 222, proteinPerServing: 8, carbsPerServing: 39, fatPerServing: 4, servingSize: '1 cup'),
    // Vegetables
    FoodItem(name: 'Broccoli', emoji: '🥦', category: 'Vegetables', caloriesPerServing: 55, proteinPerServing: 4, carbsPerServing: 11, fatPerServing: 1, servingSize: '1 cup'),
    FoodItem(name: 'Spinach', emoji: '🥬', category: 'Vegetables', caloriesPerServing: 23, proteinPerServing: 3, carbsPerServing: 4, fatPerServing: 0, servingSize: '1 cup'),
    FoodItem(name: 'Sweet Potato', emoji: '🍠', category: 'Vegetables', caloriesPerServing: 103, proteinPerServing: 2, carbsPerServing: 24, fatPerServing: 0, servingSize: '1 medium'),
    FoodItem(name: 'Mixed Salad', emoji: '🥗', category: 'Vegetables', caloriesPerServing: 45, proteinPerServing: 2, carbsPerServing: 8, fatPerServing: 1, servingSize: '1 bowl'),
    // Fruits
    FoodItem(name: 'Banana', emoji: '🍌', category: 'Fruits', caloriesPerServing: 105, proteinPerServing: 1, carbsPerServing: 27, fatPerServing: 0, servingSize: '1 medium'),
    FoodItem(name: 'Apple', emoji: '🍎', category: 'Fruits', caloriesPerServing: 95, proteinPerServing: 0, carbsPerServing: 25, fatPerServing: 0, servingSize: '1 medium'),
    FoodItem(name: 'Mixed Berries', emoji: '🫐', category: 'Fruits', caloriesPerServing: 70, proteinPerServing: 1, carbsPerServing: 17, fatPerServing: 0, servingSize: '1 cup'),
    FoodItem(name: 'Mango', emoji: '🥭', category: 'Fruits', caloriesPerServing: 99, proteinPerServing: 1, carbsPerServing: 25, fatPerServing: 1, servingSize: '1 cup'),
    // Dairy
    FoodItem(name: 'Greek Yogurt', emoji: '🥛', category: 'Dairy', caloriesPerServing: 100, proteinPerServing: 17, carbsPerServing: 6, fatPerServing: 1, servingSize: '170g'),
    FoodItem(name: 'Whole Milk', emoji: '🥛', category: 'Dairy', caloriesPerServing: 149, proteinPerServing: 8, carbsPerServing: 12, fatPerServing: 8, servingSize: '1 cup'),
    FoodItem(name: 'Cottage Cheese', emoji: '🧀', category: 'Dairy', caloriesPerServing: 206, proteinPerServing: 28, carbsPerServing: 6, fatPerServing: 9, servingSize: '1 cup'),
    // Snacks
    FoodItem(name: 'Almonds', emoji: '🌰', category: 'Snacks', caloriesPerServing: 164, proteinPerServing: 6, carbsPerServing: 6, fatPerServing: 14, servingSize: '1 oz'),
    FoodItem(name: 'Protein Bar', emoji: '🍫', category: 'Snacks', caloriesPerServing: 200, proteinPerServing: 20, carbsPerServing: 22, fatPerServing: 7, servingSize: '1 bar'),
    FoodItem(name: 'Peanut Butter', emoji: '🥜', category: 'Snacks', caloriesPerServing: 188, proteinPerServing: 8, carbsPerServing: 6, fatPerServing: 16, servingSize: '2 tbsp'),
  ];

  int _selectedCategoryIndex = 0;
  final List<CartEntry> _cart = [];
  bool _hasShownCelebration = false;

  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  int get _cartCalories => _cart.fold(0, (s, e) => s + e.totalCalories);
  int get _cartProtein => _cart.fold(0, (s, e) => s + e.totalProtein);
  int get _cartCarbs => _cart.fold(0, (s, e) => s + e.totalCarbs);
  int get _cartFat => _cart.fold(0, (s, e) => s + e.totalFat);
  int get _totalCartItems => _cart.fold(0, (s, e) => s + e.quantity);

  bool get _targetsMet =>
      _cartCalories >= widget.remainingCalories &&
      _cartProtein >= widget.remainingProtein &&
      _cartCarbs >= widget.remainingCarbs &&
      _cartFat >= widget.remainingFats;

  List<FoodItem> get _filteredItems {
    final category = _categories[_selectedCategoryIndex]['name'] as String;
    List<FoodItem> list;
    if (category == 'All') {
      list = List.from(_foodCatalog);
    } else {
      list = _foodCatalog.where((f) => f.category == category).toList();
    }

    final remProt = (widget.remainingProtein - _cartProtein).clamp(0, widget.remainingProtein);
    final remCarb = (widget.remainingCarbs - _cartCarbs).clamp(0, widget.remainingCarbs);
    final remFat = (widget.remainingFats - _cartFat).clamp(0, widget.remainingFats);

    final double totalRem = (remProt + remCarb + remFat).toDouble();
    if (totalRem > 0) {
      final double pWeight = remProt / totalRem;
      final double cWeight = remCarb / totalRem;
      final double fWeight = remFat / totalRem;

      list.sort((a, b) {
        final double scoreA = (a.proteinPerServing * pWeight) + (a.carbsPerServing * cWeight) + (a.fatPerServing * fWeight);
        final double scoreB = (b.proteinPerServing * pWeight) + (b.carbsPerServing * cWeight) + (b.fatPerServing * fWeight);
        return scoreB.compareTo(scoreA);
      });
    }
    return list;
  }

  int _getCartQuantity(FoodItem item) {
    final entry = _cart.where((e) => e.item.name == item.name).firstOrNull;
    return entry?.quantity ?? 0;
  }

  void _addToCart(FoodItem item) {
    setState(() {
      final existing = _cart.where((e) => e.item.name == item.name).firstOrNull;
      if (existing != null) {
        existing.quantity++;
      } else {
        _cart.add(CartEntry(item: item));
      }
    });
    _checkTargets();
  }

  void _removeFromCart(FoodItem item) {
    setState(() {
      final existing = _cart.where((e) => e.item.name == item.name).firstOrNull;
      if (existing != null) {
        if (existing.quantity > 1) {
          existing.quantity--;
        } else {
          _cart.removeWhere((e) => e.item.name == item.name);
        }
      }
    });
  }

  void _checkTargets() {
    if (_targetsMet && !_hasShownCelebration) {
      _hasShownCelebration = true;
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _showCelebrationPopup();
      });
    }
  }

  void _showCelebrationPopup() {
    _celebrationController.forward(from: 0.0);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => _CelebrationDialog(
        controller: _celebrationController,
        onCreateMeal: () {
          Navigator.of(ctx).pop();
          _createMealAndReturn();
        },
      ),
    );
  }

  void _createMealAndReturn() {
    if (_cart.isEmpty) return;

    final totalCal = _cartCalories;
    final totalProt = _cartProtein;
    final totalCarb = _cartCarbs;
    final totalFt = _cartFat;

    final items = _cart.map((e) => {
      'name': e.item.name,
      'emoji': e.item.emoji,
      'quantity': e.quantity,
      'calories': e.totalCalories,
      'protein': e.totalProtein,
      'carbs': e.totalCarbs,
      'fat': e.totalFat,
      'servingSize': e.item.servingSize,
      'checked': false,
    }).toList();

    final mealData = {
      'type': 'Custom Meal',
      'time': _currentTimeString(),
      'name': 'My Custom Meal',
      'icon': '🍽️',
      'calories': totalCal,
      'protein': totalProt,
      'carbs': totalCarb,
      'fat': totalFt,
      'eaten': false,
      'isCustom': true,
      'customItems': items,
      'ingredients': items.map((i) => '${i['quantity']}x ${i['name']}').toList(),
    };

    Navigator.of(context).pop(mealData);
  }

  String _currentTimeString() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrilliantColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTargetsSummary(),
            const SizedBox(height: 8),
            _buildCategoryTabs(),
            const SizedBox(height: 8),
            Expanded(child: _buildFoodGrid()),
            if (_cart.isNotEmpty) _buildCartBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: BrilliantColors.bgSecondary,
                border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: BrilliantColors.textPrimary,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build Your Meal',
                  style: BrilliantTheme.headerStyle(fontSize: 20),
                ),
                const SizedBox(height: 2),
                Text(
                  'Select foods to meet remaining targets',
                  style: BrilliantTheme.bodyStyle(fontSize: 12, color: BrilliantColors.textMuted),
                ),
              ],
            ),
          ),
          if (_totalCartItems > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: BrilliantColors.mint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: BrilliantColors.mint.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Text(
                '$_totalCartItems items',
                style: const TextStyle(
                  color: BrilliantColors.mint,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTargetsSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BrilliantColors.bgSecondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REMAINING TARGETS',
                style: BrilliantTheme.badgeStyle(color: BrilliantColors.amber),
              ),
              if (_targetsMet)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: BrilliantColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Targets Met ✨',
                    style: TextStyle(
                      color: BrilliantColors.green,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildTargetMetric('Calories', _cartCalories, widget.remainingCalories, 'cal', BrilliantColors.coral),
              _buildTargetMetric('Protein', _cartProtein, widget.remainingProtein, 'g', BrilliantColors.mint),
              _buildTargetMetric('Carbs', _cartCarbs, widget.remainingCarbs, 'g', BrilliantColors.purple),
              _buildTargetMetric('Fats', _cartFat, widget.remainingFats, 'g', BrilliantColors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTargetMetric(String label, int current, int target, String unit, Color color) {
    final double pct = target > 0 ? (current / target).clamp(0.0, 1.0) : 1.0;
    final bool isMet = current >= target;

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: BrilliantColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            '$current/$target',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: isMet ? BrilliantColors.green : color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: BrilliantColors.bgTertiary,
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isMet ? BrilliantColors.green : color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final cat = _categories[index];

          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? BrilliantColors.mint : BrilliantColors.bgSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? BrilliantColors.mint : BrilliantColors.surfaceBorder,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Text(cat['emoji'] as String, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    cat['name'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? BrilliantColors.textInverse : BrilliantColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodGrid() {
    final items = _filteredItems;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final food = items[index];
        final qty = _getCartQuantity(food);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: BrilliantColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: qty > 0 ? BrilliantColors.mint.withValues(alpha: 0.5) : BrilliantColors.surfaceBorder,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Text(food.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: BrilliantTheme.titleStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${food.caloriesPerServing} cal · ${food.servingSize}',
                      style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${food.proteinPerServing}g P · ${food.carbsPerServing}g C · ${food.fatPerServing}g F',
                      style: const TextStyle(color: BrilliantColors.mint, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (qty == 0)
                BrilliantButton(
                  onPressed: () => _addToCart(food),
                  color: BrilliantColors.mint,
                  shadowColor: BrilliantColors.mintDark,
                  textColor: BrilliantColors.textInverse,
                  borderRadius: 10,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: const Text('+ Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                )
              else
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => _removeFromCart(food),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: BrilliantColors.bgTertiary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: BrilliantColors.surfaceBorder),
                        ),
                        child: const Icon(Icons.remove, size: 16, color: BrilliantColors.textPrimary),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '$qty',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: BrilliantColors.mint),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _addToCart(food),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: BrilliantColors.mint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, size: 16, color: BrilliantColors.textInverse),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCartBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: BrilliantColors.bgSecondary,
        border: Border(top: BorderSide(color: BrilliantColors.surfaceBorder, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cart Summary',
                style: BrilliantTheme.titleStyle(fontSize: 14),
              ),
              Text(
                '$_cartCalories cal · $_cartProtein g Protein',
                style: const TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BrilliantButton(
            fullWidth: true,
            onPressed: _createMealAndReturn,
            color: _targetsMet ? BrilliantColors.green : BrilliantColors.mint,
            shadowColor: _targetsMet ? BrilliantColors.greenDark : BrilliantColors.mintDark,
            textColor: BrilliantColors.textInverse,
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_targetsMet ? Icons.check_circle_rounded : Icons.restaurant_menu_rounded, size: 20),
                const SizedBox(width: 8),
                Text(
                  _targetsMet ? 'Create & Log Meal ✨' : 'Create Meal ($_totalCartItems items)',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationDialog extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onCreateMeal;

  const _CelebrationDialog({
    required this.controller,
    required this.onCreateMeal,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: BrilliantColors.bgSecondary,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: BrilliantColors.green, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: BrilliantColors.amber,
                ),
                alignment: Alignment.center,
                child: const Text('🏆', style: TextStyle(fontSize: 36)),
              ),
              const SizedBox(height: 16),
              Text(
                'Target Met! 🎉',
                style: BrilliantTheme.headerStyle(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                "You've satisfied all remaining daily nutrition targets!",
                textAlign: TextAlign.center,
                style: BrilliantTheme.bodyStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),
              BrilliantButton(
                fullWidth: true,
                onPressed: onCreateMeal,
                color: BrilliantColors.green,
                shadowColor: BrilliantColors.greenDark,
                textColor: BrilliantColors.textInverse,
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: const Text('Create & Log Meal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
