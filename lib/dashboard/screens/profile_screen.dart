import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/brilliant_theme.dart';
import '../widgets/dashboard_glass_card.dart';
import 'settings_screen.dart';

/// Profile content — designed to be embedded inside the DashboardShell.
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
  final String _userName = 'Amit Pardeshi';
  final int _userAge = 25;
  final String _userGoal = 'Build Muscle';
  final double _userHeight = 175.0; // cm
  double _userWeight = 78.0; // kg
  double _userBodyFat = 18.4; // %
  double _userMuscleMass = 60.5; // kg

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
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildProfileHeader()),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),
              _buildFitnessSnapshot()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 100.ms),
              const SizedBox(height: 20),

              _buildSubscriptionCard()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('BODY METRICS'),
              const SizedBox(height: 10),
              _buildBodyMetricsSection()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('MY GOALS'),
              const SizedBox(height: 10),
              _buildGoalsSection()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 250.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('NUTRITION PREFERENCES'),
              const SizedBox(height: 10),
              _buildNutritionPreferences()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('LIFETIME STATS'),
              const SizedBox(height: 10),
              _buildLifetimeStats()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 20),

              _buildAccountActions()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 500.ms),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Profile',
            style: BrilliantTheme.headerStyle(fontSize: 22),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_rounded, color: BrilliantColors.textPrimary, size: 22),
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: BrilliantColors.mint, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: BrilliantColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: BrilliantColors.textInverse),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_userName, style: BrilliantTheme.titleStyle(fontSize: 17)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: BrilliantColors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('PRO', style: TextStyle(color: BrilliantColors.amber, fontWeight: FontWeight.w900, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$_userAge yrs · Goal: $_userGoal',
                  style: BrilliantTheme.bodyStyle(fontSize: 12),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pro Member since Jan 2026',
                  style: TextStyle(color: BrilliantColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: BrilliantTheme.badgeStyle(color: BrilliantColors.mint));
  }

  Widget _buildFitnessSnapshot() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSnapshotItem('Weight', '${_userWeight}kg', BrilliantColors.mint),
          _buildSnapshotDivider(),
          _buildSnapshotItem('Streak', '18 Days', BrilliantColors.amber),
          _buildSnapshotDivider(),
          _buildSnapshotItem('Level', 'Level 12', BrilliantColors.purple),
        ],
      ),
    );
  }

  Widget _buildSnapshotItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 11)),
      ],
    );
  }

  Widget _buildSnapshotDivider() {
    return Container(width: 1.5, height: 28, color: BrilliantColors.surfaceBorder);
  }

  Widget _buildSubscriptionCard() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FitForge Pro Plan', style: BrilliantTheme.titleStyle(fontSize: 15)),
                const SizedBox(height: 2),
                Text('Active · Renews Aug 1, 2026', style: BrilliantTheme.bodyStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          BrilliantButton(
            onPressed: widget.onManageBilling,
            color: BrilliantColors.mint,
            shadowColor: BrilliantColors.mintDark,
            textColor: BrilliantColors.textInverse,
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: const Text('Manage', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsSection() {
    final double heightM = _userHeight / 100.0;
    final double bmi = _userWeight / (heightM * heightM);

    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assessment Hub', style: BrilliantTheme.titleStyle(fontSize: 15)),
              const Text('Last updated Today', style: TextStyle(color: BrilliantColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              _buildMetricCard('Weight', '${_userWeight}kg', BrilliantColors.mint),
              const SizedBox(width: 8),
              _buildMetricCard('Body Fat', '$_userBodyFat%', BrilliantColors.coral),
              const SizedBox(width: 8),
              _buildMetricCard('Muscle', '${_userMuscleMass}kg', BrilliantColors.purple),
              const SizedBox(width: 8),
              _buildMetricCard('BMI', bmi.toStringAsFixed(1), BrilliantColors.blue),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: BrilliantButton(
                  onPressed: _showLogMetricsSheet,
                  color: BrilliantColors.mint,
                  shadowColor: BrilliantColors.mintDark,
                  textColor: BrilliantColors.textInverse,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text('Log Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BrilliantButton(
                  onPressed: _showMetricsHistorySheet,
                  color: BrilliantColors.bgTertiary,
                  shadowColor: BrilliantColors.surfaceBorder,
                  textColor: BrilliantColors.mint,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text('View History', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: BrilliantColors.bgPrimary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BrilliantColors.surfaceBorder),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _showLogMetricsSheet() {
    final weightCtrl = TextEditingController(text: _userWeight.toString());
    final fatCtrl = TextEditingController(text: _userBodyFat.toString());
    final muscleCtrl = TextEditingController(text: _userMuscleMass.toString());

    showModalBottomSheet(
      context: context,
      backgroundColor: BrilliantColors.bgSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: BrilliantColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Log Body Metrics', style: BrilliantTheme.headerStyle(fontSize: 20)),
            const SizedBox(height: 16),
            _buildInputField('Weight (kg)', weightCtrl),
            const SizedBox(height: 12),
            _buildInputField('Body Fat %', fatCtrl),
            const SizedBox(height: 12),
            _buildInputField('Muscle Mass (kg)', muscleCtrl),
            const SizedBox(height: 20),
            BrilliantButton(
              fullWidth: true,
              onPressed: () {
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
                  Navigator.of(ctx).pop();
                }
              },
              color: BrilliantColors.mint,
              shadowColor: BrilliantColors.mintDark,
              textColor: BrilliantColors.textInverse,
              borderRadius: 14,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const Text('Save Log', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: BrilliantColors.textPrimary, fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: BrilliantColors.textMuted),
        filled: true,
        fillColor: BrilliantColors.bgPrimary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BrilliantColors.surfaceBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BrilliantColors.surfaceBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BrilliantColors.mint, width: 2)),
      ),
    );
  }

  void _showMetricsHistorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: BrilliantColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: BrilliantColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Metrics History', style: BrilliantTheme.headerStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _metricsHistory.length,
                separatorBuilder: (context, index) => const Divider(color: BrilliantColors.surfaceBorder),
                itemBuilder: (context, index) {
                  final log = _metricsHistory[index];
                  final double w = log['weight'] as double;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDate(log['date'] as DateTime), style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 13)),
                        Text('${w}kg · Fat: ${log['bodyFat']}%', style: const TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 13)),
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

  Widget _buildGoalsSection() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Weight Goal (72.0 kg)',
                  style: BrilliantTheme.titleStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Text('66% Done', style: TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(color: BrilliantColors.bgTertiary, borderRadius: BorderRadius.circular(3)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.66,
              child: Container(decoration: BoxDecoration(color: BrilliantColors.mint, borderRadius: BorderRadius.circular(3))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionPreferences() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(18),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diet Preference', style: BrilliantTheme.titleStyle(fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  'Vegetarian · 2,500 kcal Daily Target',
                  style: BrilliantTheme.bodyStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: BrilliantColors.mint.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
            child: const Text('Configured', style: TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildLifetimeStats() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildLifetimeTile('Workouts', '142', BrilliantColors.purple)),
          const SizedBox(width: 8),
          Expanded(child: _buildLifetimeTile('Calories Tracked', '185k', BrilliantColors.coral)),
          const SizedBox(width: 8),
          Expanded(child: _buildLifetimeTile('Total XP', '4,250', BrilliantColors.amber)),
        ],
      ),
    );
  }

  Widget _buildLifetimeTile(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: BrilliantColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Row(
      children: [
        Expanded(
          child: BrilliantButton(
            onPressed: () {},
            color: BrilliantColors.bgTertiary,
            shadowColor: BrilliantColors.surfaceBorder,
            textColor: BrilliantColors.mint,
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: const Text('Export Data', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BrilliantButton(
            onPressed: () {},
            color: BrilliantColors.coral,
            shadowColor: BrilliantColors.coralDark,
            textColor: BrilliantColors.textPrimary,
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: const Text('Log Out', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }
}
