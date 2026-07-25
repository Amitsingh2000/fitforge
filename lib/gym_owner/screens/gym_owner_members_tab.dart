import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_member.dart';
import '../../models/gym_trainer.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';

class GymOwnerMembersTab extends ConsumerStatefulWidget {
  const GymOwnerMembersTab({super.key});

  @override
  ConsumerState<GymOwnerMembersTab> createState() => _GymOwnerMembersTabState();
}

class _GymOwnerMembersTabState extends ConsumerState<GymOwnerMembersTab> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String? _selectedTrainerFilter;
  final TextEditingController _searchController = TextEditingController();

  List<GymMember> _liveMembers = [];
  List<GymTrainer> _liveTrainers = [];
  bool _membersLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMembers();
    });
  }

  Future<void> _loadMembers() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null || gymId.isEmpty) {
      if (mounted) setState(() => _membersLoading = false);
      return;
    }

    setState(() => _membersLoading = true);

    try {
      final service = ref.read(gymOwnerServiceProvider);
      final members = await service.getMembers(
        gymId,
        status: _selectedFilter != 'All' ? _selectedFilter.toUpperCase() : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      final trainers = await service.getTrainersRoster(gymId);

      if (mounted) {
        setState(() {
          _liveMembers = members;
          _liveTrainers = trainers;
          _membersLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _membersLoading = false);
    }
  }

  Future<void> _updateMemberStatus(GymMember member, String newStatus) async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;

    try {
      final service = ref.read(gymOwnerServiceProvider);
      await service.updateMemberStatus(gymId, member.membershipId, status: newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated ${member.fullName} to $newStatus')),
        );
        _loadMembers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  Future<void> _assignTrainer(GymMember member, GymTrainer trainer) async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;

    try {
      final service = ref.read(gymOwnerServiceProvider);
      await service.assignTrainer(
        gymId: gymId,
        membershipId: member.membershipId,
        trainerId: trainer.trainerId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assigned ${trainer.name} to ${member.fullName}')),
        );
        _loadMembers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign trainer: $e')),
        );
      }
    }
  }

  final List<String> _statusFilters = [
    'All',
    'Active',
    'Expired',
    'Pending',
  ];

  final List<String> _trainers = [
    'Coach Anil',
    'Coach Meera',
    'Coach Raj',
    'Coach Dia',
  ];

  final List<Map<String, dynamic>> _allMembers = [
    {
      'name': 'Rahul Sharma',
      'initials': 'RS',
      'phone': '+91 98765 43210',
      'status': 'Active',
      'membershipPlan': 'Premium',
      'planExpiry': '15 Dec 2026',
      'attendance': 0.92,
      'goal': 'Weight Loss',
      'trainer': 'Coach Anil',
      'progress': 0.78,
      'joinDate': '12 Jan 2026',
      'gradientColors': [AppColors.accentBlue, AppColors.accentCyan],
    },
    {
      'name': 'Priya Patel',
      'initials': 'PP',
      'phone': '+91 87654 32109',
      'status': 'Active',
      'membershipPlan': 'Standard',
      'planExpiry': '3 Sep 2026',
      'attendance': 0.88,
      'goal': 'Muscle Gain',
      'trainer': 'Coach Meera',
      'progress': 0.65,
      'joinDate': '3 Feb 2026',
      'gradientColors': [AppColors.accentPurple, AppColors.accentCoral],
    },
    {
      'name': 'Vikram Singh',
      'initials': 'VS',
      'phone': '+91 76543 21098',
      'status': 'Expired',
      'membershipPlan': 'Basic',
      'planExpiry': '8 May 2026',
      'attendance': 0.45,
      'goal': 'Endurance',
      'trainer': 'Coach Raj',
      'progress': 0.32,
      'joinDate': '8 Nov 2025',
      'gradientColors': [AppColors.accentOrange, AppColors.accentCoral],
    },
    {
      'name': 'Sneha Gupta',
      'initials': 'SG',
      'phone': '+91 65432 10987',
      'status': 'Active',
      'membershipPlan': 'Premium',
      'planExpiry': '20 Jan 2027',
      'attendance': 0.95,
      'goal': 'Flexibility',
      'trainer': 'Coach Anil',
      'progress': 0.88,
      'joinDate': '20 Mar 2026',
      'gradientColors': [AppColors.accentCyan, AppColors.accentBlue],
    },
    {
      'name': 'Arjun Reddy',
      'initials': 'AR',
      'phone': '+91 54321 09876',
      'status': 'Active',
      'membershipPlan': 'Premium',
      'planExpiry': '15 Nov 2026',
      'attendance': 0.76,
      'goal': 'Strength',
      'trainer': 'Coach Meera',
      'progress': 0.55,
      'joinDate': '15 Apr 2026',
      'gradientColors': [AppColors.accentBlue, AppColors.accentPurple],
    },
    {
      'name': 'Deepa Nair',
      'initials': 'DN',
      'phone': '+91 43210 98765',
      'status': 'Pending',
      'membershipPlan': 'Standard',
      'planExpiry': '28 Aug 2026',
      'attendance': 0.20,
      'goal': 'Weight Loss',
      'trainer': 'Coach Raj',
      'progress': 0.10,
      'joinDate': '28 Jun 2026',
      'gradientColors': [AppColors.accentPurple, const Color(0xFFA855F7)],
    },
    {
      'name': 'Karan Mehta',
      'initials': 'KM',
      'phone': '+91 32109 87654',
      'status': 'Active',
      'membershipPlan': 'Premium',
      'planExpiry': '5 Feb 2027',
      'attendance': 0.84,
      'goal': 'Body Building',
      'trainer': 'Coach Anil',
      'progress': 0.72,
      'joinDate': '5 Jan 2026',
      'gradientColors': [AppColors.accentCoral, AppColors.accentOrange],
    },
    {
      'name': 'Ananya Iyer',
      'initials': 'AI',
      'phone': '+91 21098 76543',
      'status': 'Expired',
      'membershipPlan': 'Basic',
      'planExpiry': '22 Mar 2026',
      'attendance': 0.38,
      'goal': 'Cardio Fitness',
      'trainer': 'Coach Meera',
      'progress': 0.28,
      'joinDate': '22 Sep 2025',
      'gradientColors': [AppColors.accentOrange, AppColors.accentCyan],
    },
    {
      'name': 'Rohan Das',
      'initials': 'RD',
      'phone': '+91 10987 65432',
      'status': 'Pending',
      'membershipPlan': 'Premium',
      'planExpiry': '10 Jul 2026',
      'attendance': 0.0,
      'goal': 'Muscle Gain',
      'trainer': 'Coach Dia',
      'progress': 0.0,
      'joinDate': '1 Jul 2026',
      'gradientColors': [const Color(0xFF6366F1), AppColors.accentBlue],
    },
    {
      'name': 'Meera Joshi',
      'initials': 'MJ',
      'phone': '+91 09876 54321',
      'status': 'Active',
      'membershipPlan': 'Standard',
      'planExpiry': '18 Oct 2026',
      'attendance': 0.81,
      'goal': 'Weight Loss',
      'trainer': 'Coach Dia',
      'progress': 0.60,
      'joinDate': '18 Apr 2026',
      'gradientColors': [AppColors.accentCyan, const Color(0xFF06B6D4)],
    },
    {
      'name': 'Aditya Kapoor',
      'initials': 'AK',
      'phone': '+91 88765 12340',
      'status': 'Active',
      'membershipPlan': 'Premium',
      'planExpiry': '22 Mar 2027',
      'attendance': 0.91,
      'goal': 'Strength',
      'trainer': 'Coach Raj',
      'progress': 0.83,
      'joinDate': '22 Sep 2025',
      'gradientColors': [AppColors.accentBlue, const Color(0xFF6366F1)],
    },
    {
      'name': 'Nisha Verma',
      'initials': 'NV',
      'phone': '+91 77654 23410',
      'status': 'Expired',
      'membershipPlan': 'Basic',
      'planExpiry': '5 Apr 2026',
      'attendance': 0.30,
      'goal': 'Flexibility',
      'trainer': 'Coach Meera',
      'progress': 0.22,
      'joinDate': '5 Oct 2025',
      'gradientColors': [AppColors.accentCoral, AppColors.accentPurple],
    },
  ];

  List<Map<String, dynamic>> get _filteredMembers {
    var members = _allMembers;

    // Use live API members if available
    if (_liveMembers.isNotEmpty) {
      members = _liveMembers.map((lm) {
        return {
          'membershipId': lm.membershipId,
          'userId': lm.userId,
          'name': lm.fullName,
          'initials': lm.firstName.isNotEmpty ? lm.firstName[0] : 'M',
          'phone': lm.phone ?? 'No phone',
          'status': lm.status[0] + lm.status.substring(1).toLowerCase(),
          'membershipPlan': lm.planName ?? 'Standard',
          'planExpiry': lm.endDate != null ? '${lm.endDate!.day}/${lm.endDate!.month}/${lm.endDate!.year}' : 'Active',
          'attendance': 0.85,
          'goal': 'General Fitness',
          'trainer': lm.assignedTrainerName ?? 'Unassigned',
          'progress': 0.70,
          'joinDate': lm.startDate != null ? '${lm.startDate!.day}/${lm.startDate!.month}/${lm.startDate!.year}' : 'Recent',
          'gradientColors': [AppColors.accentBlue, AppColors.accentCyan],
          'liveModel': lm,
        };
      }).toList();
    }

    // Filter by status
    if (_selectedFilter != 'All') {
      members = members.where((m) => (m['status'] as String).toLowerCase() == _selectedFilter.toLowerCase()).toList();
    }

    // Filter by trainer
    if (_selectedTrainerFilter != null) {
      members = members
          .where((m) => m['trainer'] == _selectedTrainerFilter)
          .toList();
    }

    // Filter by search query (name or phone)
    if (_searchQuery.isNotEmpty) {
      members = members.where((m) {
        final name = (m['name'] as String).toLowerCase();
        final phone = (m['phone'] as String).replaceAll(' ', '');
        final query = _searchQuery.toLowerCase().replaceAll(' ', '');
        return name.contains(query) || phone.contains(query);
      }).toList();
    }

    return members;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMembers;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.accentBlue,
                            AppColors.accentBlue.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.people_rounded,
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
                            'Members Management',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_allMembers.length} total members',
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
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
            ),

            // ── Status Filter Chips ──
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _statusFilters.length + 1, // +1 for trainer chip
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index < _statusFilters.length) {
                      return _buildStatusFilterChip(_statusFilters[index]);
                    }
                    // Trainer dropdown chip
                    return _buildTrainerFilterChip();
                  },
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 180.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 180.ms),
            ),

            // ── Filtered Count Badge ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 20, 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.accentBlue.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.accentBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        'Showing ${filtered.length} of ${_allMembers.length} members',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentBlue,
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

            // ── Member Cards List ──
            if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          color: AppColors.textTertiary.withValues(alpha: 0.4),
                          size: 56,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No members found',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try adjusting your search or filters',
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

            if (filtered.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final member = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildMemberCard(member)
                            .animate()
                            .fadeIn(
                                duration: 400.ms,
                                delay: Duration(
                                    milliseconds: 280 + index * 50))
                            .slideY(
                                begin: 0.04,
                                end: 0,
                                duration: 400.ms,
                                delay: Duration(
                                    milliseconds: 280 + index * 50)),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),

        // ── Floating Action Button ──
        Positioned(
          bottom: 90,
          right: 20,
          child: _buildFAB()
              .animate()
              .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  delay: 500.ms,
                  curve: Curves.elasticOut),
        ),
      ],
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
              hintText: 'Search by name or phone...',
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
  //  FILTER CHIPS
  // ═══════════════════════════════════════════════

  Widget _buildStatusFilterChip(String filter) {
    final isSelected =
        filter == _selectedFilter && _selectedTrainerFilter == null;

    // Count for each filter
    int count;
    if (filter == 'All') {
      count = _allMembers.length;
    } else {
      count = _allMembers.where((m) => m['status'] == filter).length;
    }

    return GestureDetector(
      onTap: () => setState(() {
        _selectedFilter = filter;
        _selectedTrainerFilter = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.accentBlue.withValues(alpha: 0.15)
              : AppColors.glassBg,
          border: Border.all(
            color: isSelected
                ? AppColors.accentBlue.withValues(alpha: 0.4)
                : AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter,
              style: AppTextStyles.caption.copyWith(
                color:
                    isSelected ? AppColors.accentBlue : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isSelected
                    ? AppColors.accentBlue.withValues(alpha: 0.2)
                    : AppColors.bgTertiary,
              ),
              child: Text(
                '$count',
                style: AppTextStyles.caption.copyWith(
                  color: isSelected
                      ? AppColors.accentBlue
                      : AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerFilterChip() {
    final isSelected = _selectedTrainerFilter != null;
    final label = isSelected ? _selectedTrainerFilter! : 'Trainer';

    return GestureDetector(
      onTap: () => _showTrainerFilterSheet(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.accentPurple.withValues(alpha: 0.15)
              : AppColors.glassBg,
          border: Border.all(
            color: isSelected
                ? AppColors.accentPurple.withValues(alpha: 0.4)
                : AppColors.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center_rounded,
              color: isSelected
                  ? AppColors.accentPurple
                  : AppColors.textTertiary,
              size: 13,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected
                    ? AppColors.accentPurple
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: isSelected
                  ? AppColors.accentPurple
                  : AppColors.textTertiary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainerFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.textDisabled,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filter by Trainer',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              // All trainers option
              _buildTrainerOption(null, 'All Trainers',
                  Icons.groups_rounded, _selectedTrainerFilter == null),
              const SizedBox(height: 8),

              // Each trainer
              ..._trainers.map((trainer) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildTrainerOption(
                    trainer,
                    trainer,
                    Icons.fitness_center_rounded,
                    _selectedTrainerFilter == trainer,
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainerOption(
      String? value, String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTrainerFilter = value;
          if (value != null) {
            _selectedFilter = 'All';
          }
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected
              ? AppColors.accentPurple.withValues(alpha: 0.12)
              : AppColors.glassBg,
          border: Border.all(
            color: isSelected
                ? AppColors.accentPurple.withValues(alpha: 0.4)
                : AppColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.accentPurple
                  : AppColors.textTertiary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? AppColors.accentPurple
                      : AppColors.textPrimary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.accentPurple,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  MEMBER CARD
  // ═══════════════════════════════════════════════

  Widget _buildMemberCard(Map<String, dynamic> member) {
    final gradientColors = member['gradientColors'] as List<Color>;
    final status = member['status'] as String;

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'Active':
        statusColor = AppColors.accentCyan;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'Expired':
        statusColor = AppColors.accentCoral;
        statusIcon = Icons.error_outline_rounded;
        break;
      case 'Pending':
        statusColor = AppColors.accentOrange;
        statusIcon = Icons.hourglass_top_rounded;
        break;
      default:
        statusColor = AppColors.textTertiary;
        statusIcon = Icons.help_outline_rounded;
    }

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        children: [
          // ── Top Row: Avatar + Info + Status ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
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
                    member['initials'] as String,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name + Phone + Plan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      member['name'] as String,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Phone
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          color: AppColors.textTertiary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          member['phone'] as String,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Membership Plan pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: gradientColors[0].withValues(alpha: 0.1),
                        border: Border.all(
                          color: gradientColors[0].withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        '${member['membershipPlan']} • Exp ${member['planExpiry']}',
                        style: AppTextStyles.caption.copyWith(
                          color: gradientColors[0],
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: statusColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 11),
                    const SizedBox(width: 3),
                    Text(
                      status,
                      style: AppTextStyles.caption.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Goal + Trainer row ──
          Row(
            children: [
              Icon(
                Icons.flag_rounded,
                color: AppColors.textTertiary,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                member['goal'] as String,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 1,
                height: 12,
                color: AppColors.glassBorder,
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.fitness_center_rounded,
                color: AppColors.textTertiary,
                size: 13,
              ),
              const SizedBox(width: 4),
              Text(
                member['trainer'] as String,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Attendance bar ──
          _buildProgressRow(
            label: 'Attendance',
            value: member['attendance'] as double,
            color: AppColors.accentCyan,
          ),

          const SizedBox(height: 8),

          // ── Progress bar ──
          _buildProgressRow(
            label: 'Progress',
            value: member['progress'] as double,
            color: gradientColors[0],
          ),

          const SizedBox(height: 14),

          // ── Divider ──
          Container(
            height: 1,
            color: AppColors.glassBorder,
          ),

          const SizedBox(height: 12),

          // ── Action Buttons Row ──
          Row(
            children: [
              _buildActionButton(
                icon: Icons.visibility_rounded,
                label: 'View',
                color: AppColors.accentBlue,
                onTap: () => _showSnackBar(
                    'Viewing profile of ${member['name']}'),
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.edit_rounded,
                label: 'Assign Coach',
                color: AppColors.accentPurple,
                onTap: () {
                  final lm = member['liveModel'] as GymMember?;
                  if (lm != null && _liveTrainers.isNotEmpty) {
                    _assignTrainer(lm, _liveTrainers.first);
                  } else {
                    _showSnackBar('Editing ${member['name']}');
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.autorenew_rounded,
                label: 'Renew',
                color: AppColors.accentCyan,
                onTap: () {
                  final lm = member['liveModel'] as GymMember?;
                  if (lm != null) {
                    _updateMemberStatus(lm, 'ACTIVE');
                  } else {
                    _showSnackBar('Renewing membership for ${member['name']}');
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.block_rounded,
                label: 'Deactivate',
                color: AppColors.accentCoral,
                onTap: () {
                  final lm = member['liveModel'] as GymMember?;
                  if (lm != null) {
                    _updateMemberStatus(lm, 'INACTIVE');
                  } else {
                    _showSnackBar('Deactivating ${member['name']}');
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  PROGRESS ROW
  // ═══════════════════════════════════════════════

  Widget _buildProgressRow({
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: LinearProgressBar(
            progress: value,
            color: color,
            height: 4,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            '${(value * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ),
      ],
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
      onTap: () => _showSnackBar('Add Member form coming soon'),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentBlue, Color(0xFF6366F1)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.accentBlue.withValues(alpha: 0.15),
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
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
