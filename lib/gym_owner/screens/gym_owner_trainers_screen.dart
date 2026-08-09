import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_trainer.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';

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

  List<Map<String, dynamic>> get _filteredTrainers {
    var trainers = _liveTrainers.map((lt) {
      final name = lt.name.isNotEmpty ? lt.name : 'Trainer';
      final initials = name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase();
      return {
        'trainerId': lt.trainerId,
        'name': name,
        'initials': initials.isNotEmpty ? initials : 'T',
        'specialization': lt.specialization.isNotEmpty ? lt.specialization : 'General Fitness',
        'experience': '5+ years',
        'certification': 'Certified Coach',
        'isCertified': true,
        'clients': lt.activeClientsCount,
        'retentionRate': 0.92,
        'avgRating': 4.8,
        'isOnline': lt.status == 'ACTIVE',
        'phone': lt.phone ?? 'No phone',
        'joinDate': 'Recent',
        'gradientColors': [AppColors.accentPurple, AppColors.accentCoral],
      };
    }).toList();

    if (_searchQuery.isEmpty) return trainers;
    return trainers.where((t) {
      final name = (t['name'] as String).toLowerCase();
      final spec = (t['specialization'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || spec.contains(query);
    }).toList();
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

                // ── Empty State ──
                if (filtered.isEmpty)
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
                if (filtered.isNotEmpty)
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
    final totalClients = trainers.fold<int>(
        0, (sum, t) => sum + (t['clients'] as int));
    final onlineCount =
        trainers.where((t) => t['isOnline'] == true).length;
    final avgRating = trainers.isEmpty
        ? 0.0
        : trainers.fold<double>(
                0, (sum, t) => sum + (t['avgRating'] as double)) /
            trainers.length;

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
          value: '$onlineCount',
          label: 'Online Now',
          color: AppColors.accentCyan,
          iconSize: 10,
        ),
        const SizedBox(width: 10),
        _buildMiniStat(
          icon: Icons.star_rounded,
          value: avgRating.toStringAsFixed(1),
          label: 'Avg Rating',
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

  Widget _buildTrainerCard(Map<String, dynamic> trainer) {
    final gradientColors = trainer['gradientColors'] as List<Color>;
    final isOnline = trainer['isOnline'] as bool;
    final isCertified = trainer['isCertified'] as bool;

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
                        trainer['initials'] as String,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  // Online dot
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppColors.accentCyan
                            : AppColors.textDisabled,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.bgPrimary,
                          width: 2.5,
                        ),
                        boxShadow: isOnline
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

              // Name + Specialization + Experience
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row with certification badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trainer['name'] as String,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isCertified) ...[
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
                                  trainer['certification'] as String,
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
                            trainer['specialization'] as String,
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

                    // Experience
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          color: AppColors.textTertiary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trainer['experience']} experience',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 10,
                          color: AppColors.glassBorder,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.calendar_today_rounded,
                          color: AppColors.textTertiary,
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Since ${trainer['joinDate']}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
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

          // ── Statistics Row ──
          Row(
            children: [
              _buildStatItem(
                icon: Icons.people_outline_rounded,
                value: '${trainer['clients']}',
                label: 'Clients',
                color: AppColors.accentBlue,
              ),
              const SizedBox(width: 8),
              _buildStatItem(
                icon: Icons.replay_rounded,
                value:
                    '${((trainer['retentionRate'] as double) * 100).toInt()}%',
                label: 'Retention',
                color: AppColors.accentCyan,
              ),
              const SizedBox(width: 8),
              _buildStatItem(
                icon: Icons.star_rounded,
                value: '${trainer['avgRating']}',
                label: 'Rating',
                color: AppColors.accentOrange,
              ),
              const SizedBox(width: 8),
              _buildStatItem(
                icon: Icons.circle,
                value: isOnline ? 'Online' : 'Offline',
                label: 'Status',
                color: isOnline ? AppColors.accentCyan : AppColors.textDisabled,
                iconSize: 8,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Retention Progress Bar ──
          Row(
            children: [
              SizedBox(
                width: 62,
                child: Text(
                  'Retention',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ),
              Expanded(
                child: LinearProgressBar(
                  progress: trainer['retentionRate'] as double,
                  color: gradientColors[0],
                  height: 4,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 32,
                child: Text(
                  '${((trainer['retentionRate'] as double) * 100).toInt()}%',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Divider ──
          Container(
            height: 1,
            color: AppColors.glassBorder,
          ),

          const SizedBox(height: 12),

          // ── Action Buttons ──
          Row(
            children: [
              _buildActionButton(
                icon: Icons.visibility_rounded,
                label: 'View',
                color: AppColors.accentBlue,
                onTap: () => _showSnackBar(
                    'Viewing profile of ${trainer['name']}'),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.group_add_rounded,
                label: 'Assign',
                color: AppColors.accentPurple,
                onTap: () => _showSnackBar(
                    'Assigning members to ${trainer['name']}'),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.insights_rounded,
                label: 'Performance',
                color: AppColors.accentCyan,
                onTap: () => _showSnackBar(
                    'Viewing performance of ${trainer['name']}'),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Message',
                color: AppColors.accentOrange,
                onTap: () =>
                    _showSnackBar('Messaging ${trainer['name']}'),
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
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withValues(alpha: 0.08),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: color,
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
      onTap: () => _showSnackBar('Add Trainer form coming soon'),
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
