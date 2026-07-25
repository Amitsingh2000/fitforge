import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/trainer_profile.dart';
import '../../services/media_upload_service.dart';
import '../../services/trainer_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/state_views.dart';

/// `PATCH /trainers/me/profile` — bio, specializations, experience, intro
/// video, and photo gallery (uploaded via media presign, purpose TRAINER_PHOTO).
class TrainerEditProfileScreen extends ConsumerStatefulWidget {
  const TrainerEditProfileScreen({super.key, required this.initial});
  final TrainerProfile initial;

  @override
  ConsumerState<TrainerEditProfileScreen> createState() => _TrainerEditProfileScreenState();
}

class _TrainerEditProfileScreenState extends ConsumerState<TrainerEditProfileScreen> {
  final _bioController = TextEditingController();
  final _experienceController = TextEditingController();
  final _introVideoController = TextEditingController();
  final _specializationController = TextEditingController();

  late List<String> _specializations;
  late List<String> _photoUrls;
  bool _uploadingPhoto = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.initial.bio ?? '';
    _experienceController.text = widget.initial.experienceYears?.toString() ?? '';
    _introVideoController.text = widget.initial.introVideoUrl ?? '';
    _specializations = List.of(widget.initial.specializations);
    _photoUrls = List.of(widget.initial.photoUrls);
  }

  void _addSpecialization() {
    final v = _specializationController.text.trim();
    if (v.isEmpty || _specializations.contains(v) || _specializations.length >= 20) return;
    setState(() {
      _specializations.add(v);
      _specializationController.clear();
    });
  }

  Future<void> _addPhoto() async {
    if (_photoUrls.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maximum 10 photos')));
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final ext = picked.path.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final url = await ref.read(mediaUploadServiceProvider).uploadFile(
            file: File(picked.path),
            purpose: 'TRAINER_PHOTO',
            contentType: contentType,
          );
      if (mounted) setState(() { _photoUrls.add(url); _uploadingPhoto = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo upload failed: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; });
    try {
      await ref.read(trainerServiceProvider).updateMyProfile(
            bio: _bioController.text.trim(),
            specializations: _specializations,
            experienceYears: int.tryParse(_experienceController.text.trim()),
            introVideoUrl: _introVideoController.text.trim(),
            photoUrls: _photoUrls,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() { _saving = false; _error = friendlyApiError(e); });
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _experienceController.dispose();
    _introVideoController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Edit Trainer Profile', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            _sectionLabel('PHOTOS'),
            const SizedBox(height: 10),
            _buildPhotoGrid(),
            const SizedBox(height: 24),
            _sectionLabel('ABOUT'),
            const SizedBox(height: 10),
            _field(_bioController, 'Bio', hint: 'Tell clients about your coaching style', maxLines: 4, maxLength: 2000),
            const SizedBox(height: 12),
            _field(_experienceController, 'Years of Experience', keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _field(_introVideoController, 'Intro Video URL (optional)', keyboardType: TextInputType.url),
            const SizedBox(height: 24),
            _sectionLabel('SPECIALIZATIONS'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _specializationController,
                    onSubmitted: (_) => _addSpecialization(),
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. weight-loss',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      filled: true,
                      fillColor: AppColors.bgSecondary,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.glassBorder)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addSpecialization,
                  icon: const Icon(Icons.add_circle_rounded, color: AppColors.accentBlue, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _specializations.map((s) {
                return Chip(
                  label: Text(s, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                  backgroundColor: AppColors.bgTertiary,
                  deleteIcon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textTertiary),
                  onDeleted: () => setState(() => _specializations.remove(s)),
                  side: BorderSide(color: AppColors.glassBorder),
                );
              }).toList(),
            ),
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
        ),
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._photoUrls.map((url) => Stack(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: GestureDetector(
                    onTap: () => setState(() => _photoUrls.remove(url)),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            )),
        GestureDetector(
          onTap: _uploadingPhoto ? null : _addPhoto,
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.bgSecondary,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: _uploadingPhoto
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue, strokeWidth: 2))
                : const Icon(Icons.add_a_photo_outlined, color: AppColors.textTertiary),
          ),
        ),
      ],
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

  Widget _field(TextEditingController controller, String label, {String? hint, TextInputType? keyboardType, int maxLines = 1, int? maxLength}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
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
