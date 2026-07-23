import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import 'settings_screen.dart';

/// Profile content — designed to be embedded inside the DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class ProfileContent extends ConsumerStatefulWidget {
  final VoidCallback onViewAchievements;
  final VoidCallback onManageBilling;

  const ProfileContent({
    super.key,
    required this.onViewAchievements,
    required this.onManageBilling,
  });

  @override
  ConsumerState<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends ConsumerState<ProfileContent> {
  // Fitness / body states (local — not from API yet)
  int _userAge = 25;
  String _userGoal = 'Build Muscle';
  double _userHeight = 175.0; // cm
  double _userWeight = 78.0; // kg
  double _userTargetWeight = 72.0; // kg
  double _userBodyFat = 18.4; // %
  double _userMuscleMass = 60.5; // kg
  String _dietType = 'Vegetarian';

  // Metrics History state
  final List<Map<String, dynamic>> _metricsHistory = [
    {
      'date': DateTime(2026, 7, 15),
      'weight': 78.0,
      'bodyFat': 18.4,
      'muscleMass': 60.5,
    },
    {
      'date': DateTime(2026, 7, 8),
      'weight': 78.5,
      'bodyFat': 18.6,
      'muscleMass': 60.3,
    },
    {
      'date': DateTime(2026, 7, 1),
      'weight': 79.2,
      'bodyFat': 19.0,
      'muscleMass': 60.1,
    },
    {
      'date': DateTime(2026, 6, 24),
      'weight': 80.0,
      'bodyFat': 19.5,
      'muscleMass': 59.8,
    },
  ];



  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }



  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Screen Header with Settings button
        SliverToBoxAdapter(child: _buildHeader()),

        // Premium Profile Header Section
        SliverToBoxAdapter(child: _buildProfileHeader()),

        // Scrollable content body
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 130), // Bottom padding to clear floating nav bar
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),

              // Fitness Snapshot Hero Card
              _buildFitnessSnapshot()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
              const SizedBox(height: 20),

              // Subscription Manager Section
              _buildSubscriptionCard()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 150.ms),
              const SizedBox(height: 20),

              // Body Metrics Section
              _buildSectionLabel('BODY METRICS'),
              const SizedBox(height: 12),
              _buildBodyMetricsSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 200.ms),
              const SizedBox(height: 20),



              // Active Goals Progress Section
              _buildSectionLabel('MY GOALS'),
              const SizedBox(height: 12),
              _buildGoalsSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 250.ms),
              const SizedBox(height: 20),

              // Nutrition Preferences Card
              _buildSectionLabel('NUTRITION PREFERENCES'),
              const SizedBox(height: 12),
              _buildNutritionPreferences()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 300.ms),
              const SizedBox(height: 20),

              // Lifetime Activity Stats
              _buildSectionLabel('LIFETIME STATS'),
              const SizedBox(height: 12),
              _buildLifetimeStats()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 20),



              // Account Action controls
              _buildAccountActions()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 600.ms),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // SCREEN HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Profile',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.bgTertiary,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: const Icon(
                Icons.settings_rounded,
                color: AppColors.textPrimary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

  Widget _buildProfileHeader() {
    final user = ref.watch(authProvider).user;
    final displayName = user?.name ?? 'User';
    final avatarUrl = user?.avatarUrl;
    final email = user?.email ?? '';
    final memberSince = user?.memberSince ?? '';
    final isEmailVerified = user?.isEmailVerified ?? false;
    final isPhoneVerified = user?.isPhoneVerified ?? false;
    final phone = user?.phone;
    // Initials for avatar fallback
    final initials = displayName.trim().isNotEmpty
        ? displayName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Photo / Avatar
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accentBlue, width: 2),
                      gradient: avatarUrl == null
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1A2B5C), Color(0xFF0D1B38)],
                            )
                          : null,
                      image: avatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(avatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: avatarUrl == null
                        ? Center(
                            child: Text(
                              initials,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.accentBlue,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                              ),
                            ),
                          )
                        : null,
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isEmailVerified ? AppColors.accentBlue : AppColors.textTertiary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isEmailVerified ? Icons.verified_rounded : Icons.person_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'FREE',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accentBlue,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Age $_userAge  •  Goal: $_userGoal',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      memberSince.isNotEmpty ? 'Member Since: $memberSince' : '',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // ── Account Info strip ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.email_rounded,
                  label: 'Email',
                  value: email.isNotEmpty ? email : '—',
                  badge: isEmailVerified ? 'Verified' : 'Not Verified',
                  badgeColor: isEmailVerified ? AppColors.accentCyan : AppColors.accentCoral,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  icon: Icons.phone_rounded,
                  label: 'Phone',
                  value: (phone != null && phone.isNotEmpty) ? phone : 'Not added',
                  badge: isPhoneVerified ? 'Verified' : 'Not Verified',
                  badgeColor: isPhoneVerified ? AppColors.accentCyan : AppColors.accentCoral,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required String badge,
    required Color badgeColor,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            badge,
            style: AppTextStyles.caption.copyWith(
              color: badgeColor,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // FITNESS SNAPSHOT CARD
  // ─────────────────────────────────────────────

  Widget _buildFitnessSnapshot() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentBlue.withValues(alpha: 0.08),
            AppColors.accentPurple.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSnapshotMetric(label: '⚖ Weight', value: '$_userWeight kg', subLabel: 'Goal: $_userTargetWeight kg'),
                Container(width: 1, height: 40, color: AppColors.glassBorder),
                _buildSnapshotMetric(label: '🔥 Streak', value: '18 Days', subLabel: 'Milestone 21d'),
                Container(width: 1, height: 40, color: AppColors.glassBorder),
                _buildSnapshotMetric(label: '⚡ Level', value: 'Level 12', subLabel: '4,250 XP total'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSnapshotMetric({required String label, required String value, required String subLabel}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 2),
        Text(
          subLabel,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 8),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // BODY METRICS SECTION
  // ─────────────────────────────────────────────

  Widget _buildBodyMetricsSection() {
    final double bmi = _userWeight / pow(_userHeight / 100, 2);

    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Assessment',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Updated Today',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.95,
            children: [
              _buildMetricTile(label: 'Weight', value: '$_userWeight kg', icon: Icons.scale_rounded, color: AppColors.accentBlue),
              _buildMetricTile(label: 'Body Fat', value: '$_userBodyFat%', icon: Icons.local_fire_department_rounded, color: AppColors.accentCoral),
              _buildMetricTile(label: 'Muscle Mass', value: '$_userMuscleMass kg', icon: Icons.fitness_center_rounded, color: AppColors.accentPurple),
              _buildMetricTile(label: 'BMI', value: bmi.toStringAsFixed(1), icon: Icons.accessibility_new_rounded, color: AppColors.accentCyan),
              _buildMetricTile(label: 'Height', value: '${_userHeight.toInt()} cm', icon: Icons.height_rounded, color: AppColors.textTertiary),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _showLogMetricsSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_chart_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Log Progress',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _showMetricsHistorySheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.history_rounded, color: AppColors.textPrimary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'View History',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color.withValues(alpha: 0.8), size: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showLogMetricsSheet() {
    final weightCtrl = TextEditingController(text: _userWeight.toString());
    final fatCtrl = TextEditingController(text: _userBodyFat.toString());
    final muscleCtrl = TextEditingController(text: _userMuscleMass.toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add_chart_rounded, color: AppColors.accentBlue, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log Today\'s Metrics',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Record your current body measurements',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLogInputField(controller: weightCtrl, label: 'Weight (kg)', icon: Icons.scale_rounded),
            const SizedBox(height: 16),
            _buildLogInputField(controller: fatCtrl, label: 'Body Fat %', icon: Icons.local_fire_department_rounded),
            const SizedBox(height: 16),
            _buildLogInputField(controller: muscleCtrl, label: 'Muscle Mass (kg)', icon: Icons.fitness_center_rounded),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                final double? w = double.tryParse(weightCtrl.text);
                final double? f = double.tryParse(fatCtrl.text);
                final double? m = double.tryParse(muscleCtrl.text);

                if (w != null && f != null && m != null) {
                  setState(() {
                    _userWeight = w;
                    _userBodyFat = f;
                    _userMuscleMass = m;
                    _metricsHistory.insert(0, {
                      'date': DateTime.now(),
                      'weight': w,
                      'bodyFat': f,
                      'muscleMass': m,
                    });
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Metrics logged successfully!'),
                      backgroundColor: AppColors.accentBlue,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: const Text('Please enter valid decimal values'),
                      backgroundColor: AppColors.accentCoral,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Save Log',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.bgTertiary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              icon: Icon(icon, color: AppColors.textTertiary, size: 18),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  void _showMetricsHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.7,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.history_rounded, color: AppColors.accentBlue, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Metrics History',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your historical progress logs',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _metricsHistory.isEmpty
                  ? Center(
                      child: Text(
                        'No history available',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _metricsHistory.length,
                      itemBuilder: (context, index) {
                        final entry = _metricsHistory[index];
                        final dateStr = _formatDate(entry['date'] as DateTime);
                        final weight = entry['weight'] as double;
                        final bodyFat = entry['bodyFat'] as double;
                        final muscleMass = entry['muscleMass'] as double;

                        String deltaStr = '';
                        Color deltaColor = AppColors.textSecondary;
                        if (index < _metricsHistory.length - 1) {
                          final prevEntry = _metricsHistory[index + 1];
                          final prevWeight = prevEntry['weight'] as double;
                          final diff = weight - prevWeight;
                          if (diff > 0) {
                            deltaStr = '(+${diff.toStringAsFixed(1)} kg)';
                            deltaColor = AppColors.accentCoral;
                          } else if (diff < 0) {
                            deltaStr = '(${diff.toStringAsFixed(1)} kg)';
                            deltaColor = AppColors.accentCyan;
                          } else {
                            deltaStr = '(No change)';
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.bgTertiary,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateStr,
                                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  if (deltaStr.isNotEmpty)
                                    Text(
                                      deltaStr,
                                      style: AppTextStyles.caption.copyWith(color: deltaColor, fontWeight: FontWeight.bold),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildHistoryMetricItem(label: 'Weight', value: '$weight kg'),
                                  _buildHistoryMetricItem(label: 'Body Fat', value: '$bodyFat%'),
                                  _buildHistoryMetricItem(label: 'Muscle Mass', value: '$muscleMass kg'),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryMetricItem({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 8),
        ),
      ],
    );
  }



  // ─────────────────────────────────────────────
  // SUBSCRIPTION CARD
  // ─────────────────────────────────────────────

  Widget _buildSubscriptionCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B2A4A),
            Color(0xFF0F1528),
          ],
        ),
        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREMIUM MEMBERSHIP',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'FitForge Pro Plan',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Active',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.credit_card_rounded, color: AppColors.textTertiary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Renews on July 15, 2026',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onManageBilling,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.25)),
                      ),
                      child: Center(
                        child: Text(
                          'Manage Billing',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showBenefitsSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Center(
                        child: Text(
                          'View Benefits',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GOALS MANAGEMENT
  // ─────────────────────────────────────────────

  Widget _buildGoalsSection() {
    final goals = [
      {'title': 'Weight Journey', 'desc': 'Lose 6.0 kg', 'progress': 0.50, 'text': '50%'},
      {'title': 'Body Composition', 'desc': 'Reach 15% Body Fat', 'progress': 0.40, 'text': '40%'},
      {'title': 'Daily Hydration', 'desc': 'Drink 4L Water Daily', 'progress': 0.80, 'text': '80%'},
      {'title': 'Habit Consistency', 'desc': 'Maintain 30d Streak', 'progress': 0.60, 'text': '60%'},
    ];

    return Column(
      children: goals.map((goal) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DashboardGlassCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      goal['title'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      goal['text'] as String,
                      style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  goal['desc'] as String,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    height: 5,
                    color: AppColors.bgTertiary,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: goal['progress'] as double,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────
  // NUTRITION PREFERENCES
  // ─────────────────────────────────────────────

  Widget _buildNutritionPreferences() {
    final macros = [
      {'label': 'Diet Type', 'value': _dietType, 'icon': '🥑'},
      {'label': 'Daily Calories', 'value': '2,500 kcal', 'icon': '🔥'},
      {'label': 'Protein Target', 'value': '140g', 'icon': '💪'},
      {'label': 'Carbs Target', 'value': '220g', 'icon': '🍞'},
      {'label': 'Fats Target', 'value': '70g', 'icon': '🥜'},
      {'label': 'Hydration Target', 'value': '4.0 L', 'icon': '💧'},
    ];

    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Target Formulas',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.edit_note_rounded, color: AppColors.accentBlue, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: macros.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final macro = macros[index];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    Text(macro['icon']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            macro['label']!,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 8),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            macro['value']!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }



  // ─────────────────────────────────────────────
  // LIFETIME ACTIVITY STATS
  // ─────────────────────────────────────────────

  Widget _buildLifetimeStats() {
    final stats = [
      {'label': 'Workouts Done', 'value': '287', 'icon': Icons.fitness_center_rounded},
      {'label': 'Cal tracked', 'value': '425,000', 'icon': Icons.local_fire_department_rounded},
      {'label': 'Total XP', 'value': '12,450', 'icon': Icons.bolt_rounded},
      {'label': 'Active Days', 'value': '198', 'icon': Icons.calendar_month_rounded},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            children: [
              Icon(stat['icon'] as IconData, color: AppColors.accentBlue.withValues(alpha: 0.7), size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat['value'] as String,
                      style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stat['label'] as String,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 9),
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





  // ─────────────────────────────────────────────
  // ACCOUNT ACTIONS (Export & Logout)
  // ─────────────────────────────────────────────

  Widget _buildAccountActions() {
    return Column(
      children: [
        GestureDetector(
          onTap: () {},
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download_rounded, color: AppColors.textSecondary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Export My Personal Data',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            // Logout and return to welcome/login screen
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.15)),
            ),
            child: Center(
              child: Text(
                'Log Out',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.accentCoral,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBenefitsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: AppColors.accentBlue, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FitForge Pro Benefits',
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Your active premium features',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...[
              {
                'title': 'Unlimited Diet Logging',
                'desc': 'Log meals and macros without any historical or quantity limits.',
                'icon': Icons.restaurant_menu_rounded,
              },
              {
                'title': 'AI Meal & Workout Coach',
                'desc': 'Get smart suggestions and customized plans generated by AI.',
                'icon': Icons.bolt_rounded,
              },
              {
                'title': 'Progress Analytics & Charts',
                'desc': 'Track body composition, calorie history, and workout progress visually.',
                'icon': Icons.insights_rounded,
              },
              {
                'title': 'Leaderboard & Rewards',
                'desc': 'Compete with friends, earn levels, and claim rewards with your streak.',
                'icon': Icons.emoji_events_rounded,
              },
              {
                'title': 'Trainer Connect (1/mo)',
                'desc': 'One 1-on-1 virtual training session with a certified coach every month.',
                'icon': Icons.contact_support_rounded,
              },
            ].map((benefit) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.bgTertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Icon(
                        benefit['icon'] as IconData,
                        color: AppColors.accentBlue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            benefit['title'] as String,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            benefit['desc'] as String,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                widget.onManageBilling();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Manage Subscription & Plans',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Close',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper title label
  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textTertiary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
