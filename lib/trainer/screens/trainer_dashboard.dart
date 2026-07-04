import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../widgets/trainer_glass_stat_card.dart';
import '../widgets/trainer_schedule_card.dart';
import 'trainer_clients_tab.dart';
import 'trainer_reviews_tab.dart';
import 'trainer_analytics_tab.dart';
import 'trainer_profile_tab.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;

  // Simulated Trainer Profile info
  final String _trainerName = 'Coach Anil';
  final String _trainerInitials = 'CA';
  final String _specialization = 'Elite Strength Coach';
  final int _notificationCount = 2;

  final List<Map<String, dynamic>> _analyticsData = [
    {
      'title': 'Active Clients',
      'value': 18,
      'icon': Icons.people_rounded,
      'color': AppColors.accentCyan,
      'trendText': '+12%',
      'isTrendPositive': true,
    },
    {
      'title': 'Sessions Today',
      'value': 6,
      'icon': Icons.calendar_today_rounded,
      'color': AppColors.accentBlue,
      'trendText': 'On track',
      'isTrendPositive': true,
    },
    {
      'title': 'Avg Rating',
      'value': 4.8,
      'icon': Icons.star_rounded,
      'color': AppColors.accentOrange,
      'trendText': 'High',
      'isTrendPositive': true,
      'suffix': ' ★',
    },
    {
      'title': 'Retention Rate',
      'value': 94,
      'icon': Icons.cached_rounded,
      'color': AppColors.accentPurple,
      'trendText': '+3%',
      'isTrendPositive': true,
      'suffix': '%',
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'label': 'View Clients',
      'icon': Icons.people_outline_rounded,
      'gradient': [AppColors.accentCyan, AppColors.accentBlue],
      'action': 'clients',
    },
    {
      'label': 'Review Plans',
      'icon': Icons.rate_review_rounded,
      'gradient': [AppColors.accentPurple, const Color(0xFFA855F7)],
      'action': 'reviews',
    },
    {
      'label': 'New Session',
      'icon': Icons.add_circle_outline_rounded,
      'gradient': [AppColors.accentCoral, const Color(0xFFEF4444)],
      'action': 'session',
    },
    {
      'label': 'Analytics',
      'icon': Icons.insights_rounded,
      'gradient': [AppColors.accentOrange, const Color(0xFFF59E0B)],
      'action': 'analytics',
    },
  ];

  final List<Map<String, dynamic>> _todaySessions = [
    {
      'name': 'Rahul Sharma',
      'initials': 'RS',
      'time': '09:00 AM',
      'type': 'Strength & Conditioning',
      'gradient': [AppColors.accentBlue, AppColors.accentCyan],
    },
    {
      'name': 'Priya Patel',
      'initials': 'PP',
      'time': '11:30 AM',
      'type': 'Nutrition Review',
      'gradient': [AppColors.accentPurple, AppColors.accentCoral],
    },
    {
      'name': 'Sneha Gupta',
      'initials': 'SG',
      'time': '04:00 PM',
      'type': 'Flexibility Training',
      'gradient': [AppColors.accentCyan, AppColors.accentBlue],
    },
    {
      'name': 'Arjun Reddy',
      'initials': 'AR',
      'time': '06:30 PM',
      'type': 'Hypertrophy Session',
      'gradient': [AppColors.accentBlue, AppColors.accentPurple],
    },
  ];

  final List<Map<String, dynamic>> _pendingReviews = [
    {
      'name': 'Rahul Sharma',
      'goal': 'Weight Loss',
      'date': 'Today',
      'type': 'Workout Plan',
    },
    {
      'name': 'Priya Patel',
      'goal': 'Muscle Gain',
      'date': 'Yesterday',
      'type': 'Meal Plan',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Ambient background glows
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
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentPurple.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Tab content
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildCurrentPage(),
            ),
          ),

          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation()
                .animate()
                .fadeIn(duration: 600.ms, delay: 300.ms)
                .slideY(begin: 0.5, end: 0, duration: 600.ms, delay: 300.ms),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentNavIndex) {
      case 1:
        return const TrainerClientsTab(key: ValueKey('clients'));
      case 2:
        return const TrainerReviewsTab(key: ValueKey('reviews'));
      case 3:
        return const TrainerAnalyticsTab(key: ValueKey('analytics'));
      case 4:
        return const TrainerProfileTab(key: ValueKey('profile'));
      case 0:
      default:
        return _buildDashboardHome(key: const ValueKey('dashboard_home'));
    }
  }

  // ═══════════════════════════════════════════════
  //  DASHBOARD HOME CONTENT
  // ═══════════════════════════════════════════════

  Widget _buildDashboardHome({Key? key}) {
    return CustomScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(child: _buildTopHeader()),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Analytics Overview Grid
              _buildSectionLabel('OVERVIEW'),
              const SizedBox(height: 12),
              _buildAnalyticsGrid()
                  .animate()
                  .fadeIn(duration: 600.ms, delay: 100.ms)
                  .slideY(begin: 0.08, end: 0, duration: 600.ms, delay: 100.ms),
              const SizedBox(height: 24),

              // Quick Actions
              _buildSectionLabel('QUICK ACTIONS'),
              const SizedBox(height: 12),
              _buildQuickActions()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms)
                  .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 24),

              // Today's Sessions schedule
              _buildSectionLabel('TODAY\'S SCHEDULE'),
              const SizedBox(height: 12),
            ]),
          ),
        ),

        // Sessions horizontal list
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: _buildSessionsHorizontalList()
                .animate()
                .fadeIn(duration: 500.ms, delay: 300.ms)
                .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 300.ms),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Pending AI reviews
              _buildSectionLabel('PENDING AI REVIEWS'),
              const SizedBox(height: 12),
              _buildPendingReviewsList()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms)
                  .slideY(begin: 0.08, end: 0, duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 130), // space for bottom nav
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          // Trainer Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accentCyan, AppColors.accentBlue],
              ),
            ),
            child: Center(
              child: Text(
                _trainerInitials,
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name and status badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _trainerName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accentCyan.withValues(alpha: 0.2),
                        AppColors.accentBlue.withValues(alpha: 0.15),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.accentCyan.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _specialization,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notification bell
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  if (_notificationCount > 0)
                    Positioned(
                      top: 11,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.accentCoral,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentCoral.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, duration: 500.ms);
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildAnalyticsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: _analyticsData.length,
      itemBuilder: (context, index) {
        final data = _analyticsData[index];
        return TrainerGlassStatCard(
          title: data['title'] as String,
          value: data['value'],
          icon: data['icon'] as IconData,
          color: data['color'] as Color,
          trendText: data['trendText'] as String,
          isTrendPositive: data['isTrendPositive'] as bool,
          suffix: data['suffix'] as String? ?? '',
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _quickActions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final action = _quickActions[index];
          final colors = action['gradient'] as List<Color>;
          return GestureDetector(
            onTap: () {
              if (action['action'] == 'clients') {
                setState(() => _currentNavIndex = 1);
              } else if (action['action'] == 'reviews') {
                setState(() => _currentNavIndex = 2);
              } else if (action['action'] == 'analytics') {
                setState(() => _currentNavIndex = 3);
              } else if (action['action'] == 'session') {
                // Show standard notification snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.bgTertiary,
                    content: Text(
                      'Select a client from the Clients tab to schedule a session.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: 95,
              decoration: AppDecorations.glassCardWithRadius(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: colors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors[0].withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        action['icon'] as IconData,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['label'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSessionsHorizontalList() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _todaySessions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final session = _todaySessions[index];
          return TrainerScheduleCard(
            clientName: session['name'] as String,
            clientInitials: session['initials'] as String,
            time: session['time'] as String,
            sessionType: session['type'] as String,
            gradientColors: session['gradient'] as List<Color>,
            onTap: () {
              // Quick navigate to Clients detail (we'll implement that next)
              setState(() => _currentNavIndex = 1);
            },
          );
        },
      ),
    );
  }

  Widget _buildPendingReviewsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _pendingReviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final review = _pendingReviews[index];
        return DashboardGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderRadius: 16,
          onTap: () {
            // Navigate to reviews tab
            setState(() => _currentNavIndex = 2);
          },
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentPurple.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.accentPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['name'] as String,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'AI ${review['type']} generated for ${review['goal']}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Review',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review['date'] as String,
                    style: AppTextStyles.caption.copyWith(fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    final navItems = [
      {'icon': Icons.dashboard_rounded, 'label': 'Dashboard'},
      {'icon': Icons.people_rounded, 'label': 'Clients'},
      {'icon': Icons.rate_review_rounded, 'label': 'Reviews'},
      {'icon': Icons.insights_rounded, 'label': 'Analytics'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isActive = index == _currentNavIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _currentNavIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.accentCyan.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: isActive
                                ? AppColors.accentCyan
                                : AppColors.textTertiary,
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: AppTextStyles.caption.copyWith(
                              color: isActive
                                  ? AppColors.accentCyan
                                  : AppColors.textTertiary,
                              fontSize: 10,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            child: Text(item['label'] as String),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
