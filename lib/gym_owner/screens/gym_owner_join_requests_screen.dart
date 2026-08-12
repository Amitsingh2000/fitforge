import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';
import '../../models/join_request.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';

/// `GET/POST /gyms/:gymId/join-requests` — pending self-serve member join
/// requests (found via search/activation code), owner approves or rejects.
class GymOwnerJoinRequestsScreen extends ConsumerStatefulWidget {
  const GymOwnerJoinRequestsScreen({super.key});

  @override
  ConsumerState<GymOwnerJoinRequestsScreen> createState() =>
      _GymOwnerJoinRequestsScreenState();
}

class _GymOwnerJoinRequestsScreenState
    extends ConsumerState<GymOwnerJoinRequestsScreen> {
  List<JoinRequest> _requests = [];
  bool _loading = true;
  String? _error;
  final Set<String> _actioningIds = {};

  final List<String> _rejectionReasons = [
    'Gym at Full Capacity',
    'Out of Service Area',
    'Incomplete Profile',
    'Payment Issue',
    'Other (Type Below)'
  ];

  String? _selectedRejectionReason;
  final TextEditingController _customReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) {
      setState(() { _loading = false; _error = 'No gym selected.'; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final requests = await ref.read(gymOwnerServiceProvider).getJoinRequests(gymId);
      if (mounted) setState(() { _requests = requests; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _acceptRequest(JoinRequest request) async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    setState(() => _actioningIds.add(request.membershipId));
    try {
      await ref.read(gymOwnerServiceProvider).approveJoinRequest(gymId, request.membershipId);
      if (!mounted) return;
      setState(() {
        _requests.removeWhere((r) => r.membershipId == request.membershipId);
        _actioningIds.remove(request.membershipId);
      });
      _showSnackBar('Accepted ${request.fullName}. Membership activated.', AppColors.accentCyan);
    } catch (e) {
      if (!mounted) return;
      setState(() => _actioningIds.remove(request.membershipId));
      _showSnackBar(friendlyApiError(e), AppColors.accentCoral);
    }
  }

  Future<void> _rejectRequest(JoinRequest request, String? reason) async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    setState(() => _actioningIds.add(request.membershipId));
    try {
      await ref
          .read(gymOwnerServiceProvider)
          .rejectJoinRequest(gymId, request.membershipId, reason: reason);
      if (!mounted) return;
      setState(() {
        _requests.removeWhere((r) => r.membershipId == request.membershipId);
        _actioningIds.remove(request.membershipId);
      });
      _showSnackBar('Request from ${request.fullName} rejected.', AppColors.accentCoral);
    } catch (e) {
      if (!mounted) return;
      setState(() => _actioningIds.remove(request.membershipId));
      _showSnackBar(friendlyApiError(e), AppColors.accentCoral);
    }
  }

  void _showRejectionDialog(JoinRequest request) {
    setState(() {
      _selectedRejectionReason = null;
      _customReasonController.clear();
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
            return Container(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 36 + bottomPadding),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: AppColors.textDisabled,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.accentCoral.withValues(alpha: 0.15),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.block_rounded,
                              color: AppColors.accentCoral,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reject Request',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Select a reason for rejecting ${request.fullName}',
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _rejectionReasons.map((reason) {
                        final isSelected = _selectedRejectionReason == reason;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              _selectedRejectionReason = reason;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? AppColors.accentCoral
                                      .withValues(alpha: 0.15)
                                  : AppColors.glassBg,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.accentCoral
                                        .withValues(alpha: 0.5)
                                    : AppColors.glassBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              reason,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: isSelected
                                    ? AppColors.accentCoral
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
                    if (_selectedRejectionReason == 'Other (Type Below)') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.glassBg,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: TextField(
                          controller: _customReasonController,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter rejection reason...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: AppColors.glassBg,
                                border: Border.all(
                                    color: AppColors.glassBorder),
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: _selectedRejectionReason == null
                                ? null
                                : () {
                                    final reason =
                                        _selectedRejectionReason ==
                                                'Other (Type Below)'
                                            ? _customReasonController.text.trim()
                                            : _selectedRejectionReason;
                                    Navigator.pop(context);
                                    _rejectRequest(
                                        request,
                                        (reason?.isEmpty ?? true) ? null : reason);
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: _selectedRejectionReason == null
                                    ? null
                                    : const LinearGradient(
                                        colors: [
                                          AppColors.accentCoral,
                                          Colors.redAccent,
                                        ],
                                      ),
                                color: _selectedRejectionReason == null
                                    ? AppColors.bgTertiary
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  'Confirm Reject',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: _selectedRejectionReason == null
                                        ? AppColors.textDisabled
                                        : Colors.white,
                                    fontWeight: FontWeight.w700,
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
          },
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == AppColors.accentCyan
                  ? Icons.check_circle_rounded
                  : Icons.info_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.glassBg,
                        border:
                            Border.all(color: AppColors.glassBorder, width: 1),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new_rounded,
                            color: AppColors.textPrimary, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Join Requests',
                        style: AppTextStyles.titleLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${_requests.length} pending applications',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.05, end: 0, duration: 400.ms),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) return const LoadingView(message: 'Loading join requests...');
    if (_error != null) return ErrorRetryView(message: _error!, onRetry: _load);
    if (_requests.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.accentBlue,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        itemCount: _requests.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildRequestCard(_requests[index])
                .animate(key: ValueKey(_requests[index].membershipId))
                .fadeIn(duration: 500.ms, delay: Duration(milliseconds: index * 100))
                .slideY(begin: 0.1, end: 0, duration: 500.ms, delay: Duration(milliseconds: index * 100)),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const EmptyStateView(
      icon: Icons.done_all_rounded,
      title: 'All caught up!',
      subtitle: 'No pending join requests.',
    );
  }

  Widget _buildRequestCard(JoinRequest request) {
    const color = AppColors.accentBlue;
    final isActioning = _actioningIds.contains(request.membershipId);

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: color.withValues(alpha: 0.15),
                ),
                child: Center(
                  child: Text(
                    request.initials,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.fullName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          color: AppColors.textTertiary,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Requested ${_formatRelativeTime(request.requestedAt)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.bgPrimary.withValues(alpha: 0.3),
              border: Border.all(
                color: AppColors.glassBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow(Icons.email_rounded, 'Email',
                    request.email.isNotEmpty ? request.email : '—'),
                const SizedBox(height: 10),
                _buildDetailRow(Icons.phone_rounded, 'Phone',
                    request.phone ?? '—'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: isActioning ? null : () => _acceptRequest(request),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [AppColors.accentCyan, AppColors.accentBlue],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentCyan.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: isActioning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'Accept',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: isActioning ? null : () => _showRejectionDialog(request),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.accentCoral.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.accentCoral.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Reject',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.accentCoral,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
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
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 14),
        const SizedBox(width: 6),
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  String _formatRelativeTime(DateTime? dt) {
    if (dt == null) return 'recently';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'yesterday';
    return '${diff.inDays}d ago';
  }
}
