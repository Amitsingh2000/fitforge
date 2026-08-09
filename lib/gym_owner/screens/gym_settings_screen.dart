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
  final _facilitiesController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _uploadingLogo = false;
  bool _uploadingQr = false;
  String? _error;
  String? _logoUrl;
  String? _upiQrUrl;
  bool _storageConfigured = false;

  // Notification preferences
  bool _muteJoinRequests = false;
  bool _muteRenewals = false;
  bool _muteCoupons = false;

  @override
  void initState() {
    super.initState();
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

      final facilitiesList = (gym['facilities'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final muted = (gym['mutedOwnerAlertTypes'] as List?)?.map((e) => e.toString()).toList() ?? [];

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
          _facilitiesController.text = facilitiesList.join(', ');
          _logoUrl = gym['logoUrl'] as String?;
          _upiQrUrl = gym['upiQrCodeUrl'] as String?;
          _muteJoinRequests = muted.contains('OWNER_JOIN_REQUEST');
          _muteRenewals = muted.contains('OWNER_RENEWAL_DUE');
          _muteCoupons = muted.contains('OWNER_COUPON_REDEEMED');
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

  Future<void> _save() async {
    final gymId = ref.read(currentGymIdProvider);
    if (gymId == null) return;
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gym name is required')));
      return;
    }
    setState(() => _saving = true);

    final facilities = _facilitiesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final mutedTypes = <String>[];
    if (_muteJoinRequests) mutedTypes.add('OWNER_JOIN_REQUEST');
    if (_muteRenewals) mutedTypes.add('OWNER_RENEWAL_DUE');
    if (_muteCoupons) mutedTypes.add('OWNER_COUPON_REDEEMED');

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
            facilities: facilities,
            mutedOwnerAlertTypes: mutedTypes,
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
        _sectionLabel('FACILITIES & AMENITIES'),
        const SizedBox(height: 4),
        Text('Separate facilities with commas (e.g. AC, Sauna, Cardio, Parking, Personal Training)',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
        const SizedBox(height: 10),
        _field(_facilitiesController, 'Facilities', hint: 'AC, Sauna, Parking'),
        const SizedBox(height: 24),
        _sectionLabel('NOTIFICATION PREFERENCES'),
        const SizedBox(height: 4),
        Text('Mute specific owner notifications from your feed',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11)),
        const SizedBox(height: 10),
        SwitchListTile(
          title: const Text('Mute Join Request Alerts', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          value: _muteJoinRequests,
          onChanged: (v) => setState(() => _muteJoinRequests = v),
          activeColor: AppColors.accentBlue,
        ),
        SwitchListTile(
          title: const Text('Mute Membership Renewal Alerts', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          value: _muteRenewals,
          onChanged: (v) => setState(() => _muteRenewals = v),
          activeColor: AppColors.accentBlue,
        ),
        SwitchListTile(
          title: const Text('Mute Coupon Redemption Alerts', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
          value: _muteCoupons,
          onChanged: (v) => setState(() => _muteCoupons = v),
          activeColor: AppColors.accentBlue,
        ),
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
