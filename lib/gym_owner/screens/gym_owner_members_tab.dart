import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_member.dart';
import '../../models/gym_trainer.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/state_views.dart';
import 'add_member_screen.dart';
import 'bulk_import_screen.dart';
import 'member_detail_screen.dart';

const _statusFilters = ['All', 'Active', 'Expired', 'Frozen', 'Pending'];

class GymOwnerMembersTab extends ConsumerStatefulWidget {
  const GymOwnerMembersTab({super.key});

  @override
  ConsumerState<GymOwnerMembersTab> createState() => _GymOwnerMembersTabState();
}

class _GymOwnerMembersTabState extends ConsumerState<GymOwnerMembersTab> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  String? _selectedTrainerFilter;
  final TextEditingController _searchController = TextEditingController();

  List<GymMember> _members = [];
  List<GymTrainer> _trainers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMembers());
  }

  Future<void> _loadMembers() async {
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
      final results = await Future.wait([
        service.getMembers(gymId),
        service.getTrainersRoster(gymId),
      ]);
      if (mounted) {
        setState(() {
          _members = results[0] as List<GymMember>;
          _trainers = results[1] as List<GymTrainer>;
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

  Future<void> _removeMember(GymMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove member?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This removes ${member.fullName} from the gym roster.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: AppColors.accentCoral)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    try {
      await ref.read(gymOwnerServiceProvider).removeMember(gymId, member.membershipId);
      if (mounted) {
        setState(() => _members.removeWhere((m) => m.membershipId == member.membershipId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${member.fullName} removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove member: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  Future<void> _configureTrainer(GymMember trainer) async {
    final shiftController = TextEditingController();
    final commissionController = TextEditingController();
    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${trainer.fullName} — Shift & Commission',
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: shiftController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Shift schedule',
                  hintText: 'e.g. Mon-Sat 6am-2pm',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.bgTertiary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commissionController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Commission %',
                  hintText: '0-100',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.bgTertiary,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (saved != true) return;
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    try {
      await ref.read(gymOwnerServiceProvider).updateTrainerConfig(
            gymId: gymId,
            membershipId: trainer.membershipId,
            shiftSchedule: shiftController.text.trim().isEmpty ? null : shiftController.text.trim(),
            commissionPercent: double.tryParse(commissionController.text.trim()),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trainer config updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  List<GymMember> get _filteredMembers {
    var members = _members;

    if (_selectedFilter != 'All') {
      members = members.where((m) => m.status.toUpperCase() == _selectedFilter.toUpperCase()).toList();
    }

    if (_selectedTrainerFilter != null) {
      members = members.where((m) => m.assignedTrainerName == _selectedTrainerFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase().replaceAll(' ', '');
      members = members.where((m) {
        final name = m.fullName.toLowerCase();
        final phone = (m.phone ?? '').replaceAll(' ', '');
        final email = m.email.toLowerCase();
        return name.contains(query) || phone.contains(query) || email.contains(query);
      }).toList();
    }

    return members;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMembers;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadMembers,
          color: AppColors.accentBlue,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: _buildSearchBar(),
                ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
              ),
              SliverToBoxAdapter(child: _buildFilterChips()),
              SliverToBoxAdapter(child: _buildCountBadge(filtered.length)),
              if (_loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(padding: EdgeInsets.only(top: 60), child: LoadingView(message: 'Loading members…')),
                )
              else if (_error != null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: ErrorRetryView(message: _error!, onRetry: _loadMembers),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: _members.isEmpty
                        ? EmptyStateView(
                            icon: Icons.people_outline_rounded,
                            title: 'No members yet',
                            subtitle: 'Add your first member or share an invite code so people can join.',
                            actionLabel: 'Add Member',
                            onAction: _openAddMember,
                          )
                        : const EmptyStateView(
                            icon: Icons.person_search_rounded,
                            title: 'No members found',
                            subtitle: 'Try adjusting your search or filters',
                          ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final member = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildMemberCard(member)
                              .animate()
                              .fadeIn(duration: 400.ms, delay: Duration(milliseconds: 280 + index * 50))
                              .slideY(begin: 0.04, end: 0, duration: 400.ms, delay: Duration(milliseconds: 280 + index * 50)),
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Positioned(
          bottom: 90,
          right: 20,
          child: _buildFAB()
              .animate()
              .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 500.ms, delay: 500.ms, curve: Curves.elasticOut),
        ),
      ],
    );
  }

  Future<void> _openAddMember() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddMemberScreen()),
    );
    if (result != null) _loadMembers();
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accentBlue, AppColors.accentBlue.withValues(alpha: 0.7)],
              ),
            ),
            child: const Center(child: Icon(Icons.people_rounded, color: Colors.white, size: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Members Management', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  _loading ? 'Loading…' : '${_members.length} total members',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BulkImportScreen()),
              );
              if (result == true) _loadMembers();
            },
            icon: const Icon(Icons.upload_file_rounded, color: AppColors.textSecondary),
            tooltip: 'Bulk import from CSV/Excel',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.05, end: 0, duration: 500.ms);
  }

  Widget _buildCountBadge(int filteredCount) {
    if (_loading || _error != null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 20, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.accentBlue.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Showing $filteredCount of ${_members.length} members',
              style: AppTextStyles.caption.copyWith(color: AppColors.accentBlue, fontWeight: FontWeight.w600, fontSize: 10),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 250.ms);
  }

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.glassBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search by name, phone, or email...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      child: const Icon(Icons.close_rounded, color: AppColors.textTertiary, size: 18),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index < _statusFilters.length) {
            return _buildStatusFilterChip(_statusFilters[index]);
          }
          return _buildTrainerFilterChip();
        },
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 180.ms);
  }

  Widget _buildStatusFilterChip(String filter) {
    final isSelected = filter == _selectedFilter && _selectedTrainerFilter == null;
    final count = filter == 'All'
        ? _members.length
        : _members.where((m) => m.status.toUpperCase() == filter.toUpperCase()).length;

    return GestureDetector(
      onTap: () => setState(() {
        _selectedFilter = filter;
        _selectedTrainerFilter = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.glassBg,
          border: Border.all(color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.4) : AppColors.glassBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(filter,
                style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.accentBlue : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.2) : AppColors.bgTertiary,
              ),
              child: Text('$count',
                  style: AppTextStyles.caption.copyWith(
                      color: isSelected ? AppColors.accentBlue : AppColors.textTertiary, fontWeight: FontWeight.w700, fontSize: 9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerFilterChip() {
    final isSelected = _selectedTrainerFilter != null;
    final label = isSelected ? _selectedTrainerFilter! : 'Trainer';

    return GestureDetector(
      onTap: _showTrainerFilterSheet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.accentPurple.withValues(alpha: 0.15) : AppColors.glassBg,
          border: Border.all(color: isSelected ? AppColors.accentPurple.withValues(alpha: 0.4) : AppColors.glassBorder, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center_rounded, color: isSelected ? AppColors.accentPurple : AppColors.textTertiary, size: 13),
            const SizedBox(width: 5),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.accentPurple : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12)),
            const SizedBox(width: 3),
            Icon(Icons.arrow_drop_down_rounded, color: isSelected ? AppColors.accentPurple : AppColors.textTertiary, size: 16),
          ],
        ),
      ),
    );
  }

  void _showTrainerFilterSheet() {
    if (_trainers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No trainers in this gym yet')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: AppColors.textDisabled)),
              const SizedBox(height: 20),
              Text('Filter by Trainer', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _buildTrainerOption(null, 'All Trainers', Icons.groups_rounded, _selectedTrainerFilter == null),
              const SizedBox(height: 8),
              ..._trainers.map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildTrainerOption(t.name, t.name, Icons.fitness_center_rounded, _selectedTrainerFilter == t.name),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrainerOption(String? value, String label, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTrainerFilter = value;
          if (value != null) _selectedFilter = 'All';
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isSelected ? AppColors.accentPurple.withValues(alpha: 0.12) : AppColors.glassBg,
          border: Border.all(color: isSelected ? AppColors.accentPurple.withValues(alpha: 0.4) : AppColors.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.accentPurple : AppColors.textTertiary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.accentPurple : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
            ),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.accentPurple, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(GymMember member) {
    Color statusColor;
    IconData statusIcon;
    switch (member.status.toUpperCase()) {
      case 'ACTIVE':
        statusColor = AppColors.accentCyan;
        statusIcon = Icons.check_circle_outline_rounded;
        break;
      case 'EXPIRED':
        statusColor = AppColors.accentCoral;
        statusIcon = Icons.error_outline_rounded;
        break;
      case 'FROZEN':
        statusColor = AppColors.accentOrange;
        statusIcon = Icons.ac_unit_rounded;
        break;
      default:
        statusColor = AppColors.textTertiary;
        statusIcon = Icons.hourglass_top_rounded;
    }
    final isTrainer = member.role.toUpperCase() == 'TRAINER';
    final gradientColors = isTrainer
        ? [AppColors.accentPurple, AppColors.accentCoral]
        : [AppColors.accentBlue, AppColors.accentCyan];

    return DashboardGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
                  boxShadow: [BoxShadow(color: gradientColors[0].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: Text(
                    member.firstName.isNotEmpty ? member.firstName[0].toUpperCase() : 'M',
                    style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.fullName,
                        style: AppTextStyles.labelLarge.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, color: AppColors.textTertiary, size: 12),
                        const SizedBox(width: 4),
                        Text(member.phone ?? 'No phone',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: gradientColors[0].withValues(alpha: 0.1),
                        border: Border.all(color: gradientColors[0].withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        isTrainer
                            ? 'Trainer'
                            : '${member.planName ?? 'No plan'}${member.endDate != null ? ' • Exp ${_fmtDate(member.endDate!)}' : ''}',
                        style: AppTextStyles.caption.copyWith(color: gradientColors[0], fontWeight: FontWeight.w600, fontSize: 9),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: statusColor.withValues(alpha: 0.12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 11),
                    const SizedBox(width: 3),
                    Text(member.status, style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w600, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          if (member.assignedTrainerName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.fitness_center_rounded, color: AppColors.textTertiary, size: 13),
                const SizedBox(width: 4),
                Text(member.assignedTrainerName!, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.glassBorder),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.visibility_rounded,
                label: 'View',
                color: AppColors.accentBlue,
                onTap: () {
                  final gymId = ref.read(currentGymIdProvider);
                  if (gymId == null) return;
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MemberDetailScreen(gymId: gymId, membershipId: member.membershipId, initial: member),
                    ),
                  ).then((removed) {
                    if (removed == true) _loadMembers();
                  });
                },
              ),
              const SizedBox(width: 8),
              if (isTrainer)
                _buildActionButton(
                  icon: Icons.schedule_rounded,
                  label: 'Shift & Pay',
                  color: AppColors.accentPurple,
                  onTap: () => _configureTrainer(member),
                )
              else
                _buildActionButton(
                  icon: Icons.note_alt_outlined,
                  label: 'Details',
                  color: AppColors.accentPurple,
                  onTap: () {
                    final gymId = ref.read(currentGymIdProvider);
                    if (gymId == null) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MemberDetailScreen(gymId: gymId, membershipId: member.membershipId, initial: member),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.person_remove_rounded,
                label: 'Remove',
                color: AppColors.accentCoral,
                onTap: () => _removeMember(member),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withValues(alpha: 0.08),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 3),
              Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600, fontSize: 8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: _openAddMember,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.accentBlue, Color(0xFF6366F1)]),
          boxShadow: [
            BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
            BoxShadow(color: AppColors.accentBlue.withValues(alpha: 0.15), blurRadius: 32, offset: const Offset(0, 12)),
          ],
        ),
        child: const Center(child: Icon(Icons.person_add_rounded, color: Colors.white, size: 24)),
      ),
    );
  }
}
