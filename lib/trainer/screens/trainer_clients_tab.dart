import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trainer_client.dart';
import '../../providers/trainer_flow_providers.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/linear_progress_bar.dart';
import '../../dashboard/widgets/state_views.dart';
import '../widgets/client_gradient.dart';
import 'trainer_client_detail_screen.dart';

class TrainerClientsTab extends ConsumerStatefulWidget {
  const TrainerClientsTab({super.key});

  @override
  ConsumerState<TrainerClientsTab> createState() => _TrainerClientsTabState();
}

class _TrainerClientsTabState extends ConsumerState<TrainerClientsTab> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Active', 'Inactive', 'New'];

  /// Display status derived from the member's plan status + recency.
  String _statusFor(TrainerClient client) {
    final joined = client.joinedAt;
    final isRecent = joined != null &&
        !joined.isBefore(DateTime.now().subtract(const Duration(days: 30)));
    if (isRecent) return 'New';
    final status = (client.membershipStatus ?? '').toUpperCase();
    if (status == 'ACTIVE') return 'Active';
    return 'Inactive';
  }

  List<TrainerClient> _filteredClients(List<TrainerClient> clients) {
    final query = _searchQuery.toLowerCase();
    return clients.where((client) {
      final matchesSearch = query.isEmpty ||
          client.fullName.toLowerCase().contains(query) ||
          (client.fitnessGoal ?? '').toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == 'All' ||
          _statusFor(client).toLowerCase() == _selectedFilter.toLowerCase();
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
    final clientsAsync = ref.watch(currentGymTrainerClientsProvider);

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
          child: clientsAsync.when(
            loading: () =>
                const Center(child: LoadingView(message: 'Loading clients…')),
            error: (e, _) => Center(
              child: ErrorRetryView(
                message: friendlyApiError(e),
                onRetry: () =>
                    ref.invalidate(currentGymTrainerClientsProvider),
              ),
            ),
            data: (clients) {
              final filtered = _filteredClients(clients);
              if (filtered.isEmpty) return _buildEmptyState();
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildClientCard(filtered[index], index);
                },
              );
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

  Widget _buildClientCard(TrainerClient client, int index) {
    final gradientColors = clientGradient(client.userId);
    final status = _statusFor(client);

    Color badgeColor;
    if (status == 'Active') {
      badgeColor = AppColors.accentCyan;
    } else if (status == 'Inactive') {
      badgeColor = AppColors.textDisabled;
    } else {
      badgeColor = AppColors.accentOrange;
    }

    final summary = client.progressSummary;
    final progress = summary == null
        ? 0.0
        : (summary.workoutCompletionRatePercent / 100).clamp(0.0, 1.0);

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
                client.initials,
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
                      client.fullName,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 15),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: badgeColor.withValues(alpha: 0.3), width: 0.8),
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
                  client.fitnessGoal ?? 'No goal set',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),

                // Progress Bar
                Row(
                  children: [
                    Text(
                      'Workout Completion',
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).toInt()}%',
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
                  progress: progress,
                  color: gradientColors[0],
                  height: 4,
                ),
                const SizedBox(height: 10),

                // Attendance row
                Row(
                  children: [
                    Icon(Icons.monitor_heart_rounded,
                        size: 12, color: AppColors.textTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Trend: ',
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                    Text(
                      _weightTrendLabel(summary?.weightTrend),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Plan: ${client.planName ?? 'No plan'}',
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

  String _weightTrendLabel(String? trend) {
    switch (trend?.toUpperCase()) {
      case 'DOWN':
        return 'Losing';
      case 'UP':
        return 'Gaining';
      case 'STABLE':
        return 'Stable';
      default:
        return 'Tracking…';
    }
  }
}