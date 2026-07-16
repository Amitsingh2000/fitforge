import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';

/// Profile content — designed to be embedded inside the DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class ProfileContent extends StatefulWidget {
  final VoidCallback onViewAchievements;
  final VoidCallback onManageBilling;

  const ProfileContent({
    super.key,
    required this.onViewAchievements,
    required this.onManageBilling,
  });

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  // Account/User states
  String _userName = 'Amit Pardeshi';
  int _userAge = 25;
  String _userGoal = 'Build Muscle';
  double _userHeight = 175.0; // cm
  double _userWeight = 78.0; // kg
  double _userTargetWeight = 72.0; // kg
  double _userBodyFat = 18.4; // %
  double _userMuscleMass = 60.5; // kg
  String _dietType = 'Vegetarian';

  // Toggle values for preview preferences
  bool _notificationsEnabled = true;
  bool _remindersEnabled = true;
  String _units = 'Metric (kg, cm)';

  // Edit states
  bool _isEditingMetrics = false;

  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _bodyFatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = _userName;
    _weightController.text = _userWeight.toString();
    _bodyFatController.text = _userBodyFat.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _bodyFatController.dispose();
    super.dispose();
  }

  void _saveMetrics() {
    setState(() {
      _userName = _nameController.text;
      _userWeight = double.tryParse(_weightController.text) ?? _userWeight;
      _userBodyFat = double.tryParse(_bodyFatController.text) ?? _userBodyFat;
      _isEditingMetrics = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile metrics updated successfully!'),
        backgroundColor: AppColors.bgSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
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

              // Body Metrics Editor
              _buildSectionLabelWithAction(
                label: 'BODY METRICS',
                actionLabel: _isEditingMetrics ? 'Save' : 'Edit',
                onAction: () {
                  if (_isEditingMetrics) {
                    _saveMetrics();
                  } else {
                    setState(() => _isEditingMetrics = true);
                  }
                },
              ),
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

              // Recent Achievements Preview
              _buildSectionLabel('RECENT ACHIEVEMENTS'),
              const SizedBox(height: 12),
              _buildAchievementsPreview()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 350.ms),
              const SizedBox(height: 20),

              // Lifetime Activity Stats
              _buildSectionLabel('LIFETIME STATS'),
              const SizedBox(height: 12),
              _buildLifetimeStats()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 400.ms),
              const SizedBox(height: 20),

              // Connected Health Devices
              _buildSectionLabel('CONNECTED DEVICES & APPS'),
              const SizedBox(height: 12),
              _buildConnectedDevices()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 450.ms),
              const SizedBox(height: 20),

              // App Settings Preference list
              _buildSectionLabel('PREFERENCES'),
              const SizedBox(height: 12),
              _buildPreferencesList()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 500.ms),
              const SizedBox(height: 20),

              // Support & Help
              _buildSectionLabel('SUPPORT'),
              const SizedBox(height: 12),
              _buildSupportSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 550.ms),
              const SizedBox(height: 24),

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
  // HEADER
  // ─────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Photo
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accentBlue, width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppColors.accentBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
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
                        Text(
                          _userName,
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
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
                            'PRO',
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
                      'Member Since: June 2026',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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

    if (_isEditingMetrics) {
      return DashboardGlassCard(
        child: Column(
          children: [
            _buildEditTextField(controller: _nameController, label: 'Profile Name'),
            const SizedBox(height: 12),
            _buildEditTextField(controller: _weightController, label: 'Current Weight (kg)', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _buildEditTextField(controller: _bodyFatController, label: 'Body Fat %', keyboardType: TextInputType.number),
          ],
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.25,
      children: [
        _buildMetricTile(label: 'Height', value: '${_userHeight.toInt()} cm', icon: Icons.height_rounded),
        _buildMetricTile(label: 'Weight', value: '$_userWeight kg', icon: Icons.scale_rounded),
        _buildMetricTile(label: 'BMI', value: bmi.toStringAsFixed(1), icon: Icons.accessibility_new_rounded),
        _buildMetricTile(label: 'Body Fat %', value: '$_userBodyFat%', icon: Icons.local_fire_department_rounded),
        _buildMetricTile(label: 'Muscle Mass', value: '$_userMuscleMass kg', icon: Icons.fitness_center_rounded),
        _buildMetricTile(label: 'Activity', value: 'Active', icon: Icons.bolt_rounded),
      ],
    );
  }

  Widget _buildEditTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({required String label, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppColors.textTertiary, size: 14),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 8),
              ),
            ],
          ),
        ],
      ),
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
  // ACHIEVEMENTS PREVIEW
  // ─────────────────────────────────────────────

  Widget _buildAchievementsPreview() {
    final previews = [
      {'emoji': '🔥', 'title': '30 Day Warrior'},
      {'emoji': '💧', 'title': 'Hydration Hero'},
      {'emoji': '💪', 'title': 'Protein Master'},
      {'emoji': '🏆', 'title': 'Consistency Champ'},
    ];

    return DashboardGlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: previews.map((badge) {
              return Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bgSecondary,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Center(
                      child: Text(badge['emoji']!, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 60,
                    child: Text(
                      badge['title']!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 8),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: widget.onViewAchievements,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Center(
                child: Text(
                  'View All Achievements',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
  // CONNECTED HEALTH DEVICES
  // ─────────────────────────────────────────────

  Widget _buildConnectedDevices() {
    final devices = [
      {'name': 'Apple Health', 'status': 'Connected', 'icon': Icons.favorite_rounded, 'color': AppColors.accentCoral},
      {'name': 'Google Fit', 'status': 'Connected', 'icon': Icons.fitbit_rounded, 'color': AppColors.accentBlue},
      {'name': 'Fitbit Tracker', 'status': 'Not Configured', 'icon': Icons.watch_rounded, 'color': Colors.grey},
      {'name': 'Smart Watch Wear', 'status': 'Connected', 'icon': Icons.watch_rounded, 'color': AppColors.accentCyan},
    ];

    return DashboardGlassCard(
      child: Column(
        children: devices.map((device) {
          final isConnected = device['status'] == 'Connected';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(device['icon'] as IconData, color: device['color'] as Color, size: 18),
                    const SizedBox(width: 12),
                    Text(
                      device['name'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                Text(
                  device['status'] as String,
                  style: AppTextStyles.caption.copyWith(
                    color: isConnected ? AppColors.accentCyan : AppColors.textTertiary,
                    fontWeight: isConnected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // APP PREFERENCES LIST
  // ─────────────────────────────────────────────

  Widget _buildPreferencesList() {
    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildSwitchListTile(
            title: 'Push Notifications',
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildSwitchListTile(
            title: 'Daily Reminders',
            value: _remindersEnabled,
            onChanged: (val) => setState(() => _remindersEnabled = val),
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildSimpleActionTile(
            title: 'Units & Measurements',
            subtitle: _units,
            onTap: () {
              setState(() {
                _units = _units.startsWith('Metric') ? 'Imperial (lbs, in)' : 'Metric (kg, cm)';
              });
            },
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildSimpleActionTile(
            title: 'App Language',
            subtitle: 'English (US)',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentBlue,
            activeTrackColor: AppColors.accentBlue.withValues(alpha: 0.25),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleActionTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
              ],
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SUPPORT SECTION
  // ─────────────────────────────────────────────

  Widget _buildSupportSection() {
    final supportItems = [
      {'title': 'Help Center', 'icon': Icons.help_outline_rounded},
      {'title': 'Contact Support', 'icon': Icons.mail_outline_rounded},
      {'title': 'Report an Issue', 'icon': Icons.bug_report_outlined},
      {'title': 'Privacy Policy', 'icon': Icons.lock_outline_rounded},
    ];

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: supportItems.map((item) {
          return GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(item['icon'] as IconData, color: AppColors.textTertiary, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        item['title'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
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

  Widget _buildSectionLabelWithAction({
    required String label,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.accentBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
