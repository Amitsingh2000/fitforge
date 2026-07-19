import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';

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

/// Meal Builder Screen — full-screen cart-based meal customization.
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
    {'name': 'All', 'emoji': '🍽️', 'color': AppColors.accentBlue},
    {'name': 'Proteins', 'emoji': '🥩', 'color': AppColors.accentCoral},
    {'name': 'Grains', 'emoji': '🌾', 'color': AppColors.accentOrange},
    {'name': 'Vegetables', 'emoji': '🥦', 'color': Color(0xFF22C55E)},
    {'name': 'Fruits', 'emoji': '🍎', 'color': AppColors.accentPurple},
    {'name': 'Dairy', 'emoji': '🥛', 'color': AppColors.accentCyan},
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
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  // ── Computed values ──

  int get _cartCalories => _cart.fold(0, (s, e) => s + e.totalCalories);
  int get _cartProtein => _cart.fold(0, (s, e) => s + e.totalProtein);
  int get _cartCarbs => _cart.fold(0, (s, e) => s + e.totalCarbs);
  int get _cartFat => _cart.fold(0, (s, e) => s + e.totalFat);
  int get _totalCartItems => _cart.fold(0, (s, e) => s + e.quantity);

  double get _caloriesProgress =>
      widget.remainingCalories > 0 ? (_cartCalories / widget.remainingCalories).clamp(0.0, 1.5) : 1.0;
  double get _proteinProgress =>
      widget.remainingProtein > 0 ? (_cartProtein / widget.remainingProtein).clamp(0.0, 1.5) : 1.0;
  double get _carbsProgress =>
      widget.remainingCarbs > 0 ? (_cartCarbs / widget.remainingCarbs).clamp(0.0, 1.5) : 1.0;
  double get _fatProgress =>
      widget.remainingFats > 0 ? (_cartFat / widget.remainingFats).clamp(0.0, 1.5) : 1.0;

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

    // Dynamic sorting by relevance to remaining macro targets
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
        return scoreB.compareTo(scoreA); // Bubble up items containing what is most needed
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
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showCelebrationPopup();
      });
    }
  }

  void _showCelebrationPopup() {
    _celebrationController.forward(from: 0.0);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
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

    // Build the meal data map to return
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
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top header ──
            _buildHeader(),
            // ── Remaining targets summary ──
            _buildTargetsSummary(),
            const SizedBox(height: 8),
            // ── Category tabs ──
            _buildCategoryTabs(),
            const SizedBox(height: 8),
            // ── Food items grid ──
            Expanded(child: _buildFoodGrid()),
            // ── Bottom cart bar ──
            if (_cart.isNotEmpty) _buildCartBar(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────

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
                color: AppColors.bgTertiary,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textSecondary,
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
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Add items to meet your daily targets',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Cart counter badge
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$_totalCartItems',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
                .animate(target: _cart.isNotEmpty ? 1 : 0)
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 200.ms),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, duration: 400.ms);
  }

  // ─────────────────────────────────────
  // TARGETS SUMMARY
  // ─────────────────────────────────────

  Widget _buildTargetsSummary() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DashboardGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 16,
        borderColor: AppColors.accentBlue.withValues(alpha: 0.2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentBlue.withValues(alpha: 0.06),
            AppColors.accentPurple.withValues(alpha: 0.03),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: AppColors.accentBlue,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'REMAINING TARGETS',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                if (_targetsMet)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'TARGETS MET!',
                          style: AppTextStyles.caption.copyWith(
                            color: const Color(0xFF22C55E),
                            fontWeight: FontWeight.w800,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTargetMini(
                  '🔥',
                  'Calories',
                  '${widget.remainingCalories - _cartCalories > 0 ? widget.remainingCalories - _cartCalories : 0}',
                  '${widget.remainingCalories}',
                  _caloriesProgress,
                  AppColors.accentBlue,
                ),
                _buildTargetMini(
                  '💪',
                  'Protein',
                  '${widget.remainingProtein - _cartProtein > 0 ? widget.remainingProtein - _cartProtein : 0}g',
                  '${widget.remainingProtein}g',
                  _proteinProgress,
                  AppColors.accentCoral,
                ),
                _buildTargetMini(
                  '🌾',
                  'Carbs',
                  '${widget.remainingCarbs - _cartCarbs > 0 ? widget.remainingCarbs - _cartCarbs : 0}g',
                  '${widget.remainingCarbs}g',
                  _carbsProgress,
                  AppColors.accentPurple,
                ),
                _buildTargetMini(
                  '🥑',
                  'Fats',
                  '${widget.remainingFats - _cartFat > 0 ? widget.remainingFats - _cartFat : 0}g',
                  '${widget.remainingFats}g',
                  _fatProgress,
                  AppColors.accentOrange,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms);
  }

  Widget _buildTargetMini(
    String emoji,
    String label,
    String remaining,
    String total,
    double progress,
    Color color,
  ) {
    final bool isMet = progress >= 1.0;
    return Expanded(
      child: Column(
        children: [
          // Tiny circular progress
          SizedBox(
            width: 38,
            height: 38,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 3,
                  backgroundColor: AppColors.bgTertiary,
                  valueColor: AlwaysStoppedAnimation(
                    isMet ? const Color(0xFF22C55E) : color,
                  ),
                ),
                Text(emoji, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isMet ? '✓' : remaining,
            style: AppTextStyles.caption.copyWith(
              color: isMet ? const Color(0xFF22C55E) : color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
          Text(
            'of $total',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary.withValues(alpha: 0.7),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // CATEGORY TABS
  // ─────────────────────────────────────

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = index == _selectedCategoryIndex;
          final color = cat['color'] as Color;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.15) : AppColors.bgTertiary.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color.withValues(alpha: 0.4) : AppColors.glassBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat['emoji'] as String, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      cat['name'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? color : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  // ─────────────────────────────────────
  // FOOD GRID
  // ─────────────────────────────────────

  Widget _buildFoodGrid() {
    final items = _filteredItems;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final qty = _getCartQuantity(item);
        final isInCart = qty > 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildFoodItemCard(item, qty, isInCart, index),
        );
      },
    );
  }

  Widget _buildFoodItemCard(FoodItem item, int qty, bool isInCart, int index) {
    // Get category color
    final catEntry = _categories.firstWhere(
      (c) => c['name'] == item.category,
      orElse: () => _categories[0],
    );
    final catColor = catEntry['color'] as Color;

    return DashboardGlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      borderColor: isInCart ? catColor.withValues(alpha: 0.35) : AppColors.glassBorder,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isInCart
            ? [
                catColor.withValues(alpha: 0.08),
                catColor.withValues(alpha: 0.03),
              ]
            : [
                AppColors.bgSecondary.withValues(alpha: 0.6),
                AppColors.bgPrimary.withValues(alpha: 0.4),
              ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isInCart ? catColor : catColor.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  children: [
                    // Emoji avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: catColor.withValues(alpha: 0.2)),
                      ),
                      alignment: Alignment.center,
                      child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    // Name + macros
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.name,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.servingSize,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Macro pills
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: [
                              _buildMacroPill('${item.caloriesPerServing} cal', AppColors.accentBlue),
                              _buildMacroPill('${item.proteinPerServing}g P', AppColors.accentCoral),
                              _buildMacroPill('${item.carbsPerServing}g C', AppColors.accentPurple),
                              _buildMacroPill('${item.fatPerServing}g F', AppColors.accentOrange),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add / Quantity stepper
                    if (!isInCart)
                      GestureDetector(
                        onTap: () => _addToCart(item),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: catColor.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(Icons.add_rounded, color: catColor, size: 22),
                        ),
                      )
                    else
                      _buildQuantityStepper(item, qty, catColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms, delay: ((index * 50).clamp(0, 300)).ms)
        .slideX(begin: 0.05, end: 0, duration: 350.ms, delay: ((index * 50).clamp(0, 300)).ms);
  }

  Widget _buildMacroPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 9,
        ),
      ),
    );
  }

  Widget _buildQuantityStepper(FoodItem item, int qty, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Plus
          GestureDetector(
            onTap: () => _addToCart(item),
            child: Container(
              width: 36,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                color: color.withValues(alpha: 0.12),
              ),
              child: Icon(Icons.add_rounded, color: color, size: 16),
            ),
          ),
          // Quantity
          Container(
            width: 36,
            padding: const EdgeInsets.symmetric(vertical: 4),
            alignment: Alignment.center,
            child: Text(
              '$qty',
              style: AppTextStyles.labelLarge.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          // Minus
          GestureDetector(
            onTap: () => _removeFromCart(item),
            child: Container(
              width: 36,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(11)),
                color: color.withValues(alpha: 0.06),
              ),
              child: Icon(Icons.remove_rounded, color: color.withValues(alpha: 0.7), size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────
  // CART BAR (BOTTOM)
  // ─────────────────────────────────────

  Widget _buildCartBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Macros progress row
              Row(
                children: [
                  _buildCartMacro('Cal', _cartCalories, widget.remainingCalories, AppColors.accentBlue),
                  const SizedBox(width: 8),
                  _buildCartMacro('Prot', _cartProtein, widget.remainingProtein, AppColors.accentCoral),
                  const SizedBox(width: 8),
                  _buildCartMacro('Carb', _cartCarbs, widget.remainingCarbs, AppColors.accentPurple),
                  const SizedBox(width: 8),
                  _buildCartMacro('Fat', _cartFat, widget.remainingFats, AppColors.accentOrange),
                ],
              ),
              const SizedBox(height: 12),
              // Create Meal button
              GestureDetector(
                onTap: _cart.isNotEmpty ? _createMealAndReturn : null,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: _targetsMet
                        ? const LinearGradient(
                            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                          )
                        : AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: (_targetsMet ? const Color(0xFF22C55E) : AppColors.accentBlue)
                            .withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _targetsMet ? Icons.check_circle_rounded : Icons.restaurant_menu_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _targetsMet ? 'Create Meal ✨' : 'Create Meal ($_totalCartItems items)',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildCartMacro(String label, int current, int target, Color color) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 1.0;
    final isMet = current >= target;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isMet)
                  Icon(Icons.check_circle_rounded, color: const Color(0xFF22C55E), size: 10)
                else
                  const SizedBox.shrink(),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    '$current',
                    style: AppTextStyles.caption.copyWith(
                      color: isMet ? const Color(0xFF22C55E) : color,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                backgroundColor: AppColors.bgTertiary,
                valueColor: AlwaysStoppedAnimation(
                  isMet ? const Color(0xFF22C55E) : color,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// CELEBRATION DIALOG
// ─────────────────────────────────────────

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
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final scaleValue = Curves.easeOutBack.transform(
              controller.value.clamp(0.0, 1.0),
            );
            return Transform.scale(
              scale: scaleValue,
              child: child,
            );
          },
          child: DashboardGlassCard(
            padding: const EdgeInsets.all(24),
            borderRadius: 24,
            borderColor: const Color(0xFF22C55E).withValues(alpha: 0.35),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bgSecondary.withValues(alpha: 0.9),
                AppColors.bgTertiary.withValues(alpha: 0.95),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Trophy Circular Badge
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Yayyyy! 🎉',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Today's Nutrition Completed!",
                  style: AppTextStyles.labelLarge.copyWith(
                    color: const Color(0xFF22C55E),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  "All macro targets (Calories, Protein, Carbs, and Fats) have been successfully met.",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Action Button
                GestureDetector(
                  onTap: onCreateMeal,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Create & Log Meal',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
