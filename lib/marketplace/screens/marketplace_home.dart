import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/marketplace_product.dart';
import '../../providers/gym_provider.dart';
import '../../providers/member_flow_providers.dart';
import '../../services/marketplace_service.dart';
import '../../theme/app_theme.dart';
import '../../dashboard/widgets/dashboard_glass_card.dart';
import '../../dashboard/widgets/member_async_value.dart';
import '../../dashboard/widgets/state_views.dart';
import 'orders_screen.dart';
import 'product_detail.dart';

/// Browse marketplace products and gym offers.
class MarketplaceHomeScreen extends ConsumerStatefulWidget {
  const MarketplaceHomeScreen({super.key});

  @override
  ConsumerState<MarketplaceHomeScreen> createState() =>
      _MarketplaceHomeScreenState();
}

class _MarketplaceHomeScreenState extends ConsumerState<MarketplaceHomeScreen> {
  List<MarketplaceOffer> _offers = [];
  bool _offersLoading = true;
  String? _offersError;

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() {
      _offersLoading = true;
      _offersError = null;
    });
    try {
      final gymId = ref.read(currentGymIdProvider);
      final offers =
          await ref.read(marketplaceServiceProvider).listOffers(gymId: gymId);
      if (mounted) {
        setState(() {
          _offers = offers;
          _offersLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _offersLoading = false;
          _offersError = e.toString();
        });
      }
    }
  }

  void _refresh() {
    final gymId = ref.read(currentGymIdProvider);
    ref.invalidate(marketplaceProductsProvider(gymId));
    _loadOffers();
  }

  @override
  Widget build(BuildContext context) {
    final gymId = ref.watch(currentGymIdProvider);
    final productsAsync = ref.watch(marketplaceProductsProvider(gymId));
    final selectedGym = ref.watch(selectedGymProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Marketplace',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_rounded, color: AppColors.textPrimary),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: MemberAsyncValue<PaginatedMarketplaceProducts>(
          value: productsAsync,
          loadingMessage: 'Loading products…',
          onRetry: _refresh,
          builder: (page) {
            final products = page.items.where((p) => p.isActive).toList();
            return RefreshIndicator(
              color: AppColors.accentBlue,
              onRefresh: () async => _refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  if (selectedGym != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Text(
                          selectedGym.gymName ?? 'Gym products',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(child: _buildOffersSection()),
                  if (products.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyStateView(
                        icon: Icons.shopping_bag_outlined,
                        title: 'No products yet',
                        subtitle:
                            'Check back later for gym supplements, gear, and perks.',
                        actionLabel: 'Refresh',
                        onAction: _refresh,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return _ProductCard(
                              product: product,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailScreen(product: product),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOffersSection() {
    if (_offersLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColors.accentBlue,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_offersError != null || _offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OFFERS',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _offers.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final offer = _offers[index];
                return SizedBox(
                  width: 240,
                  child: DashboardGlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer_rounded,
                              color: AppColors.accentPurple.withValues(alpha: 0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                offer.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Text(
                            offer.body ?? 'Limited-time gym offer',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final MarketplaceProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        product.imageUrls.isNotEmpty ? product.imageUrls.first : null;

    return GestureDetector(
      onTap: onTap,
      child: DashboardGlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  color: AppColors.bgSecondary,
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatPrice(product),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (product.stock != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.stock! > 0 ? '${product.stock} in stock' : 'Out of stock',
                      style: AppTextStyles.caption.copyWith(
                        color: product.stock! > 0
                            ? AppColors.textTertiary
                            : AppColors.accentCoral,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textTertiary.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }

  String _formatPrice(MarketplaceProduct product) {
    final symbol = product.currency == 'INR' ? '₹' : '${product.currency} ';
    return '$symbol${product.price.toStringAsFixed(product.price == product.price.roundToDouble() ? 0 : 2)}';
  }
}
