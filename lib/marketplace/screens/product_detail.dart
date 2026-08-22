import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/marketplace_product.dart';
import '../../providers/member_flow_providers.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';

/// Product detail with one-tap marketplace checkout.
class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final MarketplaceProduct product;

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _quantity = 1;
  bool _checkoutLoading = false;

  MarketplaceProduct get product => widget.product;

  bool get _outOfStock => product.stock != null && product.stock! <= 0;

  Future<void> _handleBuy() async {
    if (_checkoutLoading || _outOfStock) return;

    setState(() => _checkoutLoading = true);
    try {
      final checkout = await ref.read(marketplaceServiceProvider).createOrder(
            idempotencyKey:
                'mp-${product.id}-${DateTime.now().millisecondsSinceEpoch}',
            lines: [
              {'productId': product.id, 'quantity': _quantity},
            ],
          );
      if (!mounted) return;

      invalidateMemberCommerce(ref);

      final refLabel = checkout.providerRef ?? checkout.paymentIntentId;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Order ${checkout.orderId}${refLabel != null ? ' · ref $refLabel' : ''}',
          ),
          backgroundColor: AppColors.accentBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout failed: $e'),
            backgroundColor: AppColors.accentCoral,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _checkoutLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        product.imageUrls.isNotEmpty ? product.imageUrls.first : null;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Product',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 1.2,
                        child: Container(
                          width: double.infinity,
                          color: AppColors.bgSecondary,
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _imagePlaceholder(),
                                )
                              : _imagePlaceholder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      product.title,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatPrice(product),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DashboardGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _detailRow('Fulfillment', _fulfillmentLabel(product.fulfillment)),
                          if (product.stock != null)
                            _detailRow(
                              'Availability',
                              product.stock! > 0
                                  ? '${product.stock} available'
                                  : 'Out of stock',
                            ),
                          _detailRow('Currency', product.currency),
                        ],
                      ),
                    ),
                    if (product.description != null &&
                        product.description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Description',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'Quantity',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _qtyButton(
                          icon: Icons.remove_rounded,
                          enabled: _quantity > 1,
                          onTap: () => setState(() => _quantity -= 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '$_quantity',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _qtyButton(
                          icon: Icons.add_rounded,
                          enabled: !_outOfStock &&
                              (product.stock == null || _quantity < product.stock!),
                          onTap: () => setState(() => _quantity += 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _outOfStock || _checkoutLoading ? null : _handleBuy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    disabledBackgroundColor: AppColors.bgTertiary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _checkoutLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _outOfStock
                              ? 'Out of Stock'
                              : 'Buy · ${_formatPrice(product, quantity: _quantity)}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textTertiary.withValues(alpha: 0.5),
        size: 64,
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Icon(
          icon,
          color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
          size: 20,
        ),
      ),
    );
  }

  String _formatPrice(MarketplaceProduct product, {int quantity = 1}) {
    final total = product.price * quantity;
    final symbol = product.currency == 'INR' ? '₹' : '${product.currency} ';
    return '$symbol${total.toStringAsFixed(total == total.roundToDouble() ? 0 : 2)}';
  }

  String _fulfillmentLabel(String fulfillment) {
    switch (fulfillment) {
      case 'DIGITAL_CODE':
        return 'Digital code';
      case 'PHYSICAL':
        return 'Physical pickup';
      default:
        return fulfillment.replaceAll('_', ' ').toLowerCase();
    }
  }
}
