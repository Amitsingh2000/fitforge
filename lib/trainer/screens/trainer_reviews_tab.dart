import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import 'trainer_plan_review_screen.dart';

class TrainerReviewsTab extends StatefulWidget {
  const TrainerReviewsTab({super.key});

  @override
  State<TrainerReviewsTab> createState() => _TrainerReviewsTabState();
}

class _TrainerReviewsTabState extends State<TrainerReviewsTab> {
  String _selectedFilter = 'Pending';
  final List<String> _filters = ['Pending', 'Approved', 'Modified'];

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'p1',
      'clientName': 'Rahul Sharma',
      'initials': 'RS',
      'goal': 'Weight Loss',
      'type': 'Workout & Meal Plan',
      'date': 'Today, 11:20 AM',
      'status': 'Pending',
      'gradientColors': [AppColors.accentBlue, AppColors.accentCyan],
      'workout': [
        {'name': 'Bodyweight Squats', 'sets': '4', 'reps': '15'},
        {'name': 'Pushups', 'sets': '3', 'reps': '10-12'},
        {'name': 'Dumbbell Rows', 'sets': '3', 'reps': '12'},
        {'name': 'Jump Rope', 'sets': '3', 'reps': '2 min'},
      ],
      'diet': [
        {'name': 'Steel Cut Oatmeal with Chia Seeds', 'time': 'Breakfast', 'cals': '380 kcal'},
        {'name': 'Baked Tofu Salad with Olive Oil', 'time': 'Lunch', 'cals': '540 kcal'},
        {'name': 'Mixed Berries & Walnuts', 'time': 'Snack', 'cals': '200 kcal'},
        {'name': 'Steamed Salmon with Asparagus', 'time': 'Dinner', 'cals': '620 kcal'},
      ]
    },
    {
      'id': 'p2',
      'clientName': 'Priya Patel',
      'initials': 'PP',
      'goal': 'Muscle Gain',
      'type': 'Meal Plan Only',
      'date': 'Yesterday, 4:45 PM',
      'status': 'Pending',
      'gradientColors': [AppColors.accentPurple, AppColors.accentCoral],
      'workout': [
        {'name': 'Barbell Squats', 'sets': '4', 'reps': '8'},
        {'name': 'Bench Press', 'sets': '4', 'reps': '8'},
      ],
      'diet': [
        {'name': 'Protein Smoothie & Eggs', 'time': 'Breakfast', 'cals': '600 kcal'},
        {'name': 'Grilled Chicken breast with Sweet Potato', 'time': 'Lunch', 'cals': '750 kcal'},
        {'name': 'Whey shake & Banana', 'time': 'Snack', 'cals': '350 kcal'},
        {'name': 'Minced Beef with Basmati Rice', 'time': 'Dinner', 'cals': '850 kcal'},
      ]
    },
    {
      'id': 'p3',
      'clientName': 'Sneha Gupta',
      'initials': 'SG',
      'goal': 'Flexibility',
      'type': 'Workout Plan Only',
      'date': '29 Jun 2026',
      'status': 'Approved',
      'gradientColors': [AppColors.accentCyan, AppColors.accentBlue],
      'workout': [],
      'diet': []
    },
    {
      'id': 'p4',
      'clientName': 'Arjun Reddy',
      'initials': 'AR',
      'goal': 'Strength',
      'type': 'Workout & Meal Plan',
      'date': '26 Jun 2026',
      'status': 'Modified',
      'gradientColors': [AppColors.accentBlue, AppColors.accentPurple],
      'workout': [],
      'diet': []
    }
  ];

  List<Map<String, dynamic>> get _filteredPlans {
    return _plans.where((plan) => plan['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title area
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Plan Reviews',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Verify, customize, and approve AI-generated plans before sending to members.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Filter chips
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = _selectedFilter == filter;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedFilter = filter);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accentCyan.withValues(alpha: 0.15)
                        : AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentCyan.withValues(alpha: 0.5)
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // List view
        Expanded(
          child: _filteredPlans.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
            physics: const BouncingScrollPhysics(),
            itemCount: _filteredPlans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = _filteredPlans[index];
              return _buildPlanCard(plan, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_rounded, color: AppColors.textDisabled, size: 48),
          const SizedBox(height: 16),
          Text(
            'No plans under "$_selectedFilter"',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'All caught up with AI generated reviews!',
            style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int index) {
    final gradientColors = plan['gradientColors'] as List<Color>;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      onTap: () async {
        final actionResult = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (context) => TrainerPlanReviewScreen(plan: plan),
          ),
        );
        if (actionResult != null && mounted) {
          // Simulated update state
          setState(() {
            plan['status'] = actionResult;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.bgTertiary,
              content: Text(
                'Plan successfully $actionResult and sent to ${plan['clientName']}.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCyan),
              ),
            ),
          );
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: Center(
              child: Text(
                plan['initials'] as String,
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Plan details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan['clientName'] as String,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.psychology_rounded, size: 10, color: AppColors.accentPurple),
                          const SizedBox(width: 4),
                          Text(
                            'AI Generated',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accentPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Goal: ${plan['goal']}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.article_rounded, size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      plan['type'] as String,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      plan['date'] as String,
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: (index * 50).ms)
        .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: (index * 50).ms);
  }
}
