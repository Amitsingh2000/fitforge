import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/brilliant_theme.dart';
import '../widgets/dashboard_glass_card.dart';

class BillingPlansScreen extends StatelessWidget {
  final VoidCallback? onCompleted;
  const BillingPlansScreen({super.key, this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrilliantColors.bgPrimary,
      body: SafeArea(
        child: BillingPlansContent(
          isStandalone: true,
          onCompleted: onCompleted ?? () {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          },
        ),
      ),
    );
  }
}

/// Billing & Plans content — embedded inside HomeDashboard's DashboardShell.
class BillingPlansContent extends StatefulWidget {
  final bool isStandalone;
  final VoidCallback? onCompleted;

  const BillingPlansContent({
    super.key,
    this.isStandalone = false,
    this.onCompleted,
  });

  @override
  State<BillingPlansContent> createState() => _BillingPlansContentState();
}

class _BillingPlansContentState extends State<BillingPlansContent>
    with SingleTickerProviderStateMixin {
  int _selectedPlanIndex = 1;
  bool _isAnnual = true;

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Free',
      'tagline': 'Great to start',
      'priceMonthly': 0,
      'priceAnnual': 0,
      'color': BrilliantColors.textMuted,
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
      'color': BrilliantColors.mint,
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
      'color': BrilliantColors.amber,
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

  final List<Map<String, dynamic>> _transactions = [
    {
      'title': 'FitForge Pro Plan',
      'date': 'Jul 15, 2026',
      'amount': '₹599',
      'status': 'Paid',
    },
    {
      'title': 'FitForge Pro Plan',
      'date': 'Jun 15, 2026',
      'amount': '₹599',
      'status': 'Paid',
    },
    {
      'title': 'FitForge Pro Plan',
      'date': 'May 15, 2026',
      'amount': '₹599',
      'status': 'Paid',
    },
  ];

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
        SliverToBoxAdapter(child: _buildHeader()),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, widget.isStandalone ? 40 : 120),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              if (!widget.isStandalone) ...[
                _buildCurrentPlanCard()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.05, end: 0, duration: 400.ms, delay: 100.ms),
                const SizedBox(height: 20),
              ],

              _buildBillingToggle()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms),
              const SizedBox(height: 16),

              _buildPlanCards()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms),
              const SizedBox(height: 20),

              _buildSectionLabel('FEATURE COMPARISON'),
              const SizedBox(height: 10),
              _buildFeatureComparisonTable()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 250.ms),
              const SizedBox(height: 20),

              if (!widget.isStandalone) ...[
                _buildSectionLabel('PAYMENT METHOD'),
                const SizedBox(height: 10),
                _buildPaymentMethod()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms),
                const SizedBox(height: 20),

                _buildSectionLabel('BILLING HISTORY'),
                const SizedBox(height: 10),
                _buildTransactionHistory()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 350.ms),
                const SizedBox(height: 20),
              ],

              _buildSectionLabel('BILLING FAQ'),
              const SizedBox(height: 10),
              const _FAQList()
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 16),

              if (!widget.isStandalone) ...[
                _buildCancelSection()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 450.ms),
                const SizedBox(height: 8),
              ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isStandalone ? 'Choose Your Plan' : 'Billing & Plans',
                  style: BrilliantTheme.headerStyle(fontSize: 22),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isStandalone
                      ? 'Start your fitness transformation today'
                      : 'Manage subscription & invoices',
                  style: BrilliantTheme.bodyStyle(fontSize: 12, color: BrilliantColors.textMuted),
                ),
              ],
            ),
          ),
          if (widget.isStandalone)
            GestureDetector(
              onTap: widget.onCompleted,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: BrilliantColors.bgSecondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BrilliantColors.surfaceBorder),
                ),
                child: const Text('Skip', style: TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: BrilliantTheme.badgeStyle(color: BrilliantColors.mint));
  }

  Widget _buildCurrentPlanCard() {
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
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: BrilliantColors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text('Current Active Plan', style: BrilliantTheme.titleStyle(fontSize: 15)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BrilliantColors.mint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('ACTIVE', style: TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('FitForge Pro · ₹599 / month', style: TextStyle(color: BrilliantColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
          const Text('Renews automatically on Aug 15, 2026', style: TextStyle(color: BrilliantColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BrilliantColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BrilliantColors.surfaceBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAnnual = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isAnnual ? BrilliantColors.mint : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Monthly Billing',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: !_isAnnual ? BrilliantColors.textInverse : BrilliantColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isAnnual = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isAnnual ? BrilliantColors.mint : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Annual Billing',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _isAnnual ? BrilliantColors.textInverse : BrilliantColors.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isAnnual ? BrilliantColors.textInverse : BrilliantColors.amber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Save 25%',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: _isAnnual ? BrilliantColors.mint : BrilliantColors.textInverse,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCards() {
    return Column(
      children: List.generate(_plans.length, (index) {
        final plan = _plans[index];
        final isSelected = _selectedPlanIndex == index;
        final price = _isAnnual ? plan['priceAnnual'] : plan['priceMonthly'];

        return GestureDetector(
          onTap: () => setState(() => _selectedPlanIndex = index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: BrilliantColors.bgSecondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected ? (plan['color'] as Color) : BrilliantColors.surfaceBorder,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(plan['icon'] as IconData, color: plan['color'] as Color, size: 22),
                        const SizedBox(width: 8),
                        Text(plan['name'] as String, style: BrilliantTheme.headerStyle(fontSize: 18)),
                      ],
                    ),
                    if (plan['badge'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (plan['color'] as Color).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          plan['badge'] as String,
                          style: TextStyle(color: plan['color'] as Color, fontWeight: FontWeight.w900, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  price == 0 ? 'Free Forever' : '₹$price / month',
                  style: const TextStyle(color: BrilliantColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                if (_isAnnual && _savingsLabel(index).isNotEmpty)
                  Text(_savingsLabel(index), style: const TextStyle(color: BrilliantColors.mint, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                BrilliantButton(
                  fullWidth: true,
                  onPressed: isSelected ? () {} : () => setState(() => _selectedPlanIndex = index),
                  color: isSelected ? (plan['color'] as Color) : BrilliantColors.bgTertiary,
                  shadowColor: isSelected ? BrilliantColors.mintDark : BrilliantColors.surfaceBorder,
                  textColor: isSelected ? BrilliantColors.textInverse : BrilliantColors.textPrimary,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(isSelected ? 'Current Selection' : 'Choose Plan', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildFeatureComparisonTable() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Column(
        children: [
          const Row(
            children: [
              Expanded(flex: 2, child: Text('Feature', style: TextStyle(color: BrilliantColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
              Expanded(child: Text('Free', textAlign: TextAlign.center, style: TextStyle(color: BrilliantColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700))),
              Expanded(child: Text('Pro', textAlign: TextAlign.center, style: TextStyle(color: BrilliantColors.mint, fontSize: 11, fontWeight: FontWeight.w800))),
              Expanded(child: Text('Elite', textAlign: TextAlign.center, style: TextStyle(color: BrilliantColors.amber, fontSize: 11, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: BrilliantColors.surfaceBorder),
          _buildFeatureRow('Diet Logging', '7 Days', 'Unlimited', 'Unlimited'),
          _buildFeatureRow('AI Insights', '✕', '✓', '✓'),
          _buildFeatureRow('Trainer Session', '✕', '1 / mo', 'Unlimited'),
          _buildFeatureRow('Composition AI', '✕', 'Basic', 'Advanced'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, String free, String pro, String elite) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(feature, style: const TextStyle(color: BrilliantColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600))),
          Expanded(child: Text(free, textAlign: TextAlign.center, style: const TextStyle(color: BrilliantColors.textMuted, fontSize: 11))),
          Expanded(child: Text(pro, textAlign: TextAlign.center, style: const TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 11))),
          Expanded(child: Text(elite, textAlign: TextAlign.center, style: const TextStyle(color: BrilliantColors.amber, fontWeight: FontWeight.w800, fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: BrilliantColors.bgSecondary,
      borderColor: BrilliantColors.surfaceBorder,
      child: Row(
        children: [
          const Icon(Icons.credit_card_rounded, color: BrilliantColors.mint, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Visa ending in •••• 4242', style: TextStyle(color: BrilliantColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 13)),
                Text('Expires 12/28 · Razorpay Secure', style: TextStyle(color: BrilliantColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      children: _transactions.map((t) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: BrilliantColors.bgSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BrilliantColors.surfaceBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['title'] as String, style: const TextStyle(color: BrilliantColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 13)),
                  Text(t['date'] as String, style: TextStyle(color: BrilliantColors.textMuted, fontSize: 11)),
                ],
              ),
              Text(t['amount'] as String, style: const TextStyle(color: BrilliantColors.mint, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCancelSection() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: const Text('Cancel Subscription', style: TextStyle(color: BrilliantColors.coral, fontSize: 12, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _FAQList extends StatefulWidget {
  const _FAQList();

  @override
  State<_FAQList> createState() => _FAQListState();
}

class _FAQListState extends State<_FAQList> {
  final List<Map<String, String>> _faqs = [
    {'q': 'Can I change plans anytime?', 'a': 'Yes! Upgrades apply immediately.'},
    {'q': 'What payment methods are supported?', 'a': 'We support UPI, Cards, NetBanking, and Razorpay.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(_faqs.length, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: BrilliantColors.bgSecondary,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BrilliantColors.surfaceBorder),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: ExpansionTile(
              shape: const Border(),
              title: Text(_faqs[index]['q']!, style: const TextStyle(color: BrilliantColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Text(_faqs[index]['a']!, style: TextStyle(color: BrilliantColors.textMuted, fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
