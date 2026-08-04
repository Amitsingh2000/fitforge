import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/linear_progress_bar.dart';
import '../widgets/radial_progress.dart';

// ──────────────────────────────────────────────────────────────
// Data models shared between the plan screen and this detail screen
// ──────────────────────────────────────────────────────────────

class WorkoutExercise {
  final String name;
  final String detail;
  final int sets;
  final int reps;
  final int restSeconds;
  final IconData icon;
  final Color color;
  final String? videoUrl; // placeholder for tutorial video
  final String muscleGroup;
  final String difficulty;
  final List<String> tips;

  const WorkoutExercise({
    required this.name,
    required this.detail,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.icon,
    required this.color,
    this.videoUrl,
    this.muscleGroup = 'Full Body',
    this.difficulty = 'Intermediate',
    this.tips = const [],
  });
}

class SetLog {
  final double weight;
  final int reps;
  final DateTime loggedAt;

  const SetLog({
    required this.weight,
    required this.reps,
    required this.loggedAt,
  });
}

// ──────────────────────────────────────────────────────────────
// Exercise Detail / Workout Screen
// ──────────────────────────────────────────────────────────────

class ExerciseDetailScreen extends StatefulWidget {
  final WorkoutExercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with TickerProviderStateMixin {
  // ── Workout state ──
  final List<SetLog> _setLogs = [];
  Timer? _ticker;
  DateTime? _startedAt;
  DateTime? _finishedAt;
  DateTime? _restEndsAt;
  bool _healthSynced = false;
  int _heartRate = 0;
  int _activeCalories = 0;

  // ── Animations ──
  late final AnimationController _pulseController;
  late final AnimationController _restRingController;

  // ── Computed getters ──
  bool get _hasStarted => _startedAt != null;
  bool get _isFinished => _finishedAt != null;
  bool get _allSetsLogged => _setLogs.length >= widget.exercise.sets;

  Duration get _elapsed {
    final start = _startedAt;
    if (start == null) return Duration.zero;
    return (_finishedAt ?? DateTime.now()).difference(start);
  }

  Duration get _restRemaining {
    final end = _restEndsAt;
    if (end == null) return Duration.zero;
    final remaining = end.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get _isResting => _restRemaining > Duration.zero;

  int get _totalVolume =>
      _setLogs.fold(0, (sum, log) => sum + (log.weight * log.reps).round());

  int get _estimatedCalories => (_elapsed.inSeconds / 60 * 7).round();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _restRingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    _restRingController.dispose();
    super.dispose();
  }

  // ── Actions ──

  void _startWorkout() {
    setState(() => _startedAt = DateTime.now());
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_restEndsAt != null && !_isResting) _restEndsAt = null;
      });
    });
    // Simulate health data polling
    if (_healthSynced) _startHealthPolling();
  }

  void _startHealthPolling() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _isFinished) {
        timer.cancel();
        return;
      }
      setState(() {
        _heartRate = 110 + Random().nextInt(50); // simulated
        _activeCalories += 2 + Random().nextInt(3);
      });
    });
  }

  Future<void> _logSet() async {
    if (!_hasStarted || _isFinished || _isResting) return;
    final setNumber = _setLogs.length + 1;
    final exercise = widget.exercise;
    final weightController = TextEditingController();
    final repsController = TextEditingController(text: '${exercise.reps}');
    final formKey = GlobalKey<FormState>();

    final log = await showModalBottomSheet<SetLog>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: DashboardGlassCard(
          borderRadius: 24,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgElevated, AppColors.bgSecondary],
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: exercise.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(exercise.icon,
                          color: exercise.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Log Set $setNumber',
                              style: AppTextStyles.titleMedium),
                          Text(exercise.name,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Previous set reference
                if (_setLogs.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.history_rounded,
                            color: AppColors.accentBlue, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Previous: ${_setLogs.last.weight.toStringAsFixed(_setLogs.last.weight % 1 == 0 ? 0 : 1)} kg × ${_setLogs.last.reps} reps',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.accentBlue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    Expanded(
                      child: _numberField(
                        controller: weightController,
                        label: 'Weight',
                        suffix: 'kg',
                        validator: (value) {
                          final amount = double.tryParse(value ?? '');
                          return amount == null || amount <= 0
                              ? 'Enter weight'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _numberField(
                        controller: repsController,
                        label: 'Reps',
                        validator: (value) {
                          final amount = int.tryParse(value ?? '');
                          return amount == null || amount <= 0
                              ? 'Enter reps'
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;
                      Navigator.pop(
                        ctx,
                        SetLog(
                          weight: double.parse(weightController.text),
                          reps: int.parse(repsController.text),
                          loggedAt: DateTime.now(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: Text('Save Set $setNumber'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: exercise.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    weightController.dispose();
    repsController.dispose();
    if (!mounted || log == null) return;

    final isLastSet = _setLogs.length + 1 >= widget.exercise.sets;
    setState(() {
      _setLogs.add(log);
      _restEndsAt = isLastSet
          ? null
          : DateTime.now()
              .add(Duration(seconds: widget.exercise.restSeconds));
    });
  }

  void _finishWorkout() {
    if (!_allSetsLogged) {
      final remaining = widget.exercise.sets - _setLogs.length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Log $remaining more ${remaining == 1 ? 'set' : 'sets'} to finish.'),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() {
      _finishedAt = DateTime.now();
      _ticker?.cancel();
      _restEndsAt = null;
    });
  }

  void _syncHealthData() {
    setState(() {
      _healthSynced = true;
      _heartRate = 72;
      _activeCalories = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Health data source connected (simulated).'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (_hasStarted && !_isFinished) _startHealthPolling();
  }

  // ── Formatters ──

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return hours > 0
        ? '${hours}h ${minutes.toString().padLeft(2, '0')}m'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatClock(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.titleMedium,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        labelStyle: AppTextStyles.caption,
        suffixStyle: AppTextStyles.caption
            .copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.bgPrimary.withValues(alpha: 0.65),
        errorStyle: AppTextStyles.caption
            .copyWith(color: AppColors.accentCoral),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.exercise.color),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: _isFinished ? _buildSummaryView() : _buildWorkoutView(),
    );
  }

  // ─── WORKOUT VIEW (before & during workout) ───

  Widget _buildWorkoutView() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Collapsing app bar with video tutorial ──
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: AppColors.bgSecondary,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary.withValues(alpha: 0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textPrimary, size: 20),
            ),
          ),
          actions: [
            if (_hasStarted && !_isFinished)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDuration(_elapsed),
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF22C55E),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildVideoTutorial(),
          ),
        ),

        // ── Body content ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Exercise info header
                _buildExerciseInfoHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.04, end: 0),
                const SizedBox(height: 18),

                // Quick stats
                _buildQuickStats()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 80.ms)
                    .slideY(begin: 0.04, end: 0),
                const SizedBox(height: 20),

                // Tips section
                if (widget.exercise.tips.isNotEmpty) ...[
                  _buildTipsCard()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 120.ms)
                      .slideY(begin: 0.04, end: 0),
                  const SizedBox(height: 20),
                ],

                // ── Workout action area ──
                if (!_hasStarted) ...[
                  _buildStartSection()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 160.ms)
                      .slideY(begin: 0.06, end: 0),
                ] else ...[
                  // Progress overview
                  _buildWorkoutProgress()
                      .animate()
                      .fadeIn(duration: 350.ms),
                  const SizedBox(height: 16),

                  // Rest timer overlay
                  if (_isResting) ...[
                    _buildRestTimerCard()
                        .animate()
                        .fadeIn(duration: 250.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
                    const SizedBox(height: 16),
                  ],

                  // Set logging cards
                  _sectionLabel('SET LOG'),
                  const SizedBox(height: 10),
                  _buildSetLogList(),
                  const SizedBox(height: 16),

                  // Log set button
                  if (!_allSetsLogged)
                    _buildLogSetButton()
                        .animate()
                        .fadeIn(duration: 300.ms),
                  const SizedBox(height: 16),

                  // Health data
                  if (_healthSynced) ...[
                    _buildHealthLiveCard(),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildHealthConnectPrompt(),
                    const SizedBox(height: 16),
                  ],

                  // Finish button
                  _buildFinishButton(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── VIDEO TUTORIAL ───

  Widget _buildVideoTutorial() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient background with exercise icon
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.exercise.color.withValues(alpha: 0.3),
                widget.exercise.color.withValues(alpha: 0.08),
                AppColors.bgSecondary,
              ],
            ),
          ),
        ),
        // Animated pattern overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _GridPatternPainter(
              color: widget.exercise.color.withValues(alpha: 0.05),
            ),
          ),
        ),
        // Center play icon and exercise visual
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Large exercise icon with glow
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.05);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.exercise.color
                            .withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.exercise.color
                                .withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.exercise.icon,
                        color: widget.exercise.color,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Play button overlay
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.exercise.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_circle_fill_rounded,
                        color: widget.exercise.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Watch Tutorial',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bottom gradient fade
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.bgSecondary.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── EXERCISE INFO HEADER ───

  Widget _buildExerciseInfoHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: widget.exercise.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.exercise.muscleGroup,
                style: AppTextStyles.caption.copyWith(
                  color: widget.exercise.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.exercise.difficulty,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.exercise.name,
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          widget.exercise.detail,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  // ─── QUICK STATS ───

  Widget _buildQuickStats() {
    return Row(
      children: [
        _statChip(Icons.repeat_rounded, '${widget.exercise.sets} sets',
            AppColors.accentBlue),
        const SizedBox(width: 10),
        _statChip(Icons.tag_rounded, '${widget.exercise.reps} reps',
            AppColors.accentPurple),
        const SizedBox(width: 10),
        _statChip(Icons.timer_outlined, '${widget.exercise.restSeconds}s rest',
            AppColors.accentOrange),
      ],
    );
  }

  Widget _statChip(IconData icon, String text, Color color) {
    return Expanded(
      child: DashboardGlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TIPS CARD ───

  Widget _buildTipsCard() {
    return DashboardGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentCyan.withValues(alpha: 0.08),
          AppColors.bgSecondary,
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded,
                  color: AppColors.accentCyan, size: 18),
              const SizedBox(width: 8),
              Text('Pro Tips',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ...widget.exercise.tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(tip,
                        style: AppTextStyles.bodyMedium
                            .copyWith(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── START SECTION (pre-workout) ───

  Widget _buildStartSection() {
    return Column(
      children: [
        // Decorative divider
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                widget.exercise.color.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Health connect card
        if (!_healthSynced) ...[
          _buildHealthConnectPrompt(),
          const SizedBox(height: 16),
        ] else ...[
          _buildHealthConnectedBadge(),
          const SizedBox(height: 16),
        ],

        // Start workout button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.exercise.color,
                widget.exercise.color.withValues(alpha: 0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.exercise.color.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: _startWorkout,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 26),
                    const SizedBox(width: 10),
                    Text(
                      'Start Workout',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Timer will begin when you tap start',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _adjustRestTime(int seconds) {
    if (_restEndsAt == null) return;
    setState(() {
      _restEndsAt = _restEndsAt!.add(Duration(seconds: seconds));
      if (!_isResting) _restEndsAt = null;
    });
  }

  // ─── WORKOUT PROGRESS (during workout) ───

  Widget _buildWorkoutProgress() {
    final progress = _setLogs.length / widget.exercise.sets;
    final nextSetNum = _setLogs.length + 1;
    return DashboardGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.exercise.color.withValues(alpha: 0.12),
          AppColors.bgSecondary,
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Radial progress
              RadialProgress(
                progress: progress,
                size: 64,
                strokeWidth: 5,
                progressColor: widget.exercise.color,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_setLogs.length}',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '/ ${widget.exercise.sets}',
                      style: AppTextStyles.caption.copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _allSetsLogged
                          ? 'All sets complete!'
                          : 'Set $nextSetNum of ${widget.exercise.sets}',
                      style: AppTextStyles.titleMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _isResting
                                ? AppColors.accentOrange
                                    .withValues(alpha: 0.15)
                                : widget.exercise.color
                                    .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isResting
                                ? 'Rest Period'
                                : _allSetsLogged
                                    ? 'Completed'
                                    : 'Set $nextSetNum Active',
                            style: AppTextStyles.caption.copyWith(
                              color: _isResting
                                  ? AppColors.accentOrange
                                  : widget.exercise.color,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.fitness_center_rounded,
                            color: AppColors.textTertiary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$_totalVolume kg',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressBar(
            progress: progress,
            color: widget.exercise.color,
            height: 4,
          ),
        ],
      ),
    );
  }

  // ─── REST TIMER ───

  Widget _buildRestTimerCard() {
    final remaining = _restRemaining;
    final total = widget.exercise.restSeconds;
    final elapsed = total - remaining.inSeconds;
    final progress = (elapsed / total).clamp(0.0, 1.0);
    final nextSetNum = _setLogs.length + 1;

    return DashboardGlassCard(
      borderRadius: 22,
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.accentOrange.withValues(alpha: 0.35),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentOrange.withValues(alpha: 0.12),
          AppColors.bgSecondary,
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Radial rest countdown
              RadialProgress(
                progress: progress,
                size: 72,
                strokeWidth: 5,
                progressColor: AppColors.accentOrange,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${remaining.inSeconds}',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      'sec rest',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 9,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            color: AppColors.accentOrange, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Resting for Set $nextSetNum',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Catch your breath and hydrate!',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _restAdjustBtn('-10s', () => _adjustRestTime(-10)),
                        const SizedBox(width: 6),
                        _restAdjustBtn('+15s', () => _adjustRestTime(15)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _restEndsAt = null),
                          icon: const Icon(Icons.skip_next_rounded, size: 16),
                          label: const Text('Skip rest'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.accentOrange,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _restAdjustBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.accentOrange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.accentOrange.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.accentOrange,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  // ─── SET LOG LIST ───

  Widget _buildSetLogList() {
    if (_setLogs.isEmpty) {
      return DashboardGlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.format_list_numbered_rounded,
                  color: AppColors.textTertiary, size: 28),
              const SizedBox(height: 8),
              Text(
                'No sets logged yet',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap "Log Set" below to record your first set',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: List.generate(_setLogs.length, (index) {
        final log = _setLogs[index];
        final setVolume = (log.weight * log.reps).round();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: DashboardGlassCard(
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            borderColor: const Color(0xFF22C55E).withValues(alpha: 0.2),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF22C55E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: const Color(0xFF22C55E),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${log.weight.toStringAsFixed(log.weight % 1 == 0 ? 0 : 1)} kg × ${log.reps} reps',
                        style: AppTextStyles.labelLarge
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Volume: $setVolume kg • ${_formatClock(log.loggedAt)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.check_circle_rounded,
                    color: const Color(0xFF22C55E), size: 20),
              ],
            ),
          ),
        ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideX(
            begin: 0.05, end: 0);
      }),
    );
  }

  // ─── LOG SET BUTTON ───

  Widget _buildLogSetButton() {
    final canLog = !_isResting && !_allSetsLogged;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: canLog
            ? LinearGradient(
                colors: [
                  widget.exercise.color,
                  widget.exercise.color.withValues(alpha: 0.75),
                ],
              )
            : null,
        color: canLog ? null : AppColors.bgElevated,
        boxShadow: canLog
            ? [
                BoxShadow(
                  color: widget.exercise.color.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: canLog ? _logSet : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canLog ? Icons.add_rounded : Icons.timer_outlined,
                  color: canLog ? Colors.white : AppColors.textTertiary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  canLog
                      ? 'Log Set ${_setLogs.length + 1}'
                      : 'Resting — wait to log next set',
                  style: AppTextStyles.labelLarge.copyWith(
                    color:
                        canLog ? Colors.white : AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEALTH CONNECT ───

  Widget _buildHealthConnectPrompt() {
    return DashboardGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      gradient: LinearGradient(
        colors: [
          AppColors.accentCoral.withValues(alpha: 0.06),
          AppColors.bgSecondary,
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.accentCoral.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite_border_rounded,
                color: AppColors.accentCoral, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sync health data',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Connect Health Connect or Apple Health for heart rate tracking.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _syncHealthData,
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthConnectedBadge() {
    return DashboardGlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderColor: const Color(0xFF22C55E).withValues(alpha: 0.2),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: const Color(0xFF22C55E), size: 18),
          const SizedBox(width: 8),
          Text(
            'Health data connected',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF22C55E),
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            'Heart rate & activity will sync',
            style: AppTextStyles.caption.copyWith(fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthLiveCard() {
    return DashboardGlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      borderColor: AppColors.accentCoral.withValues(alpha: 0.2),
      gradient: LinearGradient(
        colors: [
          AppColors.accentCoral.withValues(alpha: 0.06),
          AppColors.bgSecondary,
        ],
      ),
      child: Row(
        children: [
          // Heart rate
          Expanded(
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.15),
                      child: Icon(Icons.favorite_rounded,
                          color: AppColors.accentCoral, size: 22),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _heartRate > 0 ? '$_heartRate bpm' : '-- bpm',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.accentCoral,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text('Heart Rate', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.glassBorder,
          ),
          // Active calories
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_fire_department_rounded,
                    color: AppColors.accentOrange, size: 22),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_activeCalories kcal',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text('Active Cal', style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── FINISH BUTTON ───

  Widget _buildFinishButton() {
    final canFinish = _allSetsLogged;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: canFinish
            ? const LinearGradient(
                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
              )
            : null,
        color: canFinish ? null : AppColors.bgElevated,
        boxShadow: canFinish
            ? [
                BoxShadow(
                  color:
                      const Color(0xFF22C55E).withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _finishWorkout,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canFinish
                      ? Icons.check_rounded
                      : Icons.lock_outline_rounded,
                  color: canFinish ? Colors.white : AppColors.textTertiary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  canFinish
                      ? 'Finish Workout'
                      : 'Complete all sets to finish',
                  style: AppTextStyles.labelLarge.copyWith(
                    color:
                        canFinish ? Colors.white : AppColors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // SUMMARY VIEW (after workout)
  // ──────────────────────────────────────────────────────────────

  Widget _buildSummaryView() {
    final duration = _formatDuration(_elapsed);
    final avgWeight = _setLogs.isEmpty
        ? 0.0
        : _setLogs.fold(0.0, (sum, l) => sum + l.weight) / _setLogs.length;
    final totalReps =
        _setLogs.fold(0, (sum, l) => sum + l.reps);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          children: [
            // Confetti-style success header
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(0xFF22C55E).withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFF22C55E), size: 40),
            )
                .animate()
                .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 20),
            Text(
              'Workout Complete!',
              style: AppTextStyles.headlineMedium,
            ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
            const SizedBox(height: 6),
            Text(
              widget.exercise.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: widget.exercise.color,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 4),
            Text(
              '${_formatClock(_startedAt!)} – ${_formatClock(_finishedAt!)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
            const SizedBox(height: 28),

            // ── Stats grid ──
            Row(
              children: [
                _summaryStatCard(
                  Icons.timer_outlined,
                  duration,
                  'Duration',
                  AppColors.accentBlue,
                ),
                const SizedBox(width: 10),
                _summaryStatCard(
                  Icons.fitness_center_rounded,
                  '$_totalVolume kg',
                  'Total Volume',
                  AppColors.accentPurple,
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 300.ms)
                .slideY(begin: 0.06, end: 0),
            const SizedBox(height: 10),
            Row(
              children: [
                _summaryStatCard(
                  Icons.local_fire_department_rounded,
                  '$_estimatedCalories kcal',
                  'Est. Calories',
                  AppColors.accentOrange,
                ),
                const SizedBox(width: 10),
                _summaryStatCard(
                  Icons.repeat_rounded,
                  '$totalReps',
                  'Total Reps',
                  AppColors.accentCyan,
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 350.ms)
                .slideY(begin: 0.06, end: 0),
            const SizedBox(height: 10),
            Row(
              children: [
                _summaryStatCard(
                  Icons.scale_rounded,
                  '${avgWeight.toStringAsFixed(1)} kg',
                  'Avg Weight',
                  AppColors.accentCoral,
                ),
                const SizedBox(width: 10),
                _summaryStatCard(
                  Icons.format_list_numbered_rounded,
                  '${_setLogs.length}',
                  'Sets Completed',
                  const Color(0xFF22C55E),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.06, end: 0),

            // ── Health data summary ──
            if (_healthSynced) ...[
              const SizedBox(height: 20),
              DashboardGlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(16),
                borderColor:
                    AppColors.accentCoral.withValues(alpha: 0.2),
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentCoral.withValues(alpha: 0.08),
                    AppColors.bgSecondary,
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monitor_heart_rounded,
                            color: AppColors.accentCoral, size: 18),
                        const SizedBox(width: 8),
                        Text('Health Data Summary',
                            style: AppTextStyles.labelLarge
                                .copyWith(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _healthSummaryItem(
                            Icons.favorite_rounded,
                            'Avg HR',
                            '${_heartRate > 0 ? _heartRate : '--'} bpm',
                            AppColors.accentCoral,
                          ),
                        ),
                        Expanded(
                          child: _healthSummaryItem(
                            Icons.local_fire_department_rounded,
                            'Active Cal',
                            '$_activeCalories kcal',
                            AppColors.accentOrange,
                          ),
                        ),
                        Expanded(
                          child: _healthSummaryItem(
                            Icons.directions_walk_rounded,
                            'Activity',
                            'Strength',
                            AppColors.accentBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 450.ms)
                  .slideY(begin: 0.04, end: 0),
            ],

            // ── Set-by-set breakdown ──
            const SizedBox(height: 24),
            _sectionLabel('SET BREAKDOWN'),
            const SizedBox(height: 10),
            ...List.generate(_setLogs.length, (index) {
              final log = _setLogs[index];
              final vol = (log.weight * log.reps).round();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DashboardGlassCard(
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: widget.exercise.color
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: widget.exercise.color,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${log.weight.toStringAsFixed(log.weight % 1 == 0 ? 0 : 1)} kg × ${log.reps} reps',
                          style: AppTextStyles.labelLarge
                              .copyWith(fontSize: 13),
                        ),
                      ),
                      Text(
                        '$vol kg',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatClock(log.loggedAt),
                        style: AppTextStyles.caption
                            .copyWith(fontSize: 9),
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: (500 + index * 60).ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.04, end: 0);
            }),

            const SizedBox(height: 24),

            // ── Done button ──
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Back to Exercises'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.bgElevated,
                  foregroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryStatCard(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: DashboardGlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.1),
            AppColors.bgSecondary,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }

  Widget _healthSummaryItem(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.labelLarge
              .copyWith(fontSize: 12, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(label,
            style: AppTextStyles.caption.copyWith(fontSize: 9),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: AppTextStyles.caption.copyWith(
          letterSpacing: 1.2,
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w700,
        ),
      );
}

// ──────────────────────────────────────────────────────────────
// Grid pattern painter for video tutorial background
// ──────────────────────────────────────────────────────────────

class _GridPatternPainter extends CustomPainter {
  final Color color;

  _GridPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}
