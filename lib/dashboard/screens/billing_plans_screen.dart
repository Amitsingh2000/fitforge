import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/member_entitlements.dart';
import '../../models/member_subscription.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/dashboard_glass_card.dart';

class BillingPlansScreen extends StatelessWidget {
  final VoidCallback? onCompleted;
  const BillingPlansScreen({super.key, this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: BillingPlansContent(
          isStandalone: true,
          onCompleted: onCompleted ?? () {
            Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (_) => false);
          },
        ),
      ),
    );
  }
}

/// Billing & Plans content — embedded inside HomeDashboard's DashboardShell.
/// Does NOT have its own Scaffold or bottom nav.
class BillingPlansContent extends ConsumerStatefulWidget {
  final bool isStandalone;
  final VoidCallback? onCompleted;

  const BillingPlansContent({
    super.key,
    this.isStandalone = false,
    this.onCompleted,
  });

  @override
  ConsumerState<BillingPlansContent> createState() => _BillingPlansContentState();
}

class _BillingPlansContentState extends ConsumerState<BillingPlansContent>
    with SingleTickerProviderStateMixin {
  // ── State ──
  int _selectedPlanIndex = 1; // 0=Free, 1=Pro, 2=Elite
  bool _isAnnual = true;
  late final AnimationController _shineController;

  // ── Plan data ──
  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Free',
      'tagline': 'Great to start',
      'priceMonthly': 0,
      'priceAnnual': 0,
      'color': AppColors.textTertiary,
      'gradientColors': [Color(0xFF374151), Color(0xFF1F2937)],
      'icon': Icons.eco_rounded,
      'badge': null,
      'features': [
        {'text': 'Basic workout tracking', 'included': true},
        {'text': 'Limited diet logging (7 days)', 'included': true},
        {'text': 'Daily step counter', 'included': true},
        {'text': 'AI meal suggestions', 'included': false},
        {'text': 'Progress analytics & charts', 'included': false},
        {'text': 'Trainer connect', 'included': false},
        {'text': 'Leaderboard & rewards', 'included': false},
        {'text': 'Priority support', 'included': false},
      ],
    },
    {
      'name': 'Pro',
      'tagline': 'Most popular',
      'priceMonthly': 799,
      'priceAnnual': 599,
      'color': AppColors.accentBlue,
      'gradientColors': [Color(0xFF1E3A5F), Color(0xFF0F1F3D)],
      'icon': Icons.bolt_rounded,
      'badge': 'POPULAR',
      'features': [
        {'text': 'Everything in Free', 'included': true},
        {'text': 'Unlimited diet logging', 'included': true},
        {'text': 'AI meal & workout suggestions', 'included': true},
        {'text': 'Progress analytics & charts', 'included': true},
        {'text': 'Leaderboard & rewards', 'included': true},
        {'text': 'Trainer connect (1 session/mo)', 'included': true},
        {'text': 'Custom macro targets', 'included': false},
        {'text': 'Priority support', 'included': false},
      ],
    },
    {
      'name': 'Elite',
      'tagline': 'Peak performance',
      'priceMonthly': 1499,
      'priceAnnual': 1099,
      'color': AppColors.accentPurple,
      'gradientColors': [Color(0xFF2D1B4E), Color(0xFF150D28)],
      'icon': Icons.workspace_premium_rounded,
      'badge': 'BEST VALUE',
      'features': [
        {'text': 'Everything in Pro', 'included': true},
        {'text': 'Custom macro & calorie targets', 'included': true},
        {'text': 'Unlimited trainer sessions', 'included': true},
        {'text': 'Advanced body composition AI', 'included': true},
        {'text': 'Priority support (24/7)', 'included': true},
        {'text': 'Exclusive Elite challenges', 'included': true},
        {'text': 'Early access to new features', 'included': true},
        {'text': 'Personal nutrition consultant', 'included': true},
      ],
    },
  ];

  // ── Transaction history ──
  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'FitForge Pro Plan',
      'date': 'Jul 15, 2026',
      'amount': '₹599',
      'status': 'Paid',
      'icon': Icons.check_circle_rounded,
    },
    {
      'title': 'FitForge Pro Plan',
      'date': 'Jun 15, 2026',
      'amount': '₹599',
      'status': 'Paid',
      'icon': Icons.check_circle_rounded,
    },
    {
      'title': 'FitForge Pro Plan',
      'date': 'May 15, 2026',
      'amount': '₹599',
      'status': 'Paid',
      'icon': Icons.check_circle_rounded,
    },
    {
      'title': 'FitForge Pro Plan — Upgrade',
      'date': 'Apr 15, 2026',
      'amount': '₹799',
      'status': 'Paid',
      'icon': Icons.check_circle_rounded,
    },
    {
      'title': 'FitForge Free Plan',
      'date': 'Mar 10, 2026',
      'amount': '₹0',
      'status': 'Free',
      'icon': Icons.circle_outlined,
    },
  ];

  // ── Subscription API State ──
  MemberSubscription _subscription = MemberSubscription.none();
  MemberEntitlements _entitlements = MemberEntitlements.free();
  bool _subscriptionLoading = true;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      final service = ref.read(memberServiceProvider);
      final sub = await service.getMySubscription();
      final ent = await service.getMyEntitlements();
      if (mounted) {
        setState(() {
          _subscription = sub;
          _entitlements = ent;
          _subscriptionLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _subscriptionLoading = false;
        });
      }
    }
  }

  Future<void> _handleStartTrial() async {
    try {
      final service = ref.read(memberServiceProvider);
      await service.startTrial(planCode: 'MEMBER_PREMIUM_AI');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('7-Day Free Trial activated! Enjoy Pro features.'),
            backgroundColor: AppColors.accentBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _loadSubscription();
        if (widget.isStandalone) {
          widget.onCompleted?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start trial: $e'),
            backgroundColor: AppColors.accentCoral,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  // ── Helpers ──
  String _savingsLabel(int index) {
    final monthly = _plans[index]['priceMonthly'] as int;
    final annual = _plans[index]['priceAnnual'] as int;
    if (monthly == 0) return '';
    final saved = (monthly - annual) * 12;
    return 'Save ₹$saved/yr';
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Header ──
        SliverToBoxAdapter(child: _buildHeader()),

        // ── Body ──
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, widget.isStandalone ? 40 : 130),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // Current plan hero card
              if (!widget.isStandalone) ...[
                _buildCurrentPlanCard()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 100.ms)
                    .slideY(begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
                const SizedBox(height: 24),
              ],

              // Billing cycle toggle
              _buildBillingToggle()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 160.ms),
              const SizedBox(height: 16),

              // Plan cards
              _buildPlanCards()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 220.ms),
              const SizedBox(height: 24),

              // Feature comparison
              _buildSectionLabel('FEATURE COMPARISON'),
              const SizedBox(height: 12),
              _buildFeatureComparisonTable()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 280.ms),
              const SizedBox(height: 24),

              // Payment method
              if (!widget.isStandalone) ...[
                _buildSectionLabel('PAYMENT METHOD'),
                const SizedBox(height: 12),
                _buildPaymentMethod()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 340.ms),
                const SizedBox(height: 24),
              ],

              // Transaction history
              if (!widget.isStandalone) ...[
                _buildSectionLabel('BILLING HISTORY'),
                const SizedBox(height: 12),
                _buildTransactionHistory()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 400.ms),
                const SizedBox(height: 24),
              ],

              // FAQs
              _buildSectionLabel('BILLING FAQ'),
              const SizedBox(height: 12),
              _buildFAQSection()
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 460.ms),
              const SizedBox(height: 16),

              // Cancel subscription
              if (!widget.isStandalone) ...[
                _buildCancelSection()
                    .animate()
                    .fadeIn(duration: 500.ms, delay: 520.ms),
                const SizedBox(height: 8),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isStandalone ? 'Choose Your Plan' : 'Billing & Plans',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isStandalone
                      ? 'Start your fitness transformation today'
                      : 'Manage your subscription & payments',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (widget.isStandalone)
            GestureDetector(
              onTap: widget.onCompleted,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  'Skip',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.25)),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: AppColors.accentBlue,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CURRENT PLAN HERO CARD
  // ─────────────────────────────────────────────

  Widget _buildCurrentPlanCard() {
    final tier = _entitlements.tier;
    final planTitle = _entitlements.isPremium && tier != 'TRIAL_FULL'
        ? 'FitForge Pro'
        : (_entitlements.isTrial ? 'FitForge 7-Day Trial' : 'FitForge Free');
    final statusText = _subscriptionLoading
        ? 'Loading'
        : (_subscription.status.isNotEmpty ? _subscription.status : tier);
    final isAc = !_entitlements.isFree;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isAc
              ? const [Color(0xFF1B2A4A), Color(0xFF0F1528)]
              : const [Color(0xFF1F2430), Color(0xFF12151F)],
        ),
        border: Border.all(
          color: isAc ? AppColors.accentBlue.withValues(alpha: 0.40) : AppColors.glassBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT PLAN',
                          style: AppTextStyles.caption.copyWith(
                            color: isAc ? AppColors.accentBlue : AppColors.textTertiary,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.bolt_rounded,
                                color: isAc ? AppColors.accentBlue : AppColors.textTertiary,
                                size: 20),
                            const SizedBox(width: 6),
                            Text(
                              planTitle,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Status pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isAc ? const Color(0xFF16A34A) : AppColors.textTertiary)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: (isAc ? const Color(0xFF16A34A) : AppColors.glassBorder)
                                .withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isAc ? const Color(0xFF4ADE80) : AppColors.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: AppTextStyles.caption.copyWith(
                              color: isAc ? const Color(0xFF4ADE80) : AppColors.textTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                Container(height: 1, color: AppColors.glassBorder),
                const SizedBox(height: 16),

                // Renewal info row
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      icon: Icons.calendar_today_rounded,
                      label: 'Renews Aug 15, 2026',
                      color: AppColors.textSecondary,
                    ),
                    _buildInfoChip(
                      icon: Icons.payments_rounded,
                      label: '₹599 / month',
                      color: AppColors.accentBlue,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Usage meters
                _buildUsageMeter(label: 'AI Suggestions', used: 18, total: 30, color: AppColors.accentBlue),
                const SizedBox(height: 10),
                _buildUsageMeter(label: 'Trainer Sessions', used: 0, total: 1, color: AppColors.accentPurple),

                const SizedBox(height: 18),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'Upgrade to Elite',
                        isPrimary: true,
                        onTap: () {
                          setState(() => _selectedPlanIndex = 2);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        label: 'View Invoice',
                        isPrimary: false,
                        onTap: () => _showInvoiceSheet(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageMeter({required String label, required int used, required int total, required Color color}) {
    final double progress = total == 0 ? 0.0 : (used / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
            Text('$used / $total used', style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 5,
            color: AppColors.bgTertiary,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({required String label, required bool isPrimary, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isPrimary ? AppColors.primaryGradient : null,
          color: isPrimary ? null : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? Colors.transparent : AppColors.glassBorder,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isPrimary ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BILLING TOGGLE
  // ─────────────────────────────────────────────

  Widget _buildBillingToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isAnnual = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: !_isAnnual ? AppColors.accentBlue : AppColors.bgSecondary,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              border: Border.all(
                color: !_isAnnual ? AppColors.accentBlue : AppColors.glassBorder,
              ),
            ),
            child: Text(
              'Monthly',
              style: AppTextStyles.caption.copyWith(
                color: !_isAnnual ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _isAnnual = true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: _isAnnual ? AppColors.accentBlue : AppColors.bgSecondary,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
              border: Border.all(
                color: _isAnnual ? AppColors.accentBlue : AppColors.glassBorder,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Annual',
                  style: AppTextStyles.caption.copyWith(
                    color: _isAnnual ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: _isAnnual ? Colors.white.withValues(alpha: 0.2) : AppColors.accentBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Save 25%',
                    style: AppTextStyles.caption.copyWith(
                      color: _isAnnual ? Colors.white : AppColors.accentBlue,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // PLAN CARDS
  // ─────────────────────────────────────────────

  Widget _buildPlanCards() {
    return Column(
      children: List.generate(_plans.length, (index) {
        final plan = _plans[index];
        final bool isSelected = _selectedPlanIndex == index;
        final int price = _isAnnual ? plan['priceAnnual'] as int : plan['priceMonthly'] as int;
        final String savings = _isAnnual ? _savingsLabel(index) : '';
        final Color planColor = plan['color'] as Color;
        final String? badge = plan['badge'] as String?;
        final List<Color> gradientColors = List<Color>.from(plan['gradientColors'] as List);

        return GestureDetector(
          onTap: () => setState(() => _selectedPlanIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    )
                  : null,
              color: isSelected ? null : AppColors.bgSecondary,
              border: Border.all(
                color: isSelected ? planColor.withValues(alpha: 0.6) : AppColors.glassBorder,
                width: isSelected ? 1.5 : 1.0,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: planColor.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: planColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: planColor.withValues(alpha: 0.2)),
                        ),
                        child: Icon(plan['icon'] as IconData, color: planColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  plan['name'] as String,
                                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                                ),
                                if (badge != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: planColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: planColor.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      badge,
                                      style: AppTextStyles.caption.copyWith(
                                        color: planColor,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plan['tagline'] as String,
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      // Price column
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: price == 0 ? 'Free' : '₹$price',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: planColor,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                                if (price > 0)
                                  TextSpan(
                                    text: '/mo',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (savings.isNotEmpty)
                            Text(
                              savings,
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF4ADE80),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Expanded features (shown when selected)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    child: isSelected
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Container(height: 1, color: planColor.withValues(alpha: 0.2)),
                              const SizedBox(height: 12),
                              ...(plan['features'] as List<Map<String, dynamic>>).map((feature) {
                                final included = feature['included'] as bool;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 7),
                                  child: Row(
                                    children: [
                                      Icon(
                                        included ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                        color: included ? planColor : AppColors.textDisabled,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        feature['text'] as String,
                                        style: AppTextStyles.caption.copyWith(
                                          color: included ? AppColors.textPrimary : AppColors.textTertiary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              // CTA Button
                              GestureDetector(
                                onTap: () {
                                  if (widget.isStandalone && index == 0) {
                                    widget.onCompleted?.call();
                                  } else {
                                    _showUpgradeSheet(context, plan, index);
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [planColor, planColor.withValues(alpha: 0.7)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.isStandalone
                                          ? (index == 0 ? 'Continue with Free' : 'Start 7-Day Free Trial')
                                          : (index == 1
                                              ? 'Current Plan ✓'
                                              : index == 0
                                                  ? 'Downgrade to Free'
                                                  : 'Upgrade to ${plan['name']}'),
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────
  // FEATURE COMPARISON TABLE
  // ─────────────────────────────────────────────

  Widget _buildFeatureComparisonTable() {
    final features = [
      'Workout Tracking',
      'Diet Logging',
      'AI Suggestions',
      'Progress Charts',
      'Leaderboard',
      'Trainer Sessions',
      'Custom Macros',
      'Priority Support',
    ];
    final freeFeatures  = [true,  false, false, false, false, false, false, false];
    final proFeatures   = [true,  true,  true,  true,  true,  true,  false, false];
    final eliteFeatures = [true,  true,  true,  true,  true,  true,  true,  true];

    return DashboardGlassCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgTertiary.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Feature', style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  )),
                ),
                _buildTableHeaderCell('FREE', AppColors.textTertiary),
                _buildTableHeaderCell('PRO', AppColors.accentBlue),
                _buildTableHeaderCell('ELITE', AppColors.accentPurple),
              ],
            ),
          ),
          // Rows
          ...List.generate(features.length, (i) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: i.isEven ? Colors.transparent : AppColors.bgSecondary.withValues(alpha: 0.3),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      features[i],
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ),
                  _buildTableCell(freeFeatures[i], AppColors.textTertiary),
                  _buildTableCell(proFeatures[i], AppColors.accentBlue),
                  _buildTableCell(eliteFeatures[i], AppColors.accentPurple),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, Color color) {
    return Expanded(
      flex: 1,
      child: Center(
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w800, fontSize: 9),
        ),
      ),
    );
  }

  Widget _buildTableCell(bool included, Color color) {
    return Expanded(
      flex: 1,
      child: Center(
        child: Icon(
          included ? Icons.check_rounded : Icons.close_rounded,
          color: included ? color : AppColors.textDisabled,
          size: 15,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PAYMENT METHOD
  // ─────────────────────────────────────────────

  Widget _buildPaymentMethod() {
    return DashboardGlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1F5E),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Center(
                      child: Text(
                        'VISA',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•••• •••• •••• 4242',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Expires 09/2029',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Text(
                  'Change',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.glassBorder),
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, color: AppColors.accentBlue, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Add Payment Method',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Icon(Icons.lock_rounded, color: AppColors.textTertiary, size: 13),
              const SizedBox(width: 4),
              Text(
                'Secured by Razorpay',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TRANSACTION HISTORY
  // ─────────────────────────────────────────────

  Widget _buildTransactionHistory() {
    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: _transactions.map((tx) {
          final isPaid = tx['status'] == 'Paid';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isPaid
                        ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                        : AppColors.bgTertiary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPaid
                          ? const Color(0xFF16A34A).withValues(alpha: 0.25)
                          : AppColors.glassBorder,
                    ),
                  ),
                  child: Icon(
                    tx['icon'] as IconData,
                    color: isPaid ? const Color(0xFF4ADE80) : AppColors.textTertiary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx['title'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tx['date'] as String,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      tx['amount'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                            : AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        tx['status'] as String,
                        style: AppTextStyles.caption.copyWith(
                          color: isPaid ? const Color(0xFF4ADE80) : AppColors.textTertiary,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // FAQ SECTION
  // ─────────────────────────────────────────────

  Widget _buildFAQSection() {
    final faqs = [
      {
        'q': 'When will I be charged?',
        'a': 'You will be charged at the start of each billing cycle. Annual plans are charged once a year, monthly plans every month.',
      },
      {
        'q': 'Can I change my plan anytime?',
        'a': 'Yes! You can upgrade or downgrade your plan at any time. Upgrades take effect immediately, downgrades at your next billing cycle.',
      },
      {
        'q': 'What happens if I cancel?',
        'a': 'You retain full access until the end of your current billing period. After that your account reverts to the Free plan.',
      },
      {
        'q': 'Is my payment information secure?',
        'a': 'Absolutely. We use Razorpay, a PCI-DSS compliant payment processor. We never store your card details on our servers.',
      },
    ];

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: _FAQList(faqs: faqs),
    );
  }

  // ─────────────────────────────────────────────
  // CANCEL SUBSCRIPTION
  // ─────────────────────────────────────────────

  Widget _buildCancelSection() {
    return GestureDetector(
      onTap: () => _showCancelSheet(context),
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
            'Cancel Subscription',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accentCoral,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SECTION LABEL
  // ─────────────────────────────────────────────

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

  // ─────────────────────────────────────────────
  // BOTTOM SHEETS
  // ─────────────────────────────────────────────

  void _showUpgradeSheet(BuildContext context, Map<String, dynamic> plan, int index) {
    if (index == 1) return; // Current plan — do nothing

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
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Icon(plan['icon'] as IconData, color: plan['color'] as Color, size: 36),
            const SizedBox(height: 12),
            Text(
              index == 2 ? 'Upgrade to Elite' : 'Downgrade to Free',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              index == 2
                  ? 'Unlock unlimited trainer sessions, advanced AI, and exclusive elite challenges.'
                  : 'Downgrade to the free plan. You\'ll lose all premium features at end of billing period.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                if (index == 1) {
                  _handleStartTrial();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(index == 2 ? 'Upgraded to Elite plan!' : 'Downgraded to Free plan.'),
                      backgroundColor: AppColors.bgSecondary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                  if (widget.isStandalone) {
                    widget.onCompleted?.call();
                  }
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [(plan['color'] as Color), (plan['color'] as Color).withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Confirm & Switch',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvoiceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.receipt_long_rounded, color: AppColors.accentBlue, size: 36),
            const SizedBox(height: 12),
            Text('Invoice — Jul 15, 2026', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            _buildInvoiceRow('Plan', 'FitForge Pro — Annual'),
            _buildInvoiceRow('Billing Period', 'Jul 15 – Aug 14, 2026'),
            _buildInvoiceRow('Amount', '₹599'),
            _buildInvoiceRow('GST (18%)', '₹107.82'),
            Container(height: 1, color: AppColors.glassBorder, margin: const EdgeInsets.symmetric(vertical: 12)),
            _buildInvoiceRow('Total', '₹706.82', bold: true),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Download PDF',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: bold ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              fontSize: bold ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: AppColors.accentCoral.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_rounded, color: AppColors.accentCoral, size: 28),
            ),
            const SizedBox(height: 14),
            Text('Cancel Subscription?', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              'You\'ll lose all Pro features at the end of your billing period. Your data will be preserved.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Subscription cancelled. Access continues until Aug 14.'),
                    backgroundColor: AppColors.bgSecondary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.accentCoral.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Text(
                    'Yes, Cancel Subscription',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCoral, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Text(
                'Keep my subscription',
                style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FAQ LIST — separate StatefulWidget for expansion state
// ─────────────────────────────────────────────

class _FAQList extends StatefulWidget {
  final List<Map<String, String>> faqs;

  const _FAQList({required this.faqs});

  @override
  State<_FAQList> createState() => _FAQListState();
}

class _FAQListState extends State<_FAQList> {
  int? _expanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.faqs.length, (i) {
        final faq = widget.faqs[i];
        final isOpen = _expanded == i;

        return Column(
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = isOpen ? null : i),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        faq['q']!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 220),
                      child: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: isOpen
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        faq['a']!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            if (i < widget.faqs.length - 1)
              Container(height: 1, color: AppColors.glassBorder),
          ],
        );
      }),
    );
  }
}
