import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/join_request.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadRequests());
  }

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null || gymId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = ref.read(gymOwnerServiceProvider);
      final list = await service.getJoinRequests(gymId);
      if (mounted) {
        setState(() {
          _requests = list;
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

  Future<void> _acceptRequest(JoinRequest request) async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;

    try {
      await ref
          .read(gymOwnerServiceProvider)
          .approveJoinRequest(gymId, request.membershipId);

      setState(() {
        _requests.removeWhere((req) => req.membershipId == request.membershipId);
      });
      _showSnackBar(
        'Accepted ${request.fullName}. Membership onboarding assigned.',
        AppColors.accentCyan,
      );
    } catch (e) {
      _showSnackBar('Failed to approve: ${friendlyApiError(e)}', AppColors.accentCoral);
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

                    // Reasons
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

                    // Custom Reason Input
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

                    // Actions
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
                                : () async {
                                    final gymId = ref.read(currentGymIdProvider);
                                    if (gymId == null) return;

                                    final finalReason = _selectedRejectionReason == 'Other (Type Below)'
                                        ? _customReasonController.text.trim()
                                        : _selectedRejectionReason;

                                    Navigator.pop(context);

                                    try {
                                      await ref
                                          .read(gymOwnerServiceProvider)
                                          .rejectJoinRequest(
                                            gymId,
                                            request.membershipId,
                                            reason: finalReason,
                                          );

                                      setState(() {
                                        _requests.removeWhere(
                                            (req) => req.membershipId == request.membershipId);
                                      });
                                      _showSnackBar(
                                        'Request from ${request.fullName} rejected.',
                                        AppColors.accentCoral,
                                      );
                                    } catch (e) {
                                      _showSnackBar(
                                        'Failed to reject: ${friendlyApiError(e)}',
                                        AppColors.accentCoral,
                                      );
                                    }
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
            // Header
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
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                    onPressed: _loadRequests,
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.05, end: 0, duration: 400.ms),
            ),

            // Content
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Text(
                            _error!,
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCoral),
                          ),
                        )
                      : _requests.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: _loadRequests,
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                                itemCount: _requests.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildRequestCard(_requests[index])
                                        .animate(key: ValueKey(_requests[index].membershipId))
                                        .fadeIn(
                                            duration: 500.ms,
                                            delay:
                                                Duration(milliseconds: index * 100))
                                        .slideY(
                                            begin: 0.1,
                                            end: 0,
                                            duration: 500.ms,
                                            delay:
                                                Duration(milliseconds: index * 100)),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentBlue.withValues(alpha: 0.05),
            ),
            child: Icon(
              Icons.done_all_rounded,
              size: 48,
              color: AppColors.accentBlue.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up!',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No pending join requests.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ]
            .animate(interval: 100.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.1, end: 0, duration: 600.ms),
      ),
    );
  }

  Widget _buildRequestCard(JoinRequest request) {
    const color = AppColors.accentBlue;

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──
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
                          'Requested ${_timeAgo(request.requestedAt)}',
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

          // ── Details Grid ──
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.bgPrimary.withValues(alpha: 0.3),
              border: Border.all(
                color: AppColors.glassBorder.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.cake_rounded, 'Age', request.age ?? 'N/A'),
                      const SizedBox(height: 10),
                      _buildDetailRow(Icons.flag_rounded, 'Goal', request.fitnessGoal ?? 'Fitness'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.monitor_weight_rounded, 'Weight', request.weight != null ? '${request.weight} kg' : 'N/A'),
                      const SizedBox(height: 10),
                      _buildDetailRow(Icons.sports_rounded, 'Trainer', request.preferredTrainerName ?? 'Any'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Action Buttons ──
          Row(
            children: [
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () => _acceptRequest(request),
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
                      child: Text(
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
                  onTap: () => _showRejectionDialog(request),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return diff.inMinutes <= 1 ? 'Just now' : '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else {
      return '${diff.inDays} days ago';
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
