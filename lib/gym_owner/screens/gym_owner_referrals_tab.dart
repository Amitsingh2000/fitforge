import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';

class GymOwnerReferralsTab extends StatefulWidget {
  const GymOwnerReferralsTab({super.key});

  @override
  State<GymOwnerReferralsTab> createState() => _GymOwnerReferralsTabState();
}

class _GymOwnerReferralsTabState extends State<GymOwnerReferralsTab> {
  // ── Stats ──
  int _generated = 24;
  int _used = 16;
  int _expired = 4;

  int get _remaining => _generated - _used - _expired;

  // ── Generated code (latest) ──
  String? _latestCode;
  String? _latestDiscount;
  String? _latestValidity;
  bool _latestCopied = false;

  // ── History ──
  final List<Map<String, dynamic>> _referralHistory = [
    {
      'code': 'FIT20ABX',
      'memberName': 'Rahul Sharma',
      'usedOn': '28 Jun 2026',
      'status': 'Used',
    },
    {
      'code': 'FIT30CKP',
      'memberName': 'Priya Patel',
      'usedOn': '25 Jun 2026',
      'status': 'Used',
    },
    {
      'code': 'FIT15DJL',
      'memberName': 'Vikram Singh',
      'usedOn': '22 Jun 2026',
      'status': 'Expired',
    },
    {
      'code': 'FIT50RQZ',
      'memberName': 'Sneha Gupta',
      'usedOn': '20 Jun 2026',
      'status': 'Used',
    },
    {
      'code': 'FIT10YNB',
      'memberName': 'Arjun Reddy',
      'usedOn': '18 Jun 2026',
      'status': 'Used',
    },
    {
      'code': 'FIT25MXW',
      'memberName': '—',
      'usedOn': '—',
      'status': 'Unused',
    },
    {
      'code': 'FIT20TGH',
      'memberName': 'Deepa Nair',
      'usedOn': '15 Jun 2026',
      'status': 'Used',
    },
    {
      'code': 'FIT30VPC',
      'memberName': '—',
      'usedOn': '—',
      'status': 'Expired',
    },
    {
      'code': 'FIT40KRJ',
      'memberName': 'Karan Mehta',
      'usedOn': '10 Jun 2026',
      'status': 'Used',
    },
    {
      'code': 'FIT15ZQD',
      'memberName': 'Ananya Iyer',
      'usedOn': '8 Jun 2026',
      'status': 'Used',
    },
  ];

  // ── Generate Code popup values ──
  int _popupDiscount = 20;
  int _popupValidity = 30;
  final List<int> _discountOptions = [10, 15, 20, 25, 30, 40, 50];
  final List<int> _validityOptions = [7, 14, 30, 60, 90];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Referrals',
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage codes & track referrals',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    // Generate code button
                    GestureDetector(
                      onTap: () => _showGeneratePopup(),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentBlue.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'New Code',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
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
                  .slideY(begin: -0.05, end: 0, duration: 500.ms),
            ),

            // ── Referral Statistics Card ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildStatsRow(),
              )
                  .animate()
                  .fadeIn(duration: 500.ms, delay: 100.ms)
                  .slideY(
                      begin: 0.05, end: 0, duration: 500.ms, delay: 100.ms),
            ),

            // ── Latest Generated Code Card ──
            if (_latestCode != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildGeneratedCodeCard(),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: 500.ms,
                        curve: Curves.easeOutBack),
              ),

            // ── History Section Label ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 20, 12),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'REFERRAL HISTORY',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: AppColors.accentBlue.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.accentBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        '${_referralHistory.length} codes',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
            ),

            // ── History Table Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
                child: _buildHistoryHeader(),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 350.ms),
            ),

            // ── History List ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 130),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildHistoryRow(_referralHistory[index], index)
                          .animate()
                          .fadeIn(
                              duration: 400.ms,
                              delay: Duration(
                                  milliseconds: 380 + index * 40))
                          .slideX(
                              begin: 0.03,
                              end: 0,
                              duration: 400.ms,
                              delay: Duration(
                                  milliseconds: 380 + index * 40)),
                    );
                  },
                  childCount: _referralHistory.length,
                ),
              ),
            ),
          ],
        ),

        // ── FAB ──
        Positioned(
          bottom: 90,
          right: 20,
          child: _buildFAB()
              .animate()
              .scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  delay: 500.ms,
                  curve: Curves.elasticOut),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  REFERRAL STATISTICS
  // ═══════════════════════════════════════════════

  Widget _buildStatsRow() {
    final stats = [
      {
        'title': 'Generated',
        'value': '$_generated',
        'icon': Icons.confirmation_number_rounded,
        'color': AppColors.accentBlue,
      },
      {
        'title': 'Used',
        'value': '$_used',
        'icon': Icons.check_circle_rounded,
        'color': AppColors.accentCyan,
      },
      {
        'title': 'Expired',
        'value': '$_expired',
        'icon': Icons.timer_off_rounded,
        'color': AppColors.accentCoral,
      },
      {
        'title': 'Remaining',
        'value': '$_remaining',
        'icon': Icons.inventory_2_rounded,
        'color': AppColors.accentPurple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.7,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final color = stat['color'] as Color;
        return DashboardGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: 16,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color.withValues(alpha: 0.12),
                ),
                child: Center(
                  child: Icon(stat['icon'] as IconData, color: color, size: 16),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stat['value'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      stat['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 9,
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

  // ═══════════════════════════════════════════════
  //  GENERATE CODE POPUP
  // ═══════════════════════════════════════════════

  void _showGeneratePopup() {
    setState(() {
      _popupDiscount = 20;
      _popupValidity = 30;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: AppColors.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: AppColors.primaryGradient,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Generate Referral Code',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'One-time activation code for new members',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Discount Selector ──
                  _buildPopupSection(
                    label: 'Discount',
                    icon: Icons.percent_rounded,
                    color: AppColors.accentBlue,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _discountOptions.map((d) {
                        final isSelected = d == _popupDiscount;
                        return GestureDetector(
                          onTap: () =>
                              setSheetState(() => _popupDiscount = d),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? AppColors.accentBlue
                                      .withValues(alpha: 0.15)
                                  : AppColors.glassBg,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentBlue
                                        .withValues(alpha: 0.5)
                                    : AppColors.glassBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              '$d%',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? AppColors.accentBlue
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Validity Selector ──
                  _buildPopupSection(
                    label: 'Validity',
                    icon: Icons.schedule_rounded,
                    color: AppColors.accentCyan,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _validityOptions.map((v) {
                        final isSelected = v == _popupValidity;
                        return GestureDetector(
                          onTap: () =>
                              setSheetState(() => _popupValidity = v),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? AppColors.accentCyan
                                      .withValues(alpha: 0.15)
                                  : AppColors.glassBg,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentCyan
                                        .withValues(alpha: 0.5)
                                    : AppColors.glassBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              '$v Days',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? AppColors.accentCyan
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Usage Info ──
                  _buildPopupSection(
                    label: 'Usage',
                    icon: Icons.repeat_one_rounded,
                    color: AppColors.accentPurple,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color:
                            AppColors.accentPurple.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.accentPurple
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.looks_one_rounded,
                            color: AppColors.accentPurple,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'One Time Only',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.accentPurple,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Generate Button ──
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _generateCode();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.accentBlue,
                            Color(0xFF6366F1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentBlue
                                .withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Generate Code',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPopupSection({
    required String label,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  void _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random();
    final suffix =
        List.generate(3, (_) => chars[rng.nextInt(chars.length)]).join();
    final code = 'FIT$_popupDiscount$suffix';

    setState(() {
      _latestCode = code;
      _latestDiscount = '$_popupDiscount%';
      _latestValidity = '$_popupValidity Days';
      _latestCopied = false;
      _generated++;

      // Add to history top
      _referralHistory.insert(0, {
        'code': code,
        'memberName': '—',
        'usedOn': '—',
        'status': 'Unused',
      });
    });
  }

  // ═══════════════════════════════════════════════
  //  GENERATED CODE CARD (Premium Coupon Style)
  // ═══════════════════════════════════════════════

  Widget _buildGeneratedCodeCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accentBlue.withValues(alpha: 0.12),
            AppColors.accentPurple.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(
          color: AppColors.accentBlue.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Column(
            children: [
              // ── Card Header ──
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentBlue.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: AppColors.primaryGradient,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.confirmation_number_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Generated Code',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.accentCyan.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.accentCyan.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentCyan,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentCyan
                                      .withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Unused',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accentCyan,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Dashed divider ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: List.generate(
                    40,
                    (_) => Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        color: AppColors.glassBorder,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Code Display ──
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Column(
                  children: [
                    // Code
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: AppColors.bgPrimary.withValues(alpha: 0.6),
                        border: Border.all(
                          color: AppColors.accentBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _latestCode!,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 28,
                            letterSpacing: 4,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Info chips
                    Row(
                      children: [
                        _buildCodeInfoChip(
                          Icons.percent_rounded,
                          _latestDiscount!,
                          AppColors.accentBlue,
                        ),
                        const SizedBox(width: 8),
                        _buildCodeInfoChip(
                          Icons.schedule_rounded,
                          _latestValidity!,
                          AppColors.accentCyan,
                        ),
                        const SizedBox(width: 8),
                        _buildCodeInfoChip(
                          Icons.looks_one_rounded,
                          'One Time',
                          AppColors.accentPurple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Copy + Share buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: _latestCode!));
                              setState(() => _latestCopied = true);
                              _showSnackBar('Code copied to clipboard!');
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _latestCopied
                                    ? AppColors.accentCyan
                                        .withValues(alpha: 0.12)
                                    : AppColors.glassBg,
                                border: Border.all(
                                  color: _latestCopied
                                      ? AppColors.accentCyan
                                          .withValues(alpha: 0.4)
                                      : AppColors.glassBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _latestCopied
                                        ? Icons.check_rounded
                                        : Icons.copy_rounded,
                                    color: _latestCopied
                                        ? AppColors.accentCyan
                                        : AppColors.textSecondary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _latestCopied ? 'Copied!' : 'Copy',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: _latestCopied
                                          ? AppColors.accentCyan
                                          : AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showSnackBar(
                                'Share sheet opening for $_latestCode'),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: AppColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentBlue
                                        .withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.share_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Share',
                                    style:
                                        AppTextStyles.labelLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeInfoChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.06),
          border: Border.all(color: color.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 11),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  HISTORY TABLE
  // ═══════════════════════════════════════════════

  Widget _buildHistoryHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.bgTertiary.withValues(alpha: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Code',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Member',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Used On',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Status',
              textAlign: TextAlign.right,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w700,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(Map<String, dynamic> entry, int index) {
    final status = entry['status'] as String;
    Color statusColor;
    switch (status) {
      case 'Used':
        statusColor = AppColors.accentCyan;
        break;
      case 'Unused':
        statusColor = AppColors.accentBlue;
        break;
      case 'Expired':
        statusColor = AppColors.accentCoral;
        break;
      default:
        statusColor = AppColors.textTertiary;
    }

    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: 12,
      child: Row(
        children: [
          // Code
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    entry['code'] as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.accentBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Member
          Expanded(
            flex: 3,
            child: Text(
              entry['memberName'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Used On
          Expanded(
            flex: 3,
            child: Text(
              entry['usedOn'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: statusColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  FAB
  // ═══════════════════════════════════════════════

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () => _showGeneratePopup(),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.accentCyan, AppColors.accentBlue],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentCyan.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppColors.accentCyan.withValues(alpha: 0.15),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        backgroundColor: AppColors.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
