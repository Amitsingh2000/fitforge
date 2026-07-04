import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';
import '../../dashboard/widgets/radial_progress.dart';
import '../widgets/trainer_plan_editor_sheet.dart';
import '../widgets/trainer_feedback_sheet.dart';

class TrainerClientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> client;

  const TrainerClientDetailScreen({super.key, required this.client});

  @override
  State<TrainerClientDetailScreen> createState() => _TrainerClientDetailScreenState();
}

class _TrainerClientDetailScreenState extends State<TrainerClientDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientName = widget.client['name'] as String;
    final initials = widget.client['initials'] as String;
    final gradientColors = widget.client['gradientColors'] as List<Color>;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Background glows
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentCyan.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scroll View
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 180.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.bgPrimary,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradientColors,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: AppTextStyles.titleLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  clientName,
                                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentCyan.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        widget.client['goal'] as String,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.accentCyan,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Plan: ${widget.client['plan']}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: _tabController,
                      indicatorColor: AppColors.accentCyan,
                      labelColor: AppColors.accentCyan,
                      unselectedLabelColor: AppColors.textTertiary,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                      tabs: const [
                        Tab(text: 'Progress'),
                        Tab(text: 'Attendance'),
                        Tab(text: 'Nutrition'),
                        Tab(text: 'Workouts'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildProgressTab(),
                _buildAttendanceTab(),
                _buildNutritionTab(),
                _buildWorkoutsTab(),
              ],
            ),
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomActionBar(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  PROGRESS TAB
  // ═══════════════════════════════════════════════
  Widget _buildProgressTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radial Progress Card
          DashboardGlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                RadialProgress(
                  progress: widget.client['progress'] as double,
                  size: 100,
                  strokeWidth: 8,
                  progressColor: AppColors.accentCyan,
                  child: Center(
                    child: Text(
                      '${(widget.client['progress'] * 100).toInt()}%',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Goal Progress', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Targeting ${widget.client['goal'] == 'Weight Loss' ? '70 kg' : '82 kg'} by September.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Joined: ${widget.client['joinDate']}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.05, end: 0),

          const SizedBox(height: 20),

          // Weight Trend chart
          _buildSectionHeader('Weight Log Trend'),
          const SizedBox(height: 12),
          DashboardGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Current: 74.2 kg', style: AppTextStyles.labelLarge),
                    Text('Start: 82.0 kg', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 100,
                  child: CustomPaint(
                    painter: _WeightLinePainter(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Jan', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    Text('Feb', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    Text('Mar', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    Text('Apr', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    Text('May', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                    Text('Jun', style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: 20),

          // Milestones
          _buildSectionHeader('Milestones Achieved'),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final titles = ['First 5 kg dropped!', '15-day workout streak reached'];
              final dates = ['14 Feb 2026', '28 Mar 2026'];
              return DashboardGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderRadius: 14,
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppColors.accentOrange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titles[index], style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(dates[index], style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                        ],
                      ),
                    ),
                    Text(
                      '+500 XP',
                      style: AppTextStyles.caption.copyWith(color: AppColors.accentCyan, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  ATTENDANCE TAB
  // ═══════════════════════════════════════════════
  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attendance metrics card
          DashboardGlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildAttendanceMetric('92%', 'Attendance Rate', AppColors.accentCyan),
                _buildAttendanceMetric('14', 'Current Streak', AppColors.accentOrange),
                _buildAttendanceMetric('28', 'Max Streak', AppColors.accentPurple),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Calendar View
          _buildSectionHeader('June Attendance Calendar'),
          const SizedBox(height: 12),
          DashboardGlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    // Mock attendance check
                    final attended = day != 4 && day != 11 && day != 22;
                    return Container(
                      decoration: BoxDecoration(
                        color: attended
                            ? AppColors.accentCyan.withValues(alpha: 0.15)
                            : AppColors.accentCoral.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: attended
                              ? AppColors.accentCyan.withValues(alpha: 0.4)
                              : AppColors.accentCoral.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: attended ? AppColors.accentCyan : AppColors.accentCoral,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceMetric(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  NUTRITION TAB
  // ═══════════════════════════════════════════════
  Widget _buildNutritionTab() {
    final int caloriesTarget = 2500;
    final int caloriesConsumed = 1850;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie card
          DashboardGlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                RadialProgress(
                  progress: caloriesConsumed / caloriesTarget,
                  size: 110,
                  strokeWidth: 9,
                  progressColor: AppColors.accentCoral,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$caloriesConsumed',
                          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '/ $caloriesTarget',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 9),
                        ),
                        Text(
                          'kcal',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Macros Breakdown', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 10),
                      _buildMacroProgress('Protein', 110, 140, AppColors.accentCoral),
                      const SizedBox(height: 8),
                      _buildMacroProgress('Carbs', 210, 250, AppColors.accentBlue),
                      const SizedBox(height: 8),
                      _buildMacroProgress('Fats', 55, 75, AppColors.accentOrange),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Daily Meals List
          _buildSectionHeader('Meal Log Today'),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final meals = [
                {'name': '🥣 Breakfast', 'time': '8:30 AM', 'cals': '520 kcal', 'pro': '28g P'},
                {'name': '🥗 Lunch', 'time': '1:15 PM', 'cals': '680 kcal', 'pro': '42g P'},
                {'name': '🥜 Snack', 'time': '4:30 PM', 'cals': '210 kcal', 'pro': '10g P'},
                {'name': '🍽️ Dinner', 'time': '8:15 PM', 'cals': '440 kcal', 'pro': '30g P'},
              ];
              final meal = meals[index];
              return DashboardGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: 14,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(meal['name']!, style: AppTextStyles.labelLarge.copyWith(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            'Logged at ${meal['time']}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(meal['cals']!, style: AppTextStyles.labelLarge.copyWith(fontSize: 13, color: AppColors.accentCoral)),
                        const SizedBox(height: 2),
                        Text(meal['pro']!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgress(String label, int current, int target, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.textSecondary)),
            Text('$current / $target g', style: AppTextStyles.caption.copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressBar(
          progress: current / target,
          color: color,
          height: 3,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  WORKOUTS TAB
  // ═══════════════════════════════════════════════
  Widget _buildWorkoutsTab() {
    final List<Map<String, dynamic>> exercises = [
      {'name': 'Barbell Back Squats', 'sets': '4 Sets x 8 Reps', 'weight': '110 kg', 'completed': true},
      {'name': 'Incline Dumbbell Press', 'sets': '3 Sets x 10 Reps', 'weight': '32 kg each', 'completed': true},
      {'name': 'Cable Row', 'sets': '4 Sets x 12 Reps', 'weight': '64 kg', 'completed': true},
      {'name': 'Leg Extensions', 'sets': '3 Sets x 12 Reps', 'weight': '45 kg', 'completed': false},
      {'name': 'Hanging Leg Raises', 'sets': '3 Sets x 15 Reps', 'weight': 'Bodyweight', 'completed': false},
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout summary card
          DashboardGlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                  ),
                  child: const Icon(Icons.fitness_center_rounded, color: AppColors.accentBlue, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Push Day workout', style: AppTextStyles.labelLarge),
                      const SizedBox(height: 2),
                      Text('3 / 5 exercises completed', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),

          const SizedBox(height: 20),

          // Exercise Log list
          _buildSectionHeader('Logged Exercises Today'),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: exercises.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              final isCompleted = exercise['completed'] as bool;
              return DashboardGlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                borderRadius: 14,
                borderColor: isCompleted ? AppColors.accentCyan.withValues(alpha: 0.25) : null,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.accentCyan.withValues(alpha: 0.15)
                            : AppColors.bgPrimary,
                        border: Border.all(
                          color: isCompleted ? AppColors.accentCyan : AppColors.glassBorder,
                          width: 1,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check_rounded, color: AppColors.accentCyan, size: 14)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise['name'] as String,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 14,
                              color: isCompleted ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exercise['sets'] as String,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      exercise['weight'] as String,
                      style: AppTextStyles.caption.copyWith(
                        color: isCompleted ? AppColors.accentCyan : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  BOTTOM ACTION BAR (Sticky Actions)
  // ═══════════════════════════════════════════════
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.bgPrimary.withValues(alpha: 0.95),
            AppColors.bgPrimary,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final value = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => TrainerPlanEditorSheet(client: widget.client),
                );
                if (value == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.bgTertiary,
                      content: Text(
                        'Successfully updated diet & workout plan for ${widget.client['name']}.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCyan),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_note_rounded, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Update Plan',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final value = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => TrainerFeedbackSheet(client: widget.client),
                );
                if (value == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.bgTertiary,
                      content: Text(
                        'Feedback successfully sent to ${widget.client['name']}.',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCyan),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentBlue.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Send Feedback',
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper delegate for persistent Segmented TabBar header
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: AppColors.bgPrimary.withValues(alpha: 0.8),
          child: _tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// Premium Weight line graph Custom Painter
class _WeightLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentCyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = AppColors.accentCyan.withValues(alpha: 0.15)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final points = [
      Offset(0, size.height * 0.1),
      Offset(size.width * 0.2, size.height * 0.15),
      Offset(size.width * 0.4, size.height * 0.35),
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.8, size.height * 0.7),
      Offset(size.width, size.height * 0.8),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Draw shadow area below line
    final shadowPath = Path()
      ..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      shadowPath.lineTo(points[i].dx, points[i].dy);
    }
    shadowPath.lineTo(size.width, size.height);
    shadowPath.lineTo(0, size.height);
    shadowPath.close();

    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.accentCyan.withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Draw data points dot indicator
    final dotPaint = Paint()..color = AppColors.accentCyan;
    final outerDotPaint = Paint()
      ..color = AppColors.bgPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (var point in points) {
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 5, outerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
