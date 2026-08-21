import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../theme/layout.dart';
import '../../dashboard/widgets/adaptive_nav_shell.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';
import '../../models/trainer_dashboard.dart' as dash;
import '../../models/trainer_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/trainer_dashboard_service.dart';
import '../../services/trainer_service.dart';
import '../widgets/trainer_glass_stat_card.dart';
import '../widgets/trainer_schedule_card.dart';
import '../../providers/gym_provider.dart';
import 'trainer_chat_conversation_screen.dart';
import 'trainer_chat_threads_screen.dart';
import 'trainer_clients_tab.dart';
import 'trainer_analytics_tab.dart';
import 'trainer_notifications_screen.dart';
import 'trainer_profile_tab.dart';

class TrainerDashboard extends ConsumerStatefulWidget {
  const TrainerDashboard({super.key});

  @override
  ConsumerState<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends ConsumerState<TrainerDashboard>
    with TickerProviderStateMixin {
  int _currentNavIndex = 0;

  dash.TrainerDashboard? _dashboard;
  TrainerProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ref.read(trainerDashboardServiceProvider).getDashboard(),
        ref.read(trainerServiceProvider).getMyProfile(),
      ]);
      if (mounted) {
        setState(() {
          _dashboard = results[0] as dash.TrainerDashboard;
          _profile = results[1] as TrainerProfile;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = friendlyApiError(e);
        });
      }
    }
  }

  // Live header/stat derivations (refreshed by pull-to-refresh via _load).
  String get _displayName {
    final user = ref.watch(authProvider).user;
    if (user != null && user.name.trim().isNotEmpty) return user.name;
    return 'Trainer';
  }

  String get _displayInitials =>
      _displayName.isNotEmpty ? _displayName[0].toUpperCase() : 'T';

  String get _displaySpecialization {
    final specializations = _profile?.specializations ?? const [];
    return specializations.isNotEmpty ? specializations.first : 'FitForge Trainer';
  }

  int get _notifCount => _dashboard?.unreadNotificationsCount ?? 0;

  /// Dashboard widget cards, fed from `GET /trainers/me/dashboard` counts.
  List<Map<String, dynamic>> get _overviewCards {
    final d = _dashboard;
    return [
      {
        'title': 'Assigned Clients',
        'value': d?.assignedMembersCount ?? 0,
        'icon': Icons.people_rounded,
        'color': AppColors.accentCyan,
        'trendText': 'Self-scoped',
        'isTrendPositive': true,
      },
      {
        'title': 'Pending Workout Plans',
        'value': d?.pendingWorkoutPlansCount ?? 0,
        'icon': Icons.fitness_center_rounded,
        'color': AppColors.accentBlue,
        'trendText': 'Draft',
        'isTrendPositive': true,
      },
      {
        'title': 'Pending Diet Plans',
        'value': d?.pendingDietPlansCount ?? 0,
        'icon': Icons.restaurant_rounded,
        'color': AppColors.accentOrange,
        'trendText': 'Draft',
        'isTrendPositive': true,
      },
      {
        'title': 'Active this week',
        'value': d?.engagedClientsLast7Days ?? 0,
        'icon': Icons.local_fire_department_rounded,
        'color': AppColors.accentCoral,
        'trendText': '7 days',
        'isTrendPositive': true,
      },
      {
        'title': 'Unread Messages',
        'value': d?.unreadMessagesCount ?? 0,
        'icon': Icons.chat_bubble_rounded,
        'color': AppColors.accentPurple,
        'trendText': 'Chat',
        'isTrendPositive': true,
      },
    ];
  }

  final List<Map<String, dynamic>> _quickActions = [
    {
      'label': 'View Clients',
      'icon': Icons.people_outline_rounded,
      'gradient': [AppColors.accentCyan, AppColors.accentBlue],
      'action': 'clients',
    },
    {
      'label': 'Messages',
      'icon': Icons.chat_bubble_outline_rounded,
      'gradient': [AppColors.accentPurple, const Color(0xFFA855F7)],
      'action': 'messages',
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Center(
            child: LoadingView(message: 'Loading your dashboard…'),
          ),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: SafeArea(
          child: Center(
            child: ErrorRetryView(message: _error!, onRetry: _load),
          ),
        ),
      );
    }
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

          AdaptiveNavShell(
            selectedIndex: _currentNavIndex,
            onSelect: (i) => setState(() => _currentNavIndex = i),
            accent: AppColors.accentCyan,
            items: const [
              AdaptiveNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
              AdaptiveNavItem(icon: Icons.people_rounded, label: 'Clients'),
              AdaptiveNavItem(icon: Icons.insights_rounded, label: 'Analytics'),
              AdaptiveNavItem(icon: Icons.person_rounded, label: 'Profile'),
            ],
            body: SafeArea(
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
        return const TrainerAnalyticsTab(key: ValueKey('analytics'));
      case 3:
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
          padding: Layout.scroll(context),
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
              _buildSectionLabel('RECENT MESSAGES'),
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
              _buildSectionLabel('DRAFT PLANS'),
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
                _displayInitials,
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
                  _displayName,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: ref.read(gymMembershipsProvider).length > 1
                      ? () => showGymSwitcherSheet(context, ref, onSwitched: () => setState(() {}))
                      : null,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          ref.watch(selectedGymProvider)?.gymName ?? _displaySpecialization,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentCyan,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      if (ref.watch(gymMembershipsProvider).length > 1) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.swap_horiz_rounded, color: AppColors.accentCyan, size: 14),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Notification bell
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TrainerNotificationsScreen()),
            ),
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
                  if (_notifCount > 0)
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
      gridDelegate: Layout.cards(childAspectRatio: 1.4),
      itemCount: _overviewCards.length,
      itemBuilder: (context, index) {
        final data = _overviewCards[index];
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
              } else if (action['action'] == 'messages') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrainerChatThreadsScreen()),
                );
              } else if (action['action'] == 'analytics') {
                setState(() => _currentNavIndex = 2);
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
    final threads = _dashboard?.recentThreads ?? const [];
    if (threads.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'No recent chats yet. Message a client from their profile.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
        ),
      );
    }
    return SizedBox(
      height: 110,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: threads.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final thread = threads[index];
          final name = thread.otherUserName ?? 'Member';
          return TrainerScheduleCard(
            clientName: name,
            clientInitials: name.isNotEmpty ? name[0].toUpperCase() : 'M',
            time: thread.lastMessageAt != null
                ? '${thread.lastMessageAt!.hour.toString().padLeft(2, '0')}:${thread.lastMessageAt!.minute.toString().padLeft(2, '0')}'
                : '',
            sessionType: thread.lastMessagePreview ?? 'Chat',
            gradientColors: const [AppColors.accentBlue, AppColors.accentCyan],
            onTap: () {
              final gymId = thread.gymId ?? ref.read(currentGymIdProvider);
              if (gymId == null) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => TrainerChatConversationScreen(
                    gymId: gymId,
                    threadId: thread.id,
                    otherUserId: thread.otherUserId ?? '',
                    otherUserName: name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPendingReviewsList() {
    final d = _dashboard;
    final rows = [
      {
        'name': 'Workout drafts',
        'goal': '${d?.pendingWorkoutPlansCount ?? 0} waiting',
        'type': 'Open a client to assign',
      },
      {
        'name': 'Diet drafts',
        'goal': '${d?.pendingDietPlansCount ?? 0} waiting',
        'type': 'Open a client to assign',
      },
    ];
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final review = rows[index];
        return DashboardGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderRadius: 16,
          onTap: () => setState(() => _currentNavIndex = 1),
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
                  Icons.edit_note_rounded,
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
                      '${review['goal']} · ${review['type']}',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
