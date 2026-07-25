import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../onboarding/widgets/chip_selector.dart';
import '../../providers/auth_provider.dart';
import '../../services/media_upload_service.dart';
import '../../services/member_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/state_views.dart';

const _goalOptions = ['Fat Loss', 'Muscle Gain', 'Strength', 'Sport Specific', 'General Fitness'];
const _experienceOptions = ['Beginner', 'Intermediate', 'Advanced'];
const _dietOptions = ['Veg', 'Eggetarian', 'Non-Veg', 'Vegan', 'Jain'];
const _equipmentOptions = ['Full Gym', 'Home Equipment', 'No Equipment'];
const _budgetOptions = ['Low', 'Medium', 'High'];

String _goalToBackend(String v) => switch (v) {
      'Fat Loss' => 'FAT_LOSS',
      'Muscle Gain' => 'MUSCLE_GAIN',
      'Strength' => 'STRENGTH',
      'Sport Specific' => 'SPORT_SPECIFIC',
      _ => 'GENERAL_FITNESS',
    };
String _goalFromBackend(String? v) => switch (v) {
      'FAT_LOSS' => 'Fat Loss',
      'MUSCLE_GAIN' => 'Muscle Gain',
      'STRENGTH' => 'Strength',
      'SPORT_SPECIFIC' => 'Sport Specific',
      _ => 'General Fitness',
    };
String _expToBackend(String v) => switch (v) {
      'Intermediate' => 'INTERMEDIATE',
      'Advanced' => 'ADVANCED',
      _ => 'BEGINNER',
    };
String _expFromBackend(String? v) => switch (v) {
      'INTERMEDIATE' => 'Intermediate',
      'ADVANCED' => 'Advanced',
      _ => 'Beginner',
    };
String _dietToBackend(String v) => switch (v) {
      'Veg' => 'VEG',
      'Eggetarian' => 'EGGETARIAN',
      'Vegan' => 'VEGAN',
      'Jain' => 'JAIN',
      _ => 'NON_VEG',
    };
String _dietFromBackend(String? v) => switch (v) {
      'VEG' => 'Veg',
      'EGGETARIAN' => 'Eggetarian',
      'VEGAN' => 'Vegan',
      'JAIN' => 'Jain',
      _ => 'Non-Veg',
    };
String _equipToBackend(String v) => switch (v) {
      'Home Equipment' => 'HOME_EQUIPMENT',
      'No Equipment' => 'NO_EQUIPMENT',
      _ => 'FULL_GYM',
    };
String _equipFromBackend(String? v) => switch (v) {
      'HOME_EQUIPMENT' => 'Home Equipment',
      'NO_EQUIPMENT' => 'No Equipment',
      _ => 'Full Gym',
    };
String _budgetToBackend(String v) => switch (v) {
      'Low' => 'LOW',
      'High' => 'HIGH',
      _ => 'MEDIUM',
    };
String _budgetFromBackend(String? v) => switch (v) {
      'LOW' => 'Low',
      'HIGH' => 'High',
      _ => 'Medium',
    };

/// One combined edit screen for account basics (`PATCH /users/me`) and the
/// goal-intake fitness profile (`PATCH /members/me/profile`) — split across
/// two backend endpoints, but one natural "Edit Profile" flow for the user.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _injuriesController = TextEditingController();
  final _weeklyFocusController = TextEditingController();

  String? _goal;
  String? _experience;
  String? _diet;
  String? _equipment;
  String? _budget;
  String? _sex;
  DateTime? _dob;

  String? _avatarUrl;
  bool _uploadingAvatar = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final user = ref.read(authProvider).user;
    _firstNameController.text = user?.firstName ?? '';
    _lastNameController.text = user?.lastName ?? '';
    _phoneController.text = user?.phone ?? '';
    _avatarUrl = user?.avatarUrl;

    try {
      final profile = await ref.read(memberServiceProvider).getMyFitnessProfile();
      if (mounted) {
        setState(() {
          _goal = _goalFromBackend(profile.goal);
          _experience = _expFromBackend(profile.experienceLevel);
          _diet = _dietFromBackend(profile.dietaryPreference);
          _equipment = _equipFromBackend(profile.equipmentAccess);
          _budget = _budgetFromBackend(profile.budgetBand);
          _sex = profile.sex ?? 'MALE';
          _dob = profile.dateOfBirth;
          _heightController.text = profile.heightCm != null ? profile.heightCm!.toStringAsFixed(0) : '';
          _weightController.text = profile.weightKg != null ? profile.weightKg!.toStringAsFixed(0) : '';
          _injuriesController.text = profile.injuriesNotes ?? '';
          _weeklyFocusController.text = profile.weeklyFocus ?? '';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploadingAvatar = true);
    try {
      final ext = picked.path.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final url = await ref.read(mediaUploadServiceProvider).uploadFile(
            file: File(picked.path),
            purpose: 'AVATAR',
            contentType: contentType,
          );
      if (mounted) setState(() { _avatarUrl = url; _uploadingAvatar = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avatar upload failed: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(DateTime.now().year - 25),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; });
    try {
      final memberService = ref.read(memberServiceProvider);
      await memberService.updateUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        avatarUrl: _avatarUrl,
      );
      await memberService.updateMyFitnessProfile(
        dateOfBirth: _dob != null
            ? '${_dob!.year.toString().padLeft(4, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}'
            : null,
        sex: _sex,
        heightCm: double.tryParse(_heightController.text.trim()),
        weightKg: double.tryParse(_weightController.text.trim()),
        goal: _goal != null ? _goalToBackend(_goal!) : null,
        experienceLevel: _experience != null ? _expToBackend(_experience!) : null,
        dietaryPreference: _diet != null ? _dietToBackend(_diet!) : null,
        budgetBand: _budget != null ? _budgetToBackend(_budget!) : null,
        equipmentAccess: _equipment != null ? _equipToBackend(_equipment!) : null,
        injuriesNotes: _injuriesController.text.trim(),
        weeklyFocus: _weeklyFocusController.text.trim(),
      );
      await ref.read(authProvider.notifier).refreshUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() { _saving = false; _error = friendlyApiError(e); });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _injuriesController.dispose();
    _weeklyFocusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading your profile…');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Center(child: _buildAvatarPicker()),
        const SizedBox(height: 28),
        _sectionLabel('ACCOUNT'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _textField(_firstNameController, 'First Name *')),
          const SizedBox(width: 12),
          Expanded(child: _textField(_lastNameController, 'Last Name')),
        ]),
        const SizedBox(height: 12),
        _textField(_phoneController, 'Phone', keyboardType: TextInputType.phone, hint: '10-digit mobile number'),
        const SizedBox(height: 24),

        _sectionLabel('FITNESS PROFILE'),
        const SizedBox(height: 12),
        Text('Goal', style: AppTextStyles.labelSmall),
        const SizedBox(height: 8),
        ChipSelector(options: _goalOptions, selectedOption: _goal, onSelected: (v) => setState(() => _goal = v)),
        const SizedBox(height: 18),
        Text('Experience', style: AppTextStyles.labelSmall),
        const SizedBox(height: 8),
        ChipSelector(options: _experienceOptions, selectedOption: _experience, onSelected: (v) => setState(() => _experience = v)),
        const SizedBox(height: 18),
        Text('Diet Preference', style: AppTextStyles.labelSmall),
        const SizedBox(height: 8),
        ChipSelector(options: _dietOptions, selectedOption: _diet, onSelected: (v) => setState(() => _diet = v)),
        const SizedBox(height: 18),
        Text('Equipment Access', style: AppTextStyles.labelSmall),
        const SizedBox(height: 8),
        ChipSelector(options: _equipmentOptions, selectedOption: _equipment, onSelected: (v) => setState(() => _equipment = v)),
        const SizedBox(height: 18),
        Text('Budget for Food & Supplements', style: AppTextStyles.labelSmall),
        const SizedBox(height: 8),
        ChipSelector(options: _budgetOptions, selectedOption: _budget, onSelected: (v) => setState(() => _budget = v)),
        const SizedBox(height: 18),

        Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _sex = 'MALE'),
              child: _sexChip('Male', _sex == 'MALE'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _sex = 'FEMALE'),
              child: _sexChip('Female', _sex == 'FEMALE'),
            ),
          ),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickDob,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(color: AppColors.bgSecondary, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.glassBorder)),
            child: Row(
              children: [
                const Icon(Icons.cake_outlined, color: AppColors.textTertiary, size: 18),
                const SizedBox(width: 10),
                Text(_dob != null ? '${_dob!.day}/${_dob!.month}/${_dob!.year}' : 'Date of birth',
                    style: TextStyle(color: _dob != null ? AppColors.textPrimary : AppColors.textTertiary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _textField(_heightController, 'Height (cm)', keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: _textField(_weightController, 'Weight (kg)', keyboardType: TextInputType.number)),
        ]),
        const SizedBox(height: 12),
        _textField(_injuriesController, 'Injuries / conditions (optional)', maxLines: 2),
        const SizedBox(height: 12),
        _textField(_weeklyFocusController, "This week's focus (optional)", hint: 'e.g. Train 4x this week; hit 120g protein daily'),

        const SizedBox(height: 28),
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.accentCoral.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.3))),
            child: Text(_error!, style: const TextStyle(color: AppColors.accentCoral, fontSize: 13)),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saving ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _saving
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _sexChip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.accentBlue.withValues(alpha: 0.15) : AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? AppColors.accentBlue : AppColors.glassBorder),
      ),
      child: Text(label, style: TextStyle(color: selected ? AppColors.accentBlue : AppColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
    );
  }

  Widget _buildAvatarPicker() {
    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accentBlue, width: 2),
              image: _avatarUrl != null ? DecorationImage(image: NetworkImage(_avatarUrl!), fit: BoxFit.cover) : null,
              gradient: _avatarUrl == null
                  ? const LinearGradient(colors: [Color(0xFF1A2B5C), Color(0xFF0D1B38)])
                  : null,
            ),
            child: _uploadingAvatar
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue, strokeWidth: 2))
                : (_avatarUrl == null ? const Icon(Icons.person_rounded, color: AppColors.textTertiary, size: 40) : null),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(color: AppColors.accentBlue, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(width: 3, height: 16, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), gradient: AppColors.primaryGradient)),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 11)),
      ],
    );
  }

  Widget _textField(TextEditingController controller, String label, {String? hint, TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        filled: true,
        fillColor: AppColors.bgSecondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.accentBlue)),
      ),
    );
  }
}
