import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_trainer.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/sheet_chrome.dart';
import '../../dashboard/widgets/state_views.dart';
import 'add_member_screen.dart';

class GymOwnerTrainersScreen extends ConsumerStatefulWidget {
  const GymOwnerTrainersScreen({super.key});

  @override
  ConsumerState<GymOwnerTrainersScreen> createState() => _GymOwnerTrainersScreenState();
}

class _GymOwnerTrainersScreenState extends ConsumerState<GymOwnerTrainersScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<GymTrainer> _liveTrainers = [];
  bool _trainersLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrainers();
    });
  }

  Future<void> _loadTrainers() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null || gymId.isEmpty) {
      if (mounted) setState(() => _trainersLoading = false);
      return;
    }

    setState(() => _trainersLoading = true);

    try {
      final service = ref.read(gymOwnerServiceProvider);
      final trainers = await service.getTrainersRoster(gymId);
      if (mounted) {
        setState(() {
          _liveTrainers = trainers;
          _trainersLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _trainersLoading = false);
    }
  }

  List<GymTrainer> get _filteredTrainers {
    if (_searchQuery.isEmpty) return _liveTrainers;
    final query = _searchQuery.toLowerCase();
    return _liveTrainers.where((t) {
      return t.name.toLowerCase().contains(query) ||
          t.specialization.toLowerCase().contains(query);
    }).toList();
  }

  String _initialsFor(String name) {
    final initials = name
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join('')
        .toUpperCase();
    return initials.isNotEmpty ? initials : 'T';
  }

  List<Color> _gradientFor(String seed) {
    const palettes = [
      [AppColors.accentPurple, AppColors.accentCoral],
      [AppColors.accentBlue, AppColors.accentCyan],
      [AppColors.accentOrange, AppColors.accentPurple],
    ];
    return palettes[seed.hashCode.abs() % palettes.length];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTrainers;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // ── Ambient glows ──
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentPurple.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentBlue.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content ──
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Top Bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
                    child: Row(
                      children: [
                        // Back button
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.glassBg,
                              border: Border.all(
                                  color: AppColors.glassBorder),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textSecondary,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Header badge
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.accentPurple,
                                Color(0xFFA855F7),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.fitness_center_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trainers Management',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_liveTrainers.length} trainers',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: -0.05, end: 0, duration: 500.ms),
                ),

                // ── Search Bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: _buildSearchBar(),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 100.ms)
                      .slideY(begin: 0.05, end: 0, duration: 500.ms,
                          delay: 100.ms),
                ),

                // ── Summary Stats Row ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _buildSummaryStats(),
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: 180.ms)
                      .slideY(begin: 0.05, end: 0, duration: 500.ms,
                          delay: 180.ms),
                ),

                // ── Filtered Count ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 20, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.accentPurple
                                .withValues(alpha: 0.08),
                            border: Border.all(
                              color: AppColors.accentPurple
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                          child: Text(
                            'Showing ${filtered.length} of ${_liveTrainers.length} trainers',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accentPurple,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 250.ms),
                ),

                // ── Loading State ──
                if (_trainersLoading)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.accentPurple),
                      ),
                    ),
                  ),

                // ── Empty State ──
                if (!_trainersLoading && filtered.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_search_rounded,
                              color: AppColors.textTertiary
                                  .withValues(alpha: 0.4),
                              size: 56,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No trainers found',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your search',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textDisabled,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 300.ms),
                  ),

                // ── Trainer Cards ──
                if (!_trainersLoading && filtered.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _buildTrainerCard(filtered[index])
                                .animate()
                                .fadeIn(
                                    duration: 400.ms,
                                    delay: Duration(
                                        milliseconds: 300 + index * 50))
                                .slideY(
                                    begin: 0.04,
                                    end: 0,
                                    duration: 400.ms,
                                    delay: Duration(
                                        milliseconds: 300 + index * 50)),
                          );
                        },
                        childCount: filtered.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Floating Action Button ──
          Positioned(
            bottom: 24,
            right: 20,
            child: _buildFAB()
                .animate()
                .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    delay: 600.ms,
                    curve: Curves.elasticOut),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  SEARCH BAR
  // ═══════════════════════════════════════════════

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Search by name or specialization...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  SUMMARY STATS
  // ═══════════════════════════════════════════════

  Widget _buildSummaryStats() {
    final trainers = _filteredTrainers;
    final totalClients = trainers.fold<int>(0, (sum, t) => sum + t.activeClientsCount);
    final activeCount = trainers.where((t) => t.status == 'ACTIVE').length;
    final rated = trainers.where((t) => t.clientCheckInRate7dPercent != null).toList();
    final avgCheckIn = rated.isEmpty
        ? null
        : rated.fold<double>(0, (sum, t) => sum + t.clientCheckInRate7dPercent!) / rated.length;

    return Row(
      children: [
        _buildMiniStat(
          icon: Icons.people_outline_rounded,
          value: '$totalClients',
          label: 'Total Clients',
          color: AppColors.accentBlue,
        ),
        const SizedBox(width: 10),
        _buildMiniStat(
          icon: Icons.circle,
          value: '$activeCount',
          label: 'Active',
          color: AppColors.accentCyan,
          iconSize: 10,
        ),
        const SizedBox(width: 10),
        _buildMiniStat(
          icon: Icons.check_circle_outline_rounded,
          value: avgCheckIn == null ? '—' : '${avgCheckIn.toStringAsFixed(0)}%',
          label: 'Avg 7d Check-in',
          color: AppColors.accentOrange,
        ),
      ],
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    double iconSize = 14,
  }) {
    return Expanded(
      child: DashboardGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderRadius: 14,
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                color: color.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Icon(icon, color: color, size: iconSize),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  TRAINER CARD
  // ═══════════════════════════════════════════════

  Widget _buildTrainerCard(GymTrainer trainer) {
    final gradientColors = _gradientFor(trainer.trainerId);
    final isActive = trainer.status == 'ACTIVE';
    final isVerified = trainer.isVerified;
    final name = trainer.name.isNotEmpty ? trainer.name : 'Trainer';

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        children: [
          // ── Top Row: Avatar + Info + Online Status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _initialsFor(name),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  // Active status dot
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.accentCyan
                            : AppColors.textDisabled,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.bgPrimary,
                          width: 2.5,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: AppColors.accentCyan
                                      .withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Name + Specialization + Shift schedule
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row with real verification badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.accentOrange
                                      .withValues(alpha: 0.15),
                                  const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.1),
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.accentOrange
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.accentOrange,
                                  size: 10,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.accentOrange,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Specialization
                    Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: AppColors.textTertiary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trainer.specialization,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Real shift schedule (no fake "experience"/"join date")
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: AppColors.textTertiary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            trainer.shiftSchedule ?? 'No shift schedule set',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
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

          // ── Statistics Row (all real, backend-sourced values) ──
          Row(
            children: [
              _buildStatItem(
                icon: Icons.people_outline_rounded,
                value: '${trainer.activeClientsCount}',
                label: 'Clients',
                color: AppColors.accentBlue,
              ),
              const SizedBox(width: 8),
              _buildStatItem(
                icon: Icons.check_circle_outline_rounded,
                value: trainer.clientCheckInRate7dPercent != null
                    ? '${trainer.clientCheckInRate7dPercent!.toStringAsFixed(0)}%'
                    : '—',
                label: '7d Check-in',
                color: AppColors.accentCyan,
              ),
              const SizedBox(width: 8),
              _buildStatItem(
                icon: Icons.payments_outlined,
                value: trainer.commissionPercent != null
                    ? '${trainer.commissionPercent!.toStringAsFixed(0)}%'
                    : '—',
                label: 'Commission',
                color: AppColors.accentOrange,
              ),
              const SizedBox(width: 8),
              _buildStatItem(
                icon: Icons.circle,
                value: isActive ? 'Active' : 'Inactive',
                label: 'Status',
                color: isActive ? AppColors.accentCyan : AppColors.textDisabled,
                iconSize: 8,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${trainer.sessionsLoggedLast30Days} sessions logged in the last 30 days',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
          ),

          const SizedBox(height: 14),

          // ── Divider ──
          Container(
            height: 1,
            color: AppColors.glassBorder,
          ),

          const SizedBox(height: 12),

          // ── Action Buttons — both open real, working flows ──
          Row(
            children: [
              _buildActionButton(
                icon: Icons.visibility_rounded,
                label: 'View Details',
                color: AppColors.accentBlue,
                onTap: () => _showTrainerDetail(trainer),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.tune_rounded,
                label: 'Shift & Commission',
                color: AppColors.accentPurple,
                onTap: trainer.membershipId.isEmpty
                    ? null
                    : () => _configureTrainer(trainer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  STAT ITEM (inside card)
  // ═══════════════════════════════════════════════

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    double iconSize = 12,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: color.withValues(alpha: 0.06),
          border: Border.all(
            color: color.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: iconSize),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  ACTION BUTTON
  // ═══════════════════════════════════════════════

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    final effectiveColor = enabled ? color : AppColors.textDisabled;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: effectiveColor.withValues(alpha: 0.08),
            border: Border.all(
              color: effectiveColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: effectiveColor, size: 16),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  FLOATING ACTION BUTTON
  // ═══════════════════════════════════════════════

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () async {
        final added = await Navigator.of(context).push<Object?>(
          MaterialPageRoute(builder: (_) => const AddMemberScreen(asTrainer: true)),
        );
        if (added != null && mounted) _loadTrainers();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentPurple, Color(0xFFA855F7)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.accentPurple.withValues(alpha: 0.15),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.person_add_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  TRAINER DETAIL SHEET (real data only)
  // ═══════════════════════════════════════════════

  Future<void> _showTrainerDetail(GymTrainer trainer) async {
    final gymId = ref.read(currentGymIdProvider);
    Map<String, dynamic>? detail;
    if (gymId != null && trainer.trainerId.isNotEmpty) {
      try {
        detail = await ref.read(gymOwnerServiceProvider).getTrainerDetail(gymId, trainer.trainerId);
      } catch (_) {}
    }
    if (!mounted) return;
    final assigned = (detail?['assignedMembers'] as List?) ?? const [];
    final profile = detail?['profile'] as Map?;
    final bio = profile?['bio'] as String?;
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: const BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetDragHandle(),
            const SizedBox(height: 16),
            Text(
              trainer.name.isNotEmpty ? trainer.name : 'Trainer',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(trainer.specialization, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            if (bio != null && bio.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(bio, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 16),
            _detailRow('Verification', trainer.isVerified ? 'Verified' : trainer.verificationStatus),
            _detailRow('Email', trainer.email ?? '—'),
            _detailRow('Phone', trainer.phone ?? '—'),
            _detailRow('Shift schedule', trainer.shiftSchedule ?? 'Not set'),
            _detailRow('Commission',
                trainer.commissionPercent != null ? '${trainer.commissionPercent!.toStringAsFixed(0)}%' : 'Not set'),
            _detailRow('Active clients', '${trainer.activeClientsCount}'),
            _detailRow('Sessions logged (30d)', '${trainer.sessionsLoggedLast30Days}'),
            _detailRow('Client check-in rate (7d)',
                trainer.clientCheckInRate7dPercent != null
                    ? '${trainer.clientCheckInRate7dPercent!.toStringAsFixed(0)}%'
                    : '—'),
            if (assigned.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Assigned members', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: 6),
              ...assigned.take(8).map((raw) {
                final m = Map<String, dynamic>.from(raw as Map);
                final plan = m['plan'];
                final planName = plan is Map ? '${plan['name'] ?? ''}' : '';
                return _detailRow(m['fullName'] as String? ?? 'Member', planName.isEmpty ? '—' : planName);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelLarge.copyWith(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  SHIFT & COMMISSION EDIT (real PATCH)
  // ═══════════════════════════════════════════════

  Future<void> _configureTrainer(GymTrainer trainer) async {
    final shiftController = TextEditingController(text: trainer.shiftSchedule ?? '');
    final commissionController =
        TextEditingController(text: trainer.commissionPercent?.toStringAsFixed(0) ?? '');
    try {
      final saved = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SheetDragHandle(),
                const SizedBox(height: 16),
                Text('${trainer.name} — Shift & Commission',
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: shiftController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Shift schedule',
                    hintText: 'e.g. Mon-Sat 6am-2pm',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.bgTertiary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commissionController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Commission %',
                    hintText: '0-100',
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.bgTertiary,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (saved != true) return;
      final gymId = ref.read(currentGymIdProvider);
      if (gymId == null) return;
      try {
        await ref.read(gymOwnerServiceProvider).updateTrainerConfig(
              gymId: gymId,
              membershipId: trainer.membershipId,
              shiftSchedule: shiftController.text.trim().isEmpty ? null : shiftController.text.trim(),
              commissionPercent: double.tryParse(commissionController.text.trim()),
            );
        if (mounted) {
          _showSnackBar('Updated ${trainer.name}\'s shift & commission.');
          _loadTrainers();
        }
      } catch (e) {
        if (mounted) _showSnackBar('Failed to update: ${friendlyApiError(e)}');
      }
    } finally {
      shiftController.dispose();
      commissionController.dispose();
    }
  }

  // ═══════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        backgroundColor: AppColors.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
