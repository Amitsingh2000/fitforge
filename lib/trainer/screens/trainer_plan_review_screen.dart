import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../onboarding/widgets/primary_button.dart';

class TrainerPlanReviewScreen extends StatefulWidget {
  final Map<String, dynamic> plan;

  const TrainerPlanReviewScreen({super.key, required this.plan});

  @override
  State<TrainerPlanReviewScreen> createState() => _TrainerPlanReviewScreenState();
}

class _TrainerPlanReviewScreenState extends State<TrainerPlanReviewScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  late List<Map<String, dynamic>> _workoutList;
  late List<Map<String, dynamic>> _dietList;

  @override
  void initState() {
    super.initState();
    // Copy the plans list so trainer can edit them inline
    _workoutList = List<Map<String, dynamic>>.from(
      (widget.plan['workout'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
    );
    _dietList = List<Map<String, dynamic>>.from(
      (widget.plan['diet'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)),
    );

    // Simulate AI loading/fetching plan for 1.8 seconds if it was pending
    if (widget.plan['status'] == 'Pending') {
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientName = widget.plan['clientName'] as String;
    final initials = widget.plan['initials'] as String;
    final gradientColors = widget.plan['gradientColors'] as List<Color>;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textSecondary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'AI Plan Review',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: Icon(
                _isEditing ? Icons.check_circle_outline_rounded : Icons.edit_note_rounded,
                color: _isEditing ? AppColors.accentCyan : AppColors.textSecondary,
              ),
              onPressed: () {
                setState(() => _isEditing = !_isEditing);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          // Background glow
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

          // Main body content
          _isLoading ? _buildLoadingShimmer() : _buildPlanDetailsContent(clientName, initials, gradientColors),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spinner
          const CircularProgressIndicator(
            color: AppColors.accentCyan,
            strokeWidth: 3,
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing Member Goals...',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is generating a customized workout & meal plan...',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildPlanDetailsContent(String clientName, String initials, List<Color> gradientColors) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Client brief card
                DashboardGlassCard(
                  padding: const EdgeInsets.all(16),
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
                            colors: gradientColors,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(clientName, style: AppTextStyles.labelLarge),
                            const SizedBox(height: 2),
                            Text(
                              'Goal: ${widget.plan['goal']}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // AI Workout Plan
                if (_workoutList.isNotEmpty) ...[
                  _buildSectionHeader('AI Generated Workout Plan'),
                  const SizedBox(height: 10),
                  ...List.generate(_workoutList.length, (index) {
                    final exercise = _workoutList[index];
                    return _buildPlanItemCard(
                      title: exercise['name'] as String,
                      subtitle: '${exercise['sets']} Sets x ${exercise['reps']} Reps',
                      onEdit: (name, sub) {
                        setState(() {
                          _workoutList[index]['name'] = name;
                          final parts = sub.split('x');
                          if (parts.length == 2) {
                            _workoutList[index]['sets'] = parts[0].replaceAll(RegExp(r'\D'), '');
                            _workoutList[index]['reps'] = parts[1].replaceAll(RegExp(r'\D'), '');
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 24),
                ],

                // AI Meal Plan
                if (_dietList.isNotEmpty) ...[
                  _buildSectionHeader('AI Generated Meal Plan'),
                  const SizedBox(height: 10),
                  ...List.generate(_dietList.length, (index) {
                    final meal = _dietList[index];
                    return _buildPlanItemCard(
                      title: meal['name'] as String,
                      subtitle: '${meal['time']} | ${meal['cals']}',
                      onEdit: (name, sub) {
                        setState(() {
                          _dietList[index]['name'] = name;
                          final parts = sub.split('|');
                          if (parts.length == 2) {
                            _dietList[index]['time'] = parts[0].trim();
                            _dietList[index]['cals'] = parts[1].trim();
                          }
                        });
                      },
                    );
                  }),
                ],
              ],
            ),
          ),
        ),

        // Action panel
        _buildActionPanel(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Icon(Icons.psychology_rounded, color: AppColors.accentPurple, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanItemCard({
    required String title,
    required String subtitle,
    required Function(String, String) onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (_isEditing)
            GestureDetector(
              onTap: () => _showEditDialog(title, subtitle, onEdit),
              child: const Icon(Icons.edit_rounded, color: AppColors.accentCyan, size: 18),
            ),
        ],
      ),
    );
  }

  void _showEditDialog(String currentTitle, String currentSubtitle, Function(String, String) onEdit) {
    final titleController = TextEditingController(text: currentTitle);
    final subController = TextEditingController(text: currentSubtitle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('Edit Item', style: AppTextStyles.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: const InputDecoration(labelText: 'Details/Macros'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              onEdit(titleController.text, subController.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save', style: TextStyle(color: AppColors.accentCyan)),
          ),
        ],
      ),
    ).then((_) {
      titleController.dispose();
      subController.dispose();
    });
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.bgPrimary.withValues(alpha: 0.95),
            AppColors.bgPrimary,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Request Changes back to AI (simulation)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.bgTertiary,
                    content: Text(
                      'AI is regenerating plans with custom constraints...',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCyan),
                    ),
                  ),
                );
                setState(() {
                  _isLoading = true;
                });
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      // Add dummy modification
                      if (_workoutList.isNotEmpty) {
                        _workoutList[0]['name'] = 'Alternate: Kettlebell Squats';
                      }
                    });
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sync_rounded, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Regenerate (AI)',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: _isEditing ? 'Save Edits' : 'Approve & Send',
              onTap: () {
                if (_isEditing) {
                  setState(() => _isEditing = false);
                } else {
                  // Return status: if changes were made, mark as 'Modified', else 'Approved'
                  final bool modified = widget.plan['status'] == 'Pending'; // for demo
                  Navigator.of(context).pop(modified ? 'Modified' : 'Approved');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
