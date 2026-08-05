import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import '../widgets/linear_progress_bar.dart';
import '../widgets/radial_progress.dart';

// ──────────────────────────────────────────────────────────────
// Shared Data Models
// ──────────────────────────────────────────────────────────────

class WorkoutExercise {
  final String name;
  final String detail;
  final int sets;
  final int reps;
  final int restSeconds;
  final IconData icon;
  final Color color;
  final String? videoUrl;
  final String muscleGroup;
  final String difficulty;
  final String equipment;
  final double defaultWeight;
  final String tempo;
  final List<String> tips;
  final List<String> commonMistakes;

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
    this.equipment = 'Barbell',
    this.defaultWeight = 20.0,
    this.tempo = '3-0-1-0',
    this.tips = const [],
    this.commonMistakes = const [],
  });
}

class SetLog {
  final double weight;
  final int reps;
  final DateTime loggedAt;
  final String setType; // 'Warmup', 'Working', 'PR Attempt'

  const SetLog({
    required this.weight,
    required this.reps,
    required this.loggedAt,
    this.setType = 'Working',
  });
}

// ──────────────────────────────────────────────────────────────
// Exercise Detail & Interactive Workout Screen
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
  int _selectedRpe = 3;
  int _headerTab = 0; // 0: Form Guide, 1: Muscle Map, 2: Tempo Guide

  // ── Animations ──
  late final AnimationController _pulseController;

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

  int get _estimatedCalories =>
      max(45, (_elapsed.inSeconds / 60 * 7.5).round());

  double get _maxWeightLifted => _setLogs.isEmpty
      ? 0.0
      : _setLogs.fold(0.0, (maxW, l) => l.weight > maxW ? l.weight : maxW);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
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
    if (_healthSynced) _startHealthPolling();
  }

  void _startHealthPolling() {
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || _isFinished) {
        timer.cancel();
        return;
      }
      setState(() {
        _heartRate = 118 + Random().nextInt(35);
        _activeCalories += 2 + Random().nextInt(3);
      });
    });
  }

  Future<void> _logSet() async {
    if (!_hasStarted || _isFinished || _isResting) return;
    final setNumber = _setLogs.length + 1;
    final exercise = widget.exercise;
    final previousLog = _setLogs.isNotEmpty ? _setLogs.last : null;

    final log = await showModalBottomSheet<SetLog>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _LogSetBottomSheet(
        setNumber: setNumber,
        exercise: exercise,
        previousLog: previousLog,
      ),
    );

    if (!mounted || log == null) return;

    final isLastSet = _setLogs.length + 1 >= widget.exercise.sets;
    setState(() {
      _setLogs.add(log);
      _restEndsAt = isLastSet || widget.exercise.restSeconds <= 0
          ? null
          : DateTime.now().add(Duration(seconds: widget.exercise.restSeconds));
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      _heartRate = 84;
      _activeCalories = 12;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Health Connect synced (simulated).'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    if (_hasStarted && !_isFinished) _startHealthPolling();
  }

  void _adjustRestTime(int seconds) {
    if (_restEndsAt == null) return;
    setState(() {
      _restEndsAt = _restEndsAt!.add(Duration(seconds: seconds));
      if (!_isResting) _restEndsAt = null;
    });
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

  // ─── WORKOUT VIEW ───

  Widget _buildWorkoutView() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 270,
          pinned: true,
          backgroundColor: AppColors.bgSecondary,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgPrimary.withValues(alpha: 0.75),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder),
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
                  border: Border.all(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.3)),
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
            background: _buildInteractiveHeroHeader(),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExerciseInfoHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.04, end: 0),
                const SizedBox(height: 18),

                _buildQuickStats()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 80.ms)
                    .slideY(begin: 0.04, end: 0),
                const SizedBox(height: 18),

                // Form Check & Technique card
                _buildTechniqueCard()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 120.ms)
                    .slideY(begin: 0.04, end: 0),
                const SizedBox(height: 20),

                if (!_hasStarted) ...[
                  _buildStartSection()
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 160.ms)
                      .slideY(begin: 0.06, end: 0),
                ] else ...[
                  _buildWorkoutProgress().animate().fadeIn(duration: 350.ms),
                  const SizedBox(height: 16),

                  if (_isResting) ...[
                    _buildRestTimerCard()
                        .animate()
                        .fadeIn(duration: 250.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
                    const SizedBox(height: 16),
                  ],

                  _sectionLabel('ACTIVE SET TRACKER (${_setLogs.length}/${widget.exercise.sets})'),
                  const SizedBox(height: 10),
                  _buildSetLogList(),
                  const SizedBox(height: 16),

                  if (!_allSetsLogged)
                    _buildLogSetButton().animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: 16),

                  if (_healthSynced) ...[
                    _buildHealthLiveCard(),
                    const SizedBox(height: 16),
                  ] else ...[
                    _buildHealthConnectPrompt(),
                    const SizedBox(height: 16),
                  ],

                  _buildFinishButton(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── INTERACTIVE HERO HEADER ───

  Widget _buildInteractiveHeroHeader() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Ambient Gradient Backlight
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.exercise.color.withValues(alpha: 0.35),
                widget.exercise.color.withValues(alpha: 0.1),
                AppColors.bgSecondary,
              ],
            ),
          ),
        ),

        Positioned.fill(
          child: CustomPaint(
            painter: _GridPatternPainter(
              color: widget.exercise.color.withValues(alpha: 0.06),
            ),
          ),
        ),

        // Hero Content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 28),

              // Dynamic Pulsing Exercise Badge
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
                        color: widget.exercise.color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.exercise.color.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: widget.exercise.color.withValues(alpha: 0.3),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.exercise.icon,
                        color: widget.exercise.color,
                        size: 38,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              // Segmented Feature Pills
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgPrimary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.exercise.color.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _headerTabPill('Form Guide', 0),
                    _headerTabPill('Muscle Map', 1),
                    _headerTabPill('Tempo', 2),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom blend gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 45,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.bgSecondary.withValues(alpha: 0.95),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerTabPill(String label, int index) {
    final isSel = _headerTab == index;
    return InkWell(
      onTap: () => setState(() => _headerTab = index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSel ? widget.exercise.color : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSel ? Colors.white : AppColors.textSecondary,
            fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
            fontSize: 11,
          ),
        ),
      ),
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
                color: widget.exercise.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Target: ${widget.exercise.muscleGroup}',
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
                color: AppColors.accentOrange.withValues(alpha: 0.14),
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
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Text(
                'Tempo: ${widget.exercise.tempo}',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          widget.exercise.name,
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w800,
          ),
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
        const SizedBox(width: 10),
        _statChip(Icons.fitness_center_rounded, widget.exercise.equipment,
            AppColors.accentCyan),
      ],
    );
  }

  Widget _statChip(IconData icon, String text, Color color) {
    return Expanded(
      child: DashboardGlassCard(
        borderRadius: 14,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              text,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── TECHNIQUE CARD (Dynamic based on Tab) ───

  Widget _buildTechniqueCard() {
    if (_headerTab == 1) {
      // Muscle Engagement Breakdown
      return DashboardGlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentPurple.withValues(alpha: 0.1),
            AppColors.bgSecondary,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.accessibility_new_rounded,
                    color: AppColors.accentPurple, size: 18),
                const SizedBox(width: 8),
                Text('Muscle Engagement Breakdown',
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            _muscleBar('Primary (${widget.exercise.muscleGroup})', 0.85,
                widget.exercise.color),
            const SizedBox(height: 8),
            _muscleBar('Secondary (Stabilizers & Core)', 0.40, AppColors.accentCyan),
          ],
        ),
      );
    } else if (_headerTab == 2) {
      // Tempo Guide
      return DashboardGlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentOrange.withValues(alpha: 0.1),
            AppColors.bgSecondary,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed_rounded,
                    color: AppColors.accentOrange, size: 18),
                const SizedBox(width: 8),
                Text('Tempo Rhythm: ${widget.exercise.tempo}',
                    style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '• 3s Eccentric: Lower weight under complete control.\n'
              '• 0s Pause: No rest at bottom; reverse movement.\n'
              '• 1s Concentric: Drive weight up rapidly.\n'
              '• 0s Top: Squeeze muscle target at lockout.',
              style: AppTextStyles.caption.copyWith(height: 1.4, fontSize: 11),
            ),
          ],
        ),
      );
    }

    // Default: Form Execution Tips
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
              const Icon(Icons.checklist_rtl_rounded,
                  color: AppColors.accentCyan, size: 18),
              const SizedBox(width: 8),
              Text('Trainer Execution Checkpoints',
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
                    decoration: const BoxDecoration(
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

  Widget _muscleBar(String label, double fill, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
            Text('${(fill * 100).round()}%',
                style: AppTextStyles.caption.copyWith(
                    color: color, fontWeight: FontWeight.w700, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressBar(progress: fill, color: color, height: 5),
      ],
    );
  }

  // ─── START SECTION ───

  Widget _buildStartSection() {
    return Column(
      children: [
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

        if (!_healthSynced) ...[
          _buildHealthConnectPrompt(),
          const SizedBox(height: 16),
        ] else ...[
          _buildHealthConnectedBadge(),
          const SizedBox(height: 16),
        ],

        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.exercise.color,
                widget.exercise.color.withValues(alpha: 0.75),
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
                      'Start Exercise Session',
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
          'Timer will start immediately on tap',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ─── WORKOUT PROGRESS ───

  Widget _buildWorkoutProgress() {
    final totalSets = widget.exercise.sets;
    final progress = totalSets > 0
        ? (_setLogs.length / totalSets).clamp(0.0, 1.0)
        : 0.0;
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
                                ? AppColors.accentOrange.withValues(alpha: 0.15)
                                : widget.exercise.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isResting
                                ? 'Resting'
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
                        const Icon(Icons.fitness_center_rounded,
                            color: AppColors.textTertiary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$_totalVolume kg total',
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
    final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 1.0;
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
      child: Row(
        children: [
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
                    const Icon(Icons.timer_outlined,
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
                  'Hydrate & catch your breath',
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
                      onPressed: () => setState(() => _restEndsAt = null),
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
              const Icon(Icons.format_list_numbered_rounded,
                  color: AppColors.textTertiary, size: 28),
              const SizedBox(height: 8),
              Text(
                'No sets recorded yet',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap "Log Set 1" below to start',
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            borderColor: const Color(0xFF22C55E).withValues(alpha: 0.25),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.12),
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
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF22C55E), size: 20),
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
                      : 'Resting — wait for rest timer',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: canLog ? Colors.white : AppColors.textTertiary,
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
                  'Sync Health Connect',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Connect wearable for heart rate & active calorie tracking.',
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
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFF22C55E), size: 18),
          const SizedBox(width: 8),
          Text(
            'Health Connect active',
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF22C55E),
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            'Syncing live metrics',
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
          Expanded(
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.15),
                      child: const Icon(Icons.favorite_rounded,
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_rounded,
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
                  color: const Color(0xFF22C55E).withValues(alpha: 0.35),
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
                      ? 'Finish & View Summary'
                      : 'Complete all sets to finish',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: canFinish ? Colors.white : AppColors.textTertiary,
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
  // PREMIUM HIGH-IMPACT EXERCISE COMPLETION / SUMMARY VIEW
  // ──────────────────────────────────────────────────────────────

  Widget _buildSummaryView() {
    final duration = _formatDuration(_elapsed);
    final avgWeight = _setLogs.isEmpty
        ? 0.0
        : _setLogs.fold(0.0, (sum, l) => sum + l.weight) / _setLogs.length;
    final totalReps = _setLogs.fold(0, (sum, l) => sum + l.reps);

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(Icons.close_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'SESSION SUMMARY',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Workout summary copied for sharing!'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(Icons.ios_share_rounded,
                          color: AppColors.textPrimary, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeroVictoryCard()
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: 20),

                _buildAchievementBanner()
                    .animate()
                    .fadeIn(duration: 450.ms, delay: 100.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: 20),

                _sectionLabel('PERFORMANCE HIGHLIGHTS'),
                const SizedBox(height: 10),
                _buildPerformanceBentoGrid(
                  duration: duration,
                  totalVolume: _totalVolume,
                  calories: _estimatedCalories,
                  totalReps: totalReps,
                  maxWeight: _maxWeightLifted,
                  avgWeight: avgWeight,
                )
                    .animate()
                    .fadeIn(duration: 450.ms, delay: 160.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: 24),

                if (_setLogs.isNotEmpty) ...[
                  _sectionLabel('SET VOLUME LOAD DISTRIBUTION'),
                  const SizedBox(height: 10),
                  _buildSetLoadChart()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 220.ms),
                  const SizedBox(height: 24),
                ],

                if (_healthSynced) ...[
                  _buildHealthSummaryCard()
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 280.ms),
                  const SizedBox(height: 24),
                ],

                _buildRpeRatingSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 320.ms),
                const SizedBox(height: 24),

                _buildRecoveryCard()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 380.ms),
                const SizedBox(height: 28),

                _sectionLabel('DETAILED SET LOGS'),
                const SizedBox(height: 10),
                ...List.generate(_setLogs.length, (index) {
                  final log = _setLogs[index];
                  final setVol = (log.weight * log.reps).round();
                  final isMaxWeightSet = log.weight == _maxWeightLifted && _maxWeightLifted > 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: DashboardGlassCard(
                      borderRadius: 14,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      borderColor: isMaxWeightSet
                          ? AppColors.accentCyan.withValues(alpha: 0.3)
                          : null,
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: widget.exercise.color.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(9),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${log.weight.toStringAsFixed(log.weight % 1 == 0 ? 0 : 1)} kg × ${log.reps} reps',
                                      style: AppTextStyles.labelLarge
                                          .copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    if (isMaxWeightSet) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.accentCyan
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'Top Weight',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.accentCyan,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Set Volume: $setVol kg • ${_formatClock(log.loggedAt)}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF22C55E), size: 18),
                        ],
                      ),
                    ),
                  ).animate(delay: (400 + index * 50).ms).fadeIn(duration: 300.ms);
                }),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: AppColors.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Return to Workout Plan',
                                style: AppTextStyles.labelLarge.copyWith(
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
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HERO VICTORY CARD ───

  Widget _buildHeroVictoryCard() {
    return DashboardGlassCard(
      borderRadius: 26,
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          widget.exercise.color.withValues(alpha: 0.2),
          AppColors.accentPurple.withValues(alpha: 0.1),
          AppColors.bgSecondary,
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF22C55E).withValues(alpha: 0.25),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(Icons.emoji_events_rounded,
                    color: Color(0xFF22C55E), size: 36),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.elasticOut)
                  .fadeIn(duration: 300.ms),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'EXERCISE COMPLETED',
            style: AppTextStyles.caption.copyWith(
              letterSpacing: 2.0,
              color: const Color(0xFF22C55E),
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.exercise.name,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Logged ${_setLogs.length} sets • ${_startedAt != null ? _formatClock(_startedAt!) : ''} - ${_finishedAt != null ? _formatClock(_finishedAt!) : ''}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── PR & XP ACHIEVEMENT BANNER ───

  Widget _buildAchievementBanner() {
    return DashboardGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.accentCyan.withValues(alpha: 0.3),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentCyan.withValues(alpha: 0.12),
          AppColors.accentBlue.withValues(alpha: 0.05),
          AppColors.bgSecondary,
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accentCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.bolt_rounded,
                color: AppColors.accentCyan, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Session Target Achieved!',
                      style: AppTextStyles.labelLarge
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '+120 XP',
                        style: AppTextStyles.caption.copyWith(
                          color: const Color(0xFF22C55E),
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Great progressive overload! You completed all ${widget.exercise.sets} sets as planned.',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── BENTO PERFORMANCE STATS GRID ───

  Widget _buildPerformanceBentoGrid({
    required String duration,
    required int totalVolume,
    required int calories,
    required int totalReps,
    required double maxWeight,
    required double avgWeight,
  }) {
    return Column(
      children: [
        Row(
          children: [
            _bentoStatCard(
              icon: Icons.timer_outlined,
              value: duration,
              label: 'Duration',
              sublabel: 'Active effort',
              color: AppColors.accentBlue,
            ),
            const SizedBox(width: 10),
            _bentoStatCard(
              icon: Icons.fitness_center_rounded,
              value: '$totalVolume kg',
              label: 'Total Volume',
              sublabel: 'Weight × reps',
              color: AppColors.accentPurple,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _bentoStatCard(
              icon: Icons.local_fire_department_rounded,
              value: '$calories kcal',
              label: 'Est. Calorie Burn',
              sublabel: '7.5 kcal/min avg',
              color: AppColors.accentOrange,
            ),
            const SizedBox(width: 10),
            _bentoStatCard(
              icon: Icons.repeat_rounded,
              value: '$totalReps reps',
              label: 'Total Reps',
              sublabel: '${_setLogs.length} sets completed',
              color: AppColors.accentCyan,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _bentoStatCard(
              icon: Icons.upload_rounded,
              value: '${maxWeight.toStringAsFixed(maxWeight % 1 == 0 ? 0 : 1)} kg',
              label: 'Max Weight',
              sublabel: 'Peak load lifted',
              color: AppColors.accentCoral,
            ),
            const SizedBox(width: 10),
            _bentoStatCard(
              icon: Icons.scale_rounded,
              value: '${avgWeight.toStringAsFixed(1)} kg',
              label: 'Avg Load / Set',
              sublabel: 'Consistent intensity',
              color: const Color(0xFF22C55E),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bentoStatCard({
    required IconData icon,
    required String value,
    required String label,
    required String sublabel,
    required Color color,
  }) {
    return Expanded(
      child: DashboardGlassCard(
        borderRadius: 18,
        padding: const EdgeInsets.all(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            AppColors.bgSecondary,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelLarge
                  .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              sublabel,
              style: AppTextStyles.caption
                  .copyWith(fontSize: 10, color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  // ─── SET VOLUME LOAD DISTRIBUTION CHART ───

  Widget _buildSetLoadChart() {
    final maxVol = _setLogs.fold<int>(
        1, (maxV, l) => max(maxV, (l.weight * l.reps).round()));

    return DashboardGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  color: AppColors.accentPurple, size: 20),
              const SizedBox(width: 8),
              Text(
                'Volume Load Per Set',
                style: AppTextStyles.labelLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_setLogs.length, (i) {
                final log = _setLogs[i];
                final vol = (log.weight * log.reps).round();
                final heightFactor = (vol / maxVol).clamp(0.15, 1.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$vol',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FractionallySizedBox(
                          heightFactor: heightFactor,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  widget.exercise.color,
                                  widget.exercise.color.withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Set ${i + 1}',
                          style: AppTextStyles.caption.copyWith(fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEALTH SUMMARY CARD ───

  Widget _buildHealthSummaryCard() {
    return DashboardGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.accentCoral.withValues(alpha: 0.25),
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
              const Icon(Icons.monitor_heart_rounded,
                  color: AppColors.accentCoral, size: 18),
              const SizedBox(width: 8),
              Text('Health & Biometrics',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _healthSummaryItem(
                  Icons.favorite_rounded,
                  'Avg Heart Rate',
                  '${_heartRate > 0 ? _heartRate : 124} bpm',
                  AppColors.accentCoral,
                ),
              ),
              Expanded(
                child: _healthSummaryItem(
                  Icons.local_fire_department_rounded,
                  'Active Energy',
                  '$_activeCalories kcal',
                  AppColors.accentOrange,
                ),
              ),
              Expanded(
                child: _healthSummaryItem(
                  Icons.directions_run_rounded,
                  'Intensity Zone',
                  'Hypertrophy',
                  AppColors.accentBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── RPE EFFORT RATING SECTION ───

  Widget _buildRpeRatingSection() {
    final rpeLabels = ['Light', 'Moderate', 'Hard', 'Max Effort'];
    final rpeColors = [
      AppColors.accentCyan,
      AppColors.accentBlue,
      AppColors.accentOrange,
      AppColors.accentCoral,
    ];

    return DashboardGlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate Workout Perceived Exertion (RPE)',
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'How demanding was this exercise on a scale of 1-4?',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(4, (i) {
              final val = i + 1;
              final isSel = _selectedRpe == val;
              final color = rpeColors[i];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _selectedRpe = val),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSel
                            ? color.withValues(alpha: 0.2)
                            : AppColors.bgPrimary.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSel ? color : AppColors.glassBorder,
                          width: isSel ? 1.5 : 1.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$val',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isSel ? color : AppColors.textSecondary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rpeLabels[i],
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9,
                              color: isSel ? color : AppColors.textTertiary,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── PRO RECOVERY CARD ───

  Widget _buildRecoveryCard() {
    return DashboardGlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.accentBlue.withValues(alpha: 0.08),
          AppColors.bgSecondary,
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.water_drop_rounded,
                color: AppColors.accentBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Post-Workout Recovery Tip',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Drink 500 ml of water & consume 25-30g protein within 45 mins to optimize muscle repair.',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
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
// Stateful Log Set Modal Bottom Sheet Widget
// Solves controller lifecycle & premature disposal assertion errors.
// ──────────────────────────────────────────────────────────────

class _LogSetBottomSheet extends StatefulWidget {
  final int setNumber;
  final WorkoutExercise exercise;
  final SetLog? previousLog;

  const _LogSetBottomSheet({
    required this.setNumber,
    required this.exercise,
    this.previousLog,
  });

  @override
  State<_LogSetBottomSheet> createState() => _LogSetBottomSheetState();
}

class _LogSetBottomSheetState extends State<_LogSetBottomSheet> {
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final double initialWeight =
        widget.previousLog?.weight ?? widget.exercise.defaultWeight;
    final int initialReps = widget.exercise.reps;

    _weightController = TextEditingController(
      text: initialWeight.toStringAsFixed(initialWeight % 1 == 0 ? 0 : 1),
    );
    _repsController = TextEditingController(text: '$initialReps');
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _updateWeight(double delta) {
    final current =
        double.tryParse(_weightController.text) ?? widget.exercise.defaultWeight;
    final updated = (current + delta).clamp(0.0, 999.0);
    setState(() {
      _weightController.text =
          updated.toStringAsFixed(updated % 1 == 0 ? 0 : 1);
    });
  }

  void _updateReps(int delta) {
    final current =
        int.tryParse(_repsController.text) ?? widget.exercise.reps;
    final updated = (current + delta).clamp(1, 999);
    setState(() {
      _repsController.text = '$updated';
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final weight =
        double.tryParse(_weightController.text) ?? widget.exercise.defaultWeight;
    final reps = int.tryParse(_repsController.text) ?? widget.exercise.reps;
    Navigator.of(context).pop(SetLog(
      weight: weight,
      reps: reps,
      loggedAt: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: DashboardGlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.bgElevated, AppColors.bgSecondary],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: exercise.color.withValues(alpha: 0.14),
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
                        Text('Log Set ${widget.setNumber} of ${exercise.sets}',
                            style: AppTextStyles.titleMedium
                                .copyWith(fontWeight: FontWeight.w700)),
                        Text(exercise.name, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (widget.previousLog != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.accentBlue.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.history_rounded,
                          color: AppColors.accentBlue, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Previous Set: ${widget.previousLog!.weight.toStringAsFixed(widget.previousLog!.weight % 1 == 0 ? 0 : 1)} kg × ${widget.previousLog!.reps} reps',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.accentBlue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Weight Input Row with +/- Step Buttons
              Text('Weight (kg)', style: AppTextStyles.caption),
              const SizedBox(height: 6),
              Row(
                children: [
                  _stepBtn('-5', () => _updateWeight(-5)),
                  const SizedBox(width: 4),
                  _stepBtn('-2.5', () => _updateWeight(-2.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge
                          .copyWith(fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.bgPrimary.withValues(alpha: 0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.glassBorder),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      validator: (v) {
                        final d = double.tryParse(v ?? '');
                        return (d == null || d <= 0) ? 'Required' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _stepBtn('+2.5', () => _updateWeight(2.5)),
                  const SizedBox(width: 4),
                  _stepBtn('+5', () => _updateWeight(5)),
                ],
              ),
              const SizedBox(height: 14),

              // Reps Input Row with +/- Step Buttons
              Text('Reps', style: AppTextStyles.caption),
              const SizedBox(height: 6),
              Row(
                children: [
                  _stepBtn('-2', () => _updateReps(-2)),
                  const SizedBox(width: 4),
                  _stepBtn('-1', () => _updateReps(-1)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.titleLarge
                          .copyWith(fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.bgPrimary.withValues(alpha: 0.7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.glassBorder),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      validator: (v) {
                        final d = int.tryParse(v ?? '');
                        return (d == null || d <= 0) ? 'Required' : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  _stepBtn('+1', () => _updateReps(1)),
                  const SizedBox(width: 4),
                  _stepBtn('+2', () => _updateReps(2)),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check_rounded),
                  label: Text('Save Set ${widget.setNumber}'),
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
    );
  }

  Widget _stepBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

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
