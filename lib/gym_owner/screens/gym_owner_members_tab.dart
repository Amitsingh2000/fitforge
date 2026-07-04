import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';

class GymOwnerMembersTab extends StatefulWidget {
  const GymOwnerMembersTab({super.key});

  @override
  State<GymOwnerMembersTab> createState() => _GymOwnerMembersTabState();
}

class _GymOwnerMembersTabState extends State<GymOwnerMembersTab> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Active', 'Inactive', 'New'];

  final List<Map<String, dynamic>> _allMembers = [
    {
      'name': 'Rahul Sharma',
      'initials': 'RS',
      'status': 'Active',
      'attendance': 0.92,
      'goal': 'Weight Loss',
      'trainer': 'Coach Anil',
      'progress': 0.78,
      'joinDate': '12 Jan 2026',
      'plan': 'Premium',
      'gradientColors': [AppColors.accentBlue, AppColors.accentCyan],
    },
    {
      'name': 'Priya Patel',
      'initials': 'PP',
      'status': 'Active',
      'attendance': 0.88,
      'goal': 'Muscle Gain',
      'trainer': 'Coach Meera',
      'progress': 0.65,
      'joinDate': '3 Feb 2026',
      'plan': 'Standard',
      'gradientColors': [AppColors.accentPurple, AppColors.accentCoral],
    },
    {
      'name': 'Vikram Singh',
      'initials': 'VS',
      'status': 'Inactive',
      'attendance': 0.45,
      'goal': 'Endurance',
      'trainer': 'Coach Raj',
      'progress': 0.32,
      'joinDate': '8 Nov 2025',
      'plan': 'Basic',
      'gradientColors': [AppColors.accentOrange, AppColors.accentCoral],
    },
    {
      'name': 'Sneha Gupta',
      'initials': 'SG',
      'status': 'Active',
      'attendance': 0.95,
      'goal': 'Flexibility',
      'trainer': 'Coach Anil',
      'progress': 0.88,
      'joinDate': '20 Mar 2026',
      'plan': 'Premium',
      'gradientColors': [AppColors.accentCyan, AppColors.accentBlue],
    },
    {
      'name': 'Arjun Reddy',
      'initials': 'AR',
      'status': 'Active',
      'attendance': 0.76,
      'goal': 'Strength',
      'trainer': 'Coach Meera',
      'progress': 0.55,
      'joinDate': '15 Apr 2026',
      'plan': 'Premium',
      'gradientColors': [AppColors.accentBlue, AppColors.accentPurple],
    },
    {
      'name': 'Deepa Nair',
      'initials': 'DN',
      'status': 'New',
      'attendance': 0.20,
      'goal': 'Weight Loss',
      'trainer': 'Coach Raj',
      'progress': 0.10,
      'joinDate': '28 Jun 2026',
      'plan': 'Standard',
      'gradientColors': [AppColors.accentPurple, const Color(0xFFA855F7)],
    },
    {
      'name': 'Karan Mehta',
      'initials': 'KM',
      'status': 'Active',
      'attendance': 0.84,
      'goal': 'Body Building',
      'trainer': 'Coach Anil',
      'progress': 0.72,
      'joinDate': '5 Jan 2026',
      'plan': 'Premium',
      'gradientColors': [AppColors.accentCoral, AppColors.accentOrange],
    },
    {
      'name': 'Ananya Iyer',
      'initials': 'AI',
      'status': 'Inactive',
      'attendance': 0.38,
      'goal': 'Cardio Fitness',
      'trainer': 'Coach Meera',
      'progress': 0.28,
      'joinDate': '22 Sep 2025',
      'plan': 'Basic',
      'gradientColors': [AppColors.accentOrange, AppColors.accentCyan],
    },
  ];

  List<Map<String, dynamic>> get _filteredMembers {
    var members = _allMembers;
    if (_selectedFilter != 'All') {
      members = members
          .where((m) => m['status'] == _selectedFilter)
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      members = members
          .where((m) => (m['name'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()))
          .toList();
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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
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
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.people_rounded,
                      color: AppColors.accentBlue,
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
                        'Members',
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

        // Search bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: _buildSearchBar(),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 150.ms)
              .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 150.ms),
        ),

        // Filter chips
        SliverToBoxAdapter(
          child: SizedBox(
            height: 38,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    child: Text(
                      filter,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? AppColors.accentBlue
                            : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms, delay: 200.ms)
              .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 200.ms),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        // Member list
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final member = _filteredMembers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildMemberListCard(member)
                      .animate()
                      .fadeIn(
                          duration: 400.ms,
                          delay: Duration(milliseconds: 250 + index * 60))
                      .slideY(
                          begin: 0.05,
                          end: 0,
                          duration: 400.ms,
                          delay: Duration(milliseconds: 250 + index * 60)),
                );
              },
              childCount: _filteredMembers.length,
            ),
          ),
        ),
      ],
    );
  }

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
              hintText: 'Search members...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
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

  Widget _buildMemberListCard(Map<String, dynamic> member) {
    final gradientColors = member['gradientColors'] as List<Color>;
    final isActive = member['status'] == 'Active';
    final isNew = member['status'] == 'New';

    Color statusColor;
    if (isActive) {
      statusColor = AppColors.accentCyan;
    } else if (isNew) {
      statusColor = AppColors.accentPurple;
    } else {
      statusColor = AppColors.accentOrange;
    }

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Row(
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

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member['name'] as String,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: statusColor.withValues(alpha: 0.12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        member['status'] as String,
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${member['goal']} • ${member['trainer']} • ${member['plan']}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressBar(
                        progress: member['attendance'] as double,
                        color: gradientColors[0],
                        height: 4,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${((member['attendance'] as double) * 100).toInt()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
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
    );
  }
}
