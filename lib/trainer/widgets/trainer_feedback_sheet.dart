import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/trainer_client.dart';
import '../../providers/gym_provider.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';
import '../../onboarding/widgets/primary_button.dart';
import '../../dashboard/widgets/state_views.dart';

class TrainerFeedbackSheet extends ConsumerStatefulWidget {
  final TrainerClient client;

  const TrainerFeedbackSheet({super.key, required this.client});

  @override
  ConsumerState<TrainerFeedbackSheet> createState() =>
      _TrainerFeedbackSheetState();
}

class _TrainerFeedbackSheetState extends ConsumerState<TrainerFeedbackSheet> {
  int _selectedRating = 5;
  String _selectedCategory = 'Progress';
  bool _sending = false;
  final _feedbackController = TextEditingController();

  final List<String> _categories = ['Progress', 'Diet', 'Consistency', 'Effort'];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null || _sending) return;
    setState(() => _sending = true);

    try {
      final chat = ref.read(chatServiceProvider);
      final thread = await chat.createOrGetThread(
        gymId,
        otherUserId: widget.client.userId,
      );
      final body = [
        '⭐ Feedback (${_selectedRating}/5) · $_selectedCategory',
        if (_feedbackController.text.trim().isNotEmpty)
          _feedbackController.text.trim(),
      ].join('\n');
      await chat.sendMessage(gymId, thread.id, body: body);

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.bgTertiary,
          content: Text(
            'Could not send feedback: ${friendlyApiError(e)}',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.accentCoral),
          ),
        ),
      );
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
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
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Send Feedback',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.client.fullName,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Star Rating
            Text(
              'Performance Rating',
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                final isSelected = starValue <= _selectedRating;
                return GestureDetector(
                  onTap: _sending
                      ? null
                      : () => setState(() => _selectedRating = starValue),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.star_rounded,
                      color: isSelected ? AppColors.accentOrange : AppColors.textDisabled,
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Category selection
            Text(
              'Feedback Category',
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: _sending
                      ? null
                      : () => setState(() => _selectedCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accentCyan.withValues(alpha: 0.15)
                          : AppColors.bgPrimary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentCyan.withValues(alpha: 0.5)
                            : AppColors.glassBorder,
                      ),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected ? AppColors.accentCyan : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Feedback Message
            Text(
              'Feedback Message',
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              cursorColor: AppColors.accentCyan,
              decoration: InputDecoration(
                hintText: 'Enter encouragement, diet adjustments or exercise notes...',
                hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
                filled: true,
                fillColor: AppColors.bgPrimary,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.glassBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.accentCyan, width: 1.2),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            PrimaryButton(
              label: _sending ? 'Sending…' : 'Send Feedback to Member',
              isEnabled: !_sending,
              onTap: _send,
            ),
          ],
        ),
      ),
    );
  }
}