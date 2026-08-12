import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../services/media_upload_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/state_views.dart';

/// `PATCH /gyms/:gymId` — gym profile edit, including UPI payout setup
/// (`upiId` / `upiQrCodeUrl` via media presign purpose `GYM_UPI_QR`) and
/// logo (`GYM_LOGO`).
class GymSettingsScreen extends ConsumerStatefulWidget {
  const GymSettingsScreen({super.key});

  @override
  ConsumerState<GymSettingsScreen> createState() => _GymSettingsScreenState();
}

class _GymSettingsScreenState extends ConsumerState<GymSettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _upiController = TextEditingController();
  final _facilityController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _uploadingLogo = false;
  bool _uploadingQr = false;
  bool _uploadingPhoto = false;
  String? _error;
  String? _logoUrl;
  String? _upiQrUrl;
  bool _storageConfigured = false;

  List<String> _facilities = [];
  List<String> _photoUrls = [];
  late List<Map<String, dynamic>> _workingHours;
  final Set<String> _mutedAlertTypes = {};

  static const _weekDays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  static const _alertTypeLabels = {
    'OWNER_JOIN_REQUEST': 'New join requests',
    'OWNER_RENEWAL_DUE': 'Membership renewals due',
    'OWNER_MEMBERSHIP_EXPIRED': 'Memberships expired',
    'OWNER_COUPON_REDEEMED': 'Coupon redeemed',
    'OWNER_TRAINER_JOINED': 'New trainer joined',
    'OWNER_TRAINER_UPDATE': 'Trainer profile/certification updates',
  };

  List<Map<String, dynamic>> _defaultWorkingHours() {
    return _weekDays
        .map((d) => {
              'day': d,
              'isClosed': false,
              'opensAt': '06:00',
              'closesAt': '22:00',
            })
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _workingHours = _defaultWorkingHours();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ref.read(gymOwnerServiceProvider).getGym(gymId),
        ref.read(mediaUploadServiceProvider).isStorageConfigured(),
      ]);
      final gym = results[0] as Map<String, dynamic>;
      final configured = results[1] as bool;
      if (mounted) {
        setState(() {
          _nameController.text = gym['name'] as String? ?? '';
          _phoneController.text = gym['phone'] as String? ?? '';
          _emailController.text = gym['email'] as String? ?? '';
          _addressController.text = gym['addressLine'] as String? ?? '';
          _cityController.text = gym['city'] as String? ?? '';
          _stateController.text = gym['state'] as String? ?? '';
          _pincodeController.text = gym['pincode'] as String? ?? '';
          _upiController.text = gym['upiId'] as String? ?? '';
          _logoUrl = gym['logoUrl'] as String?;
          _upiQrUrl = gym['upiQrCodeUrl'] as String?;
          _facilities = (gym['facilities'] as List?)?.map((e) => e.toString()).toList() ?? [];
          _photoUrls = (gym['photoUrls'] as List?)?.map((e) => e.toString()).toList() ?? [];
          final hours = gym['workingHours'] as List?;
          if (hours != null && hours.isNotEmpty) {
            _workingHours = hours.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }
          _mutedAlertTypes
            ..clear()
            ..addAll((gym['mutedOwnerAlertTypes'] as List?)?.map((e) => e.toString()) ?? []);
          _storageConfigured = configured;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = friendlyApiError(e); });
    }
  }

  Future<void> _pickAndUpload({required String purpose, required bool isLogo}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() {
      if (isLogo) {
        _uploadingLogo = true;
      } else {
        _uploadingQr = true;
      }
    });

    try {
      final ext = picked.path.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final url = await ref.read(mediaUploadServiceProvider).uploadFile(
            file: File(picked.path),
            purpose: purpose,
            contentType: contentType,
          );
      if (mounted) {
        setState(() {
          if (isLogo) { _logoUrl = url; _uploadingLogo = false; } else { _upiQrUrl = url; _uploadingQr = false; }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _uploadingLogo = false; _uploadingQr = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final ext = picked.path.split('.').last.toLowerCase();
      final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
      final url = await ref.read(mediaUploadServiceProvider).uploadFile(
            file: File(picked.path),
            purpose: 'GYM_PHOTO',
            contentType: contentType,
          );
      if (mounted) {
        setState(() {
          _photoUrls = [..._photoUrls, url];
          _uploadingPhoto = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  void _addFacility() {
    final value = _facilityController.text.trim();
    if (value.isEmpty || _facilities.contains(value)) return;
    setState(() {
      _facilities = [..._facilities, value];
      _facilityController.clear();
    });
  }

  Future<void> _save() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gym name is required')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(gymOwnerServiceProvider).updateGym(
            gymId,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            addressLine: _addressController.text.trim(),
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
            pincode: _pincodeController.text.trim(),
            upiId: _upiController.text.trim(),
            logoUrl: _logoUrl,
            upiQrCodeUrl: _upiQrUrl,
            facilities: _facilities,
            workingHours: _workingHours,
            photoUrls: _photoUrls,
            mutedOwnerAlertTypes: _mutedAlertTypes.toList(),
          );
      ref.read(selectedGymProvider.notifier).update((g) => g?.copyWith(gymName: _nameController.text.trim()));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gym settings saved')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: ${friendlyApiError(e)}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _upiController.dispose();
    _facilityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Gym Settings', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(message: 'Loading gym settings…');
    if (_error != null) return ErrorRetryView(message: _error!, onRetry: _load);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        _sectionLabel('GYM LOGO'),
        const SizedBox(height: 10),
        _buildImagePicker(
          url: _logoUrl,
          uploading: _uploadingLogo,
          placeholder: Icons.storefront_rounded,
          onTap: _storageConfigured ? () => _pickAndUpload(purpose: 'GYM_LOGO', isLogo: true) : null,
        ),
        const SizedBox(height: 24),
        _sectionLabel('GYM DETAILS'),
        const SizedBox(height: 10),
        _field(_nameController, 'Gym Name *'),
        const SizedBox(height: 12),
        _field(_phoneController, 'Phone', keyboardType: TextInputType.phone),
        const SizedBox(height: 12),
        _field(_emailController, 'Email', keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _field(_addressController, 'Address'),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _field(_cityController, 'City')),
          const SizedBox(width: 12),
          Expanded(child: _field(_stateController, 'State')),
        ]),
        const SizedBox(height: 12),
        _field(_pincodeController, 'Pincode', keyboardType: TextInputType.number),
        const SizedBox(height: 24),
        _sectionLabel('PAYMENTS (UPI)'),
        const SizedBox(height: 4),
        Text('Members will see this so they can pay you directly via any UPI app.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
        const SizedBox(height: 10),
        _field(_upiController, 'UPI ID', hint: 'e.g. gymname@okhdfcbank'),
        const SizedBox(height: 16),
        Text('UPI QR Code', style: AppTextStyles.labelSmall),
        const SizedBox(height: 8),
        _buildImagePicker(
          url: _upiQrUrl,
          uploading: _uploadingQr,
          placeholder: Icons.qr_code_2_rounded,
          onTap: _storageConfigured ? () => _pickAndUpload(purpose: 'GYM_UPI_QR', isLogo: false) : null,
        ),
        if (!_storageConfigured) ...[
          const SizedBox(height: 8),
          Text('Image upload is temporarily unavailable — you can still save the UPI ID.',
              style: AppTextStyles.caption.copyWith(color: AppColors.accentOrange, fontSize: 11)),
        ],
        const SizedBox(height: 24),
        _sectionLabel('PHOTO GALLERY'),
        const SizedBox(height: 10),
        _buildPhotoGallery(),
        const SizedBox(height: 24),
        _sectionLabel('FACILITIES'),
        const SizedBox(height: 10),
        _buildFacilities(),
        const SizedBox(height: 24),
        _sectionLabel('WORKING HOURS'),
        const SizedBox(height: 10),
        _buildWorkingHours(),
        const SizedBox(height: 24),
        _sectionLabel('NOTIFICATION PREFERENCES'),
        const SizedBox(height: 4),
        Text('Choose which owner alerts you want to receive.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
        const SizedBox(height: 10),
        _buildNotificationPreferences(),
        const SizedBox(height: 32),
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

  Widget _buildImagePicker({
    required String? url,
    required bool uploading,
    required IconData placeholder,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        width: 110,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
          image: url != null ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null,
        ),
        child: uploading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue, strokeWidth: 2))
            : url == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(placeholder, color: AppColors.textTertiary, size: 28),
                      const SizedBox(height: 6),
                      Text(onTap == null ? 'Unavailable' : 'Upload',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 10)),
                    ],
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                    ),
                  ),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final url in _photoUrls)
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.glassBorder),
                  image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _photoUrls = _photoUrls.where((u) => u != url).toList()),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
        GestureDetector(
          onTap: _storageConfigured && !_uploadingPhoto ? _pickAndUploadPhoto : null,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: _uploadingPhoto
                ? const Center(child: CircularProgressIndicator(color: AppColors.accentBlue, strokeWidth: 2))
                : Icon(Icons.add_photo_alternate_rounded,
                    color: AppColors.textTertiary, size: 26),
          ),
        ),
      ],
    );
  }

  Widget _buildFacilities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final facility in _facilities)
              Chip(
                label: Text(facility, style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
                backgroundColor: AppColors.bgSecondary,
                side: BorderSide(color: AppColors.glassBorder),
                deleteIcon: const Icon(Icons.close_rounded, size: 16),
                onDeleted: () =>
                    setState(() => _facilities = _facilities.where((f) => f != facility).toList()),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _facilityController,
                style: const TextStyle(color: AppColors.textPrimary),
                onSubmitted: (_) => _addFacility(),
                decoration: InputDecoration(
                  hintText: 'e.g. Free parking, Sauna',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.bgSecondary,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.glassBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.glassBorder)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.accentBlue)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _addFacility,
              icon: const Icon(Icons.add_circle_rounded, color: AppColors.accentBlue, size: 30),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkingHours() {
    return Column(
      children: [
        for (var i = 0; i < _workingHours.length; i++) _buildDayRow(i),
      ],
    );
  }

  Widget _buildDayRow(int index) {
    final day = _workingHours[index];
    final isClosed = day['isClosed'] as bool? ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            SizedBox(width: 40, child: Text(day['day'] as String, style: AppTextStyles.labelLarge.copyWith(fontSize: 12, fontWeight: FontWeight.w700))),
            Expanded(
              child: isClosed
                  ? Text('Closed', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary))
                  : Row(
                      children: [
                        Expanded(child: _timeField(day, 'opensAt', index)),
                        const SizedBox(width: 8),
                        const Text('–', style: TextStyle(color: AppColors.textTertiary)),
                        const SizedBox(width: 8),
                        Expanded(child: _timeField(day, 'closesAt', index)),
                      ],
                    ),
            ),
            Switch(
              value: !isClosed,
              activeThumbColor: AppColors.accentBlue,
              onChanged: (open) => setState(() => _workingHours[index]['isClosed'] = !open),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeField(Map<String, dynamic> day, String key, int index) {
    return GestureDetector(
      onTap: () async {
        final current = (day[key] as String? ?? '06:00').split(':');
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: int.tryParse(current[0]) ?? 6,
            minute: int.tryParse(current.length > 1 ? current[1] : '0') ?? 0,
          ),
        );
        if (picked != null) {
          setState(() {
            _workingHours[index][key] =
                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(day[key] as String? ?? '--:--',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12)),
      ),
    );
  }

  Widget _buildNotificationPreferences() {
    return Column(
      children: _alertTypeLabels.entries.map((entry) {
        final isMuted = _mutedAlertTypes.contains(entry.key);
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: !isMuted,
          activeThumbColor: AppColors.accentBlue,
          title: Text(entry.value, style: AppTextStyles.bodyMedium.copyWith(fontSize: 13)),
          onChanged: (enabled) => setState(() {
            if (enabled) {
              _mutedAlertTypes.remove(entry.key);
            } else {
              _mutedAlertTypes.add(entry.key);
            }
          }),
        );
      }).toList(),
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

  Widget _field(TextEditingController controller, String label, {String? hint, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
