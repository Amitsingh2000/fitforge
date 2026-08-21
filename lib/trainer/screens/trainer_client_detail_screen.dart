import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../models/diet_plan.dart';
import '../../models/member_attendance.dart';
import '../../models/member_progress_summary.dart';
import '../../models/nutrition_log.dart';
import '../../models/progress_entry.dart';
import '../../models/trainer_client.dart';
import '../../models/workout_log.dart';
import '../../providers/gym_provider.dart';
import '../../providers/trainer_flow_providers.dart';
import '../../services/member_management_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';
import '../../dashboard/widgets/radial_progress.dart';
import '../../dashboard/widgets/state_views.dart';
import '../widgets/client_gradient.dart';
import '../widgets/trainer_plan_editor_sheet.dart';
import '../widgets/trainer_feedback_sheet.dart';
import 'trainer_chat_conversation_screen.dart';

class TrainerClientDetailScreen extends ConsumerStatefulWidget {
  final TrainerClient client;

  const TrainerClientDetailScreen({super.key, required this.client});

  @override
  ConsumerState<TrainerClientDetailScreen> createState() =>
      _TrainerClientDetailScreenState();
}

class _TrainerClientDetailScreenState
    extends ConsumerState<TrainerClientDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

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

  // Uses `ref.read` (not `ref.watch`) because this getter is also evaluated
  // from error-retry callbacks (outside build), where `watch` is illegal.
  // Reactivity is preserved by an explicit `ref.watch(currentGymIdProvider)`
  // in `build` below.
  String? get _gymId => ref.read(currentGymIdProvider);

  ({String gymId, String userId}) get _memberKey =>
      (gymId: _gymId ?? '', userId: widget.client.userId);

  bool get _hasKey => _gymId != null && widget.client.userId.isNotEmpty;

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  String _fmtTime(DateTime? d) {
    if (d == null) return '';
    var hour = d.hour;
    final meridian = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12 == 0 ? 12 : hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    return '$hour:$minute $meridian';
  }

  Future<void> _editWeeklyFocus(String? current) async {
    final gymId = _gymId;
    if (gymId == null) return;
    final ctrl = TextEditingController(text: current ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('This week\'s focus', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          maxLength: 500,
          maxLines: 3,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'e.g. Train 4x; hit 120g protein',
            hintStyle: TextStyle(color: AppColors.textTertiary),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );
    final text = ctrl.text.trim();
    ctrl.dispose();
    if (saved != true || !mounted) return;
    try {
      await ref.read(memberManagementServiceProvider).setWeeklyFocus(
            gymId,
            widget.client.userId,
            weeklyFocus: text,
          );
      ref.invalidate(memberProfileProvider(_memberKey));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyApiError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.client;
    final gradientColors = clientGradient(client.userId);
    final goal = client.fitnessGoal ?? 'No goal set';

    // Keep the screen reactive to the active-gym change while `_gymId` reads
    // (safe outside build) via ref.read.
    ref.watch(currentGymIdProvider);

    if (!_hasKey) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Center(
            child: ErrorRetryView(
              message: 'No gym selected. Select a gym to view this client.',
              onRetry: () {
                if (Navigator.of(context).canPop()) Navigator.of(context).pop();
              },
            ),
          ),
        ),
      );
    }

    final key = _memberKey;
    final entriesAsync = ref.watch(memberProgressEntriesProvider(key));
    final summaryAsync = ref.watch(memberProgressSummaryProvider(key));
    final attendanceAsync = ref.watch(memberAttendanceProvider(key));
    final nutritionAsync = ref.watch(memberNutritionLogsProvider(key));
    final workoutsAsync = ref.watch(memberWorkoutLogsProvider(key));
    final dietPlansAsync = ref.watch(memberDietPlansProvider(key));
    final profileAsync = ref.watch(memberProfileProvider(key));
    final weeklyFocus = profileAsync.asData?.value.weeklyFocus;

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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.flag_outlined, color: AppColors.textSecondary),
                      tooltip: 'Weekly focus',
                      onPressed: () => _editWeeklyFocus(weeklyFocus),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () {
                        final gymId = _gymId;
                        if (gymId == null) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TrainerChatConversationScreen(
                              gymId: gymId,
                              otherUserId: client.userId,
                              otherUserName: client.fullName,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
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
                                client.initials,
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
                                const Spacer(),
                                Text(
                                  client.fullName,
                                  style: AppTextStyles.titleLarge
                                      .copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentCyan
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        goal,
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
                                        'Plan: ${client.planName ?? 'No plan'}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textTertiary),
                                      ),
                                    ),
                                  ],
                                ),
                                if (weeklyFocus != null && weeklyFocus.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    weeklyFocus,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                                const SizedBox(height: 14),
                                const Spacer(),
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
                      labelStyle: AppTextStyles.caption
                          .copyWith(fontWeight: FontWeight.bold, fontSize: 12),
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
                _buildProgressTab(entriesAsync, summaryAsync),
                _buildAttendanceTab(attendanceAsync),
                _buildNutritionTab(nutritionAsync, dietPlansAsync),
                _buildWorkoutsTab(workoutsAsync),
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
  Widget _buildProgressTab(
      AsyncValue<List<ProgressEntry>> entriesAsync,
      AsyncValue<MemberProgressSummary> summaryAsync) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 16, 20, Layout.navClearance(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          entriesAsync.when(
            loading: () =>
                const Center(child: LoadingView(message: 'Loading progress…')),
            error: (e, _) => Center(
              child: ErrorRetryView(
                message: friendlyApiError(e),
                onRetry: () => ref.invalidate(memberProgressEntriesProvider(
                    _memberKey)),
              ),
            ),
            data: (entries) {
              return summaryAsync.when(
                loading: () => const Center(
                    child: LoadingView(message: 'Loading summary…')),
                error: (e, _) => Center(
                  child: ErrorRetryView(
                    message: friendlyApiError(e),
                    onRetry: () => ref.invalidate(
                        memberProgressSummaryProvider(_memberKey)),
                  ),
                ),
                data: (summary) => _buildProgressContent(entries, summary),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent(
      List<ProgressEntry> entries, MemberProgressSummary summary) {
    final pct = summary.workoutCompletionRatePercent.clamp(0, 100);
    final weights = entries
        .where((e) => e.weightKg != null && e.loggedAt != null)
        .toList()
      ..sort((a, b) => a.loggedAt!.compareTo(b.loggedAt!));
    final firstWeight = weights.isNotEmpty ? weights.first.weightKg! : null;
    final latestWeight = weights.isNotEmpty ? weights.last.weightKg! : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Goal Progress Card
        DashboardGlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              RadialProgress(
                progress: pct / 100,
                size: 100,
                strokeWidth: 8,
                progressColor: AppColors.accentCyan,
                child: Center(
                  child: Text(
                    '$pct%',
                    style: AppTextStyles.titleMedium
                        .copyWith(fontWeight: FontWeight.bold),
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
                      'Workout completion across the active plan.',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Joined: ${_fmtDate(widget.client.joinedAt)}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.05, end: 0),

        const SizedBox(height: 20),

        // Weight Log Trend chart
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
                  Text(
                    latestWeight == null
                        ? 'No weight logs yet'
                        : 'Current: ${latestWeight.toStringAsFixed(1)} kg',
                    style: AppTextStyles.labelLarge,
                  ),
                  Text(
                    firstWeight == null
                        ? '—'
                        : 'Start: ${firstWeight.toStringAsFixed(1)} kg',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 100,
                child: weights.length >= 2
                    ? CustomPaint(
                        painter: _WeightLinePainter(
                          values: _normalizedWeights(weights),
                        ),
                      )
                    : Center(
                        child: Text(
                          'Log at least 2 weigh-ins to see a trend.',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weights.length >= 2
                    ? [
                        Text(
                            '${weights.first.loggedAt!.day} ${_months[weights.first.loggedAt!.month - 1]}',
                            style: const TextStyle(
                                color: AppColors.textTertiary, fontSize: 10)),
                        Text(
                            '${weights.last.loggedAt!.day} ${_months[weights.last.loggedAt!.month - 1]}',
                            style: const TextStyle(
                                color: AppColors.textTertiary, fontSize: 10)),
                      ]
                    : const [SizedBox.shrink(), SizedBox.shrink()],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),

        const SizedBox(height: 20),

        // Progress snapshot (real compliance + logged counts)
        _buildSectionHeader('Compliance Snapshot'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSnapshotTile(
                '${summary.workoutCompletionRatePercent}%',
                'Workout Completion',
                AppColors.accentCyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSnapshotTile(
                '${summary.nutritionComplianceRatePercent}%',
                'Nutrition Compliance',
                AppColors.accentOrange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSnapshotTile(
                '${summary.workoutsLoggedCount ?? 0}',
                'Workouts Logged',
                AppColors.accentBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSnapshotTile(
                '${summary.nutritionDaysLoggedCount ?? 0}',
                'Nutrition Days',
                AppColors.accentPurple,
              ),
            ),
          ],
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.05, end: 0),
      ],
    );
  }

  Widget _buildSnapshotTile(String value, String label, Color color) {
    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  List<double> _normalizedWeights(List<ProgressEntry> entries) {
    final weights = entries
        .where((e) => e.weightKg != null)
        .map((e) => e.weightKg!)
        .toList();
    if (weights.length < 2) return const [];
    final minW = weights.reduce(math.min);
    final maxW = weights.reduce(math.max);
    final span = maxW == minW ? 1.0 : maxW - minW;
    return weights.map((w) => (w - minW) / span).toList();
  }

  // ═══════════════════════════════════════════════
  //  ATTENDANCE TAB
  // ═══════════════════════════════════════════════
  Widget _buildAttendanceTab(
      AsyncValue<List<MemberAttendanceEntry>> attendanceAsync) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 16, 20, Layout.navClearance(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          attendanceAsync.when(
            loading: () =>
                const Center(child: LoadingView(message: 'Loading attendance…')),
            error: (e, _) => Center(
              child: ErrorRetryView(
                message: friendlyApiError(e),
                onRetry: () => ref.invalidate(
                    memberAttendanceProvider(_memberKey)),
              ),
            ),
            data: (entries) {
              final days = entries.map((e) => _dateOnly(e.attendedOn)).toSet();
              final now = DateTime.now();
              final currentStreak = _currentStreak(days, now);
              final maxStreak = _maxStreak(days);
              final last30 = days
                  .where((d) => !d.isBefore(now.subtract(const Duration(days: 29))))
                  .length;
              final rate = ((last30 / 30) * 100).clamp(0, 100).toInt();

              // Calendar month = month of most recent check-in, else now.
              final sorted = entries.toList()
                ..sort((a, b) => b.attendedOn.compareTo(a.attendedOn));
              final monthAnchor =
                  sorted.isNotEmpty ? sorted.first.attendedOn : now;
              final daysAttended = entries
                  .where((e) =>
                      e.attendedOn.year == monthAnchor.year &&
                      e.attendedOn.month == monthAnchor.month)
                  .map((e) => e.attendedOn.day)
                  .toSet();
              final daysInMonth =
                  DateTime(monthAnchor.year, monthAnchor.month + 1, 0).day;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Attendance metrics card
                  DashboardGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAttendanceMetric(
                            '$rate%', 'Attendance Rate', AppColors.accentCyan),
                        _buildAttendanceMetric('$currentStreak',
                            'Current Streak', AppColors.accentOrange),
                        _buildAttendanceMetric(
                            '$maxStreak', 'Max Streak', AppColors.accentPurple),
                      ],
                    ),
                  ).animate().fadeIn(),

                  const SizedBox(height: 20),

                  // Calendar View
                  _buildSectionHeader(
                      '${_months[monthAnchor.month - 1]} ${monthAnchor.year} Attendance'),
                  const SizedBox(height: 12),
                  DashboardGlassCard(
                    padding: const EdgeInsets.all(16),
                    child: entries.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No check-ins recorded yet.',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textTertiary),
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1,
                            ),
                            itemCount: daysInMonth,
                            itemBuilder: (context, index) {
                              final day = index + 1;
                              final attended = daysAttended.contains(day);
                              return Container(
                                decoration: BoxDecoration(
                                  color: attended
                                      ? AppColors.accentCyan.withValues(alpha: 0.15)
                                      : AppColors.bgPrimary,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: attended
                                        ? AppColors.accentCyan.withValues(alpha: 0.4)
                                        : AppColors.glassBorder,
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '$day',
                                    style: TextStyle(
                                      color: attended
                                          ? AppColors.accentCyan
                                          : AppColors.textTertiary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  int _currentStreak(Set<DateTime> days, DateTime now) {
    var count = 0;
    var cursor = DateTime(now.year, now.month, now.day);
    while (days.contains(cursor)) {
      count++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }

  int _maxStreak(Set<DateTime> days) {
    if (days.isEmpty) return 0;
    final sorted = days.toList()..sort();
    var best = 1;
    var run = 1;
    for (var i = 1; i < sorted.length; i++) {
      final diff = sorted[i].difference(sorted[i - 1]).inDays;
      run = diff == 1 ? run + 1 : 1;
      best = math.max(best, run);
    }
    return best;
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
  Widget _buildNutritionTab(
      AsyncValue<List<NutritionLog>> nutritionAsync,
      AsyncValue<List<DietPlan>> dietPlansAsync) {
    // Real target from the client's current diet plan when one is assigned;
    // the plan list may still be loading independently of the logs — that's
    // fine, it just falls back to "no target set" until it resolves.
    final activeDietPlan = dietPlansAsync.maybeWhen(
      data: (plans) => plans.isEmpty ? null : plans.first,
      orElse: () => null,
    );
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 16, 20, Layout.navClearance(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          nutritionAsync.when(
            loading: () =>
                const Center(child: LoadingView(message: 'Loading nutrition…')),
            error: (e, _) => Center(
              child: ErrorRetryView(
                message: friendlyApiError(e),
                onRetry: () => ref.invalidate(
                    memberNutritionLogsProvider(_memberKey)),
              ),
            ),
            data: (logs) {
              final now = DateTime.now();
              final todayLogs = logs
                  .where((l) =>
                      l.loggedAt != null &&
                      l.loggedAt!.year == now.year &&
                      l.loggedAt!.month == now.month &&
                      l.loggedAt!.day == now.day)
                  .toList()
                ..sort((a, b) =>
                    (a.loggedAt ?? now).compareTo(b.loggedAt ?? now));
              final consumed = todayLogs.fold<double>(
                  0.0, (sum, l) => sum + l.totalCalories);
              final protein = todayLogs.fold<double>(
                  0.0, (sum, l) => sum + l.totalProteinG);
              final carbs = todayLogs.fold<double>(
                  0.0, (sum, l) => sum + l.totalCarbsG);
              final fats = todayLogs.fold<double>(
                  0.0, (sum, l) => sum + l.totalFatG);
              final caloriesTarget = activeDietPlan?.dailyCalorieTarget;
              final proteinTarget = activeDietPlan?.dailyProteinTargetG;
              final carbsTarget = activeDietPlan?.dailyCarbsTargetG;
              final fatTarget = activeDietPlan?.dailyFatTargetG;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calorie card
                  DashboardGlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        RadialProgress(
                          progress: caloriesTarget == null || caloriesTarget == 0
                              ? 0.0
                              : (consumed / caloriesTarget).clamp(0.0, 1.0),
                          size: 110,
                          strokeWidth: 9,
                          progressColor: AppColors.accentCoral,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  consumed.toStringAsFixed(0),
                                  style: AppTextStyles.titleMedium
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  caloriesTarget == null
                                      ? 'No target set'
                                      : '/ ${caloriesTarget.toStringAsFixed(0)}',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 9),
                                ),
                                Text(
                                  'kcal',
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 9),
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
                              Text('Today\'s Macros',
                                  style: AppTextStyles.labelLarge),
                              const SizedBox(height: 10),
                              _buildMacroProgress(
                                  'Protein', protein, proteinTarget, AppColors.accentCoral),
                              const SizedBox(height: 8),
                              _buildMacroProgress(
                                  'Carbs', carbs, carbsTarget, AppColors.accentBlue),
                              const SizedBox(height: 8),
                              _buildMacroProgress(
                                  'Fats', fats, fatTarget, AppColors.accentOrange),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                  const SizedBox(height: 20),

                  // Logged meals today
                  _buildSectionHeader('Meal Log Today'),
                  const SizedBox(height: 12),
                  if (todayLogs.isEmpty)
                    DashboardGlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      borderRadius: 14,
                      child: Center(
                        child: Text(
                          'No meals logged today yet.',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todayLogs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final log = todayLogs[index];
                        final items =
                            log.items.map((i) => i.foodName).take(3).join(', ');
                        return DashboardGlassCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          borderRadius: 14,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.mealType ?? 'Meal ${index + 1}',
                                      style: AppTextStyles.labelLarge
                                          .copyWith(fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      items.isEmpty
                                          ? 'Logged at ${_fmtTime(log.loggedAt)}'
                                          : '$items · ${_fmtTime(log.loggedAt)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.textTertiary,
                                          fontSize: 10),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${log.totalCalories.toStringAsFixed(0)} kcal',
                                    style: AppTextStyles.labelLarge.copyWith(
                                        fontSize: 13,
                                        color: AppColors.accentCoral),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${log.totalProteinG.toStringAsFixed(0)}g P',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMacroProgress(
      String label, double current, double? target, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.caption
                    .copyWith(fontSize: 10, color: AppColors.textSecondary)),
            Text(
                target == null
                    ? '${current.toStringAsFixed(0)} g'
                    : '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} g',
                style: AppTextStyles.caption
                    .copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressBar(
          progress: target == null || target == 0
              ? 0.0
              : (current / target).clamp(0.0, 1.0),
          color: color,
          height: 3,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  WORKOUTS TAB
  // ═══════════════════════════════════════════════
  Widget _buildWorkoutsTab(AsyncValue<List<WorkoutLog>> workoutsAsync) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 16, 20, Layout.navClearance(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          workoutsAsync.when(
            loading: () =>
                const Center(child: LoadingView(message: 'Loading workouts…')),
            error: (e, _) => Center(
              child: ErrorRetryView(
                message: friendlyApiError(e),
                onRetry: () =>
                    ref.invalidate(memberWorkoutLogsProvider(_memberKey)),
              ),
            ),
            data: (logs) {
              if (logs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Text(
                      'No workout sessions logged yet.',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                );
              }

              final sorted = logs.toList()
                ..sort((a, b) => (b.loggedAt ?? DateTime.fromMillisecondsSinceEpoch(
                        0)).compareTo(a.loggedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
              final latest = sorted.first;
              final totalSets = latest.sets.length;
              final completedSets =
                  latest.sets.where((s) => s.completed).length;

              // Group sets by exercise name, preserving order.
              final grouped = <String, List<WorkoutLogSet>>{};
              for (final set in latest.sets) {
                grouped.putIfAbsent(set.exerciseName, () => []).add(set);
              }
              final exerciseRows = grouped.entries.toList();

              return Column(
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
                          child: const Icon(Icons.fitness_center_rounded,
                              color: AppColors.accentBlue, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                latest.label ?? 'Log ${latest.dayNumber ?? ''}'
                                    .trim(),
                                style: AppTextStyles.labelLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$completedSets / $totalSets sets completed'
                                '${latest.loggedAt != null ? ' · ${_fmtDate(latest.loggedAt)}' : ''}',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),

                  const SizedBox(height: 20),

                  // Logged exercise list
                  _buildSectionHeader('Logged Exercises'),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: exerciseRows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final entry = exerciseRows[index];
                      final sets = entry.value;
                      final isCompleted = sets.any((s) => s.completed);
                      final repsText = sets
                          .map((s) {
                            final weight = s.weightKg != null
                                ? ' @ ${s.weightKg!.toStringAsFixed(0)}kg'
                                : '';
                            return '${s.reps ?? '—'}$weight';
                          })
                          .join(' · ');
                      final bestWeight = sets
                          .where((s) => s.weightKg != null)
                          .map((s) => s.weightKg!)
                          .fold<double?>(null,
                              (maxW, w) => maxW == null ? w : math.max(maxW, w));

                      return DashboardGlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        borderRadius: 14,
                        borderColor: isCompleted
                            ? AppColors.accentCyan.withValues(alpha: 0.25)
                            : null,
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
                                  color: isCompleted
                                      ? AppColors.accentCyan
                                      : AppColors.glassBorder,
                                  width: 1,
                                ),
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check_rounded,
                                      color: AppColors.accentCyan, size: 14)
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontSize: 14,
                                      color: isCompleted
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${sets.length}S · $repsText',
                                    style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textTertiary,
                                        fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              bestWeight == null
                                  ? 'Bodyweight'
                                  : '${bestWeight.toStringAsFixed(0)} kg',
                              style: AppTextStyles.caption.copyWith(
                                color: isCompleted
                                    ? AppColors.accentCyan
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
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
    final client = widget.client;
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
                  builder: (context) =>
                      TrainerPlanEditorSheet(client: client),
                );
                if (value == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.bgTertiary,
                      content: Text(
                        'Successfully updated diet & workout plan for ${client.fullName}.',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.accentCyan),
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
                    const Icon(Icons.edit_note_rounded,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Update Plan',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.textSecondary, fontSize: 13),
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
                  builder: (context) => TrainerFeedbackSheet(client: client),
                );
                if (value == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.bgTertiary,
                      content: Text(
                        'Feedback successfully sent to ${client.fullName}.',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.accentCyan),
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
                      style: AppTextStyles.labelLarge
                          .copyWith(color: Colors.white, fontSize: 13),
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

// Weight line graph Custom Painter — data-driven from progress entries.
class _WeightLinePainter extends CustomPainter {
  /// Normalized weight values (0 = lightest seen, 1 = heaviest seen).
  final List<double> values;

  _WeightLinePainter({required this.values});

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

    if (values.length < 2) return;
    final points = <Offset>[];
    final n = values.length;
    for (var i = 0; i < n; i++) {
      points.add(Offset(size.width * i / (n - 1), (1.0 - values[i]) * size.height));
    }

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    // Draw shadow area below line
    final shadowPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      shadowPath.lineTo(p.dx, p.dy);
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

    for (final point in points) {
      canvas.drawCircle(point, 5, dotPaint);
      canvas.drawCircle(point, 5, outerDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightLinePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}