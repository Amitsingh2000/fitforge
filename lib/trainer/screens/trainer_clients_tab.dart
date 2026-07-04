import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';
import 'trainer_client_detail_screen.dart';

class TrainerClientsTab extends StatefulWidget {
  const TrainerClientsTab({super.key});

  @override
  State<TrainerClientsTab> createState() => _TrainerClientsTabState();
}

class _TrainerClientsTabState extends State<TrainerClientsTab> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Active', 'Inactive', 'New'];

  final List<Map<String, dynamic>> _allClients = [
    {
      'id': 'c1',
      'name': 'Rahul Sharma',
      'initials': 'RS',
      'status': 'Active',
      'attendance': 0.92,
      'goal': 'Weight Loss',
      'progress': 0.78,
      'joinDate': '12 Jan 2026',
      'plan': 'Premium Fit',
      'xp': 2850,
      'gradientColors': [AppColors.accentBlue, AppColors.accentCyan],
    },
    {
      'id': 'c2',
      'name': 'Priya Patel',
      'initials': 'PP',
      'status': 'Active',
      'attendance': 0.88,
      'goal': 'Muscle Gain',
      'progress': 0.65,
      'joinDate': '3 Feb 2026',
      'plan': 'Standard Fit',
      'xp': 1950,
      'gradientColors': [AppColors.accentPurple, AppColors.accentCoral],
    },
    {
      'id': 'c3',
      'name': 'Vikram Singh',
      'initials': 'VS',
      'status': 'Inactive',
      'attendance': 0.45,
      'goal': 'Endurance',
      'progress': 0.32,
      'joinDate': '8 Nov 2025',
      'plan': 'Basic Fit',
      'xp': 820,
      'gradientColors': [AppColors.accentOrange, AppColors.accentCoral],
    },
    {
      'id': 'c4',
      'name': 'Sneha Gupta',
      'initials': 'SG',
      'status': 'Active',
      'attendance': 0.95,
      'goal': 'Flexibility',
      'progress': 0.88,
      'joinDate': '20 Mar 2026',
      'plan': 'Premium Fit',
      'xp': 3400,
      'gradientColors': [AppColors.accentCyan, AppColors.accentBlue],
    },
    {
      'id': 'c5',
      'name': 'Arjun Reddy',
      'initials': 'AR',
      'status': 'Active',
      'attendance': 0.76,
      'goal': 'Strength',
      'progress': 0.55,
      'joinDate': '15 Apr 2026',
      'plan': 'Premium Fit',
      'xp': 1420,
      'gradientColors': [AppColors.accentBlue, AppColors.accentPurple],
    },
    {
      'id': 'c6',
      'name': 'Karan Malhotra',
      'initials': 'KM',
      'status': 'New',
      'attendance': 1.0,
      'goal': 'Muscle Gain',
      'progress': 0.05,
      'joinDate': '01 Jul 2026',
      'plan': 'Standard Fit',
      'xp': 100,
      'gradientColors': [AppColors.accentOrange, AppColors.accentPurple],
    },
  ];

  List<Map<String, dynamic>> get _filteredClients {
    return _allClients.where((client) {
      final matchesSearch = client['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          client['goal']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      final matchesFilter = _selectedFilter == 'All' ||
          client['status'].toString().toLowerCase() ==
              _selectedFilter.toLowerCase();

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Area
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Clients',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage schedules, track progress, and review plans for your assigned clients.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextField(
              controller: _searchController,
              cursorColor: AppColors.accentCyan,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              decoration: InputDecoration(
                hintText: 'Search by client name or goal...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textDisabled),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        // Filters list
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

        // List view of Clients
        Expanded(
          child: _filteredClients.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
            physics: const BouncingScrollPhysics(),
            itemCount: _filteredClients.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final client = _filteredClients[index];
              return _buildClientCard(client, index);
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
          Icon(Icons.people_outline_rounded, color: AppColors.textDisabled, size: 48),
          const SizedBox(height: 16),
          Text(
            'No clients found',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Try refining your search or filter.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildClientCard(Map<String, dynamic> client, int index) {
    final gradientColors = client['gradientColors'] as List<Color>;
    final status = client['status'] as String;

    Color badgeColor;
    if (status == 'Active') {
      badgeColor = AppColors.accentCyan;
    } else if (status == 'Inactive') {
      badgeColor = AppColors.textDisabled;
    } else {
      badgeColor = AppColors.accentOrange;
    }

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TrainerClientDetailScreen(client: client),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Initials Avatar
          Container(
            width: 46,
            height: 46,
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
                client['initials'] as String,
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Detail column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      client['name'] as String,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 15),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: Text(
                        status,
                        style: AppTextStyles.caption.copyWith(
                          color: badgeColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  client['goal'] as String,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),

                // Progress Bar
                Row(
                  children: [
                    Text(
                      'Goal Progress',
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                    const Spacer(),
                    Text(
                      '${(client['progress'] * 100).toInt()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressBar(
                  progress: client['progress'] as double,
                  color: gradientColors[0],
                  height: 4,
                ),
                const SizedBox(height: 10),

                // Attendance row
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Attendance: ',
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                    Text(
                      '${(client['attendance'] * 100).toInt()}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Plan: ${client['plan']}',
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
