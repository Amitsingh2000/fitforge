import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/gym_membership.dart';
import '../../providers/gym_provider.dart';
import '../../services/gym_owner_service.dart';
import '../../theme/app_theme.dart';

/// Screen displayed to newly registered gym owners who do not have a gym created yet.
class CreateGymScreen extends ConsumerStatefulWidget {
  const CreateGymScreen({super.key});

  @override
  ConsumerState<CreateGymScreen> createState() => _CreateGymScreenState();
}

class _CreateGymScreenState extends ConsumerState<CreateGymScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final service = ref.read(gymOwnerServiceProvider);
      final res = await service.createGym(
        name: _nameController.text.trim(),
        addressLine: _addressController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final gymId = res['id'] as String? ?? res['gymId'] as String? ?? '';
      final membershipId = res['membershipId'] as String? ?? '';

      if (gymId.isNotEmpty) {
        ref.read(selectedGymProvider.notifier).state = GymMembership(
          gymId: gymId,
          gymName: _nameController.text.trim(),
          role: GymRole.gymOwner,
          membershipId: membershipId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gym created! Add your UPI ID from Gym Settings so members can pay you.'),
            backgroundColor: AppColors.accentBlue,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/gym-owner-dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = _friendlyError(e);
        });
      }
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('timeout') || msg.contains('Connection')) {
      return "Couldn't reach the server — it may be waking up (free hosting can take up to a minute). Please try again.";
    }
    return 'Failed to create gym: $msg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Register Your Gym', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Gym Owner! 🏋️‍♂️',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Set up your gym profile to start managing members, trainers, and attendance.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),

                _field(
                  controller: _nameController,
                  label: 'Gym Name *',
                  hint: 'e.g. Iron Vault Fitness',
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Enter at least 2 characters'
                      : null,
                ),
                const SizedBox(height: 16),

                _field(
                  controller: _addressController,
                  label: 'Address / Location *',
                  hint: 'e.g. 123 Health St, Andheri',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter an address' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: _cityController,
                        label: 'City',
                        hint: 'Mumbai',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        controller: _stateController,
                        label: 'State',
                        hint: 'Maharashtra',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller: _pincodeController,
                        label: 'Pincode',
                        hint: '400058',
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        validator: (v) => (v != null && v.isNotEmpty && v.length < 4)
                            ? 'Invalid pincode'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _field(
                        controller: _phoneController,
                        label: 'Gym Phone',
                        hint: '9876543210',
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'UPI ID / QR for payments can be added later from Gym Settings.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
                ),
                const SizedBox(height: 24),

                if (_error != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accentCoral.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentCoral.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.accentCoral, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _handleCreate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Create Gym Profile',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        counterText: '',
        filled: true,
        fillColor: AppColors.bgSecondary,
        errorStyle: const TextStyle(color: AppColors.accentCoral, fontSize: 11),
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
          borderSide: const BorderSide(color: AppColors.accentBlue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentCoral),
        ),
      ),
    );
  }
}
