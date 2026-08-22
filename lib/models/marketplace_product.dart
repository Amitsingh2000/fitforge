class MarketplaceProduct {
  final String id;
  final String? gymId;
  final String title;
  final String? description;
  final int priceInMinor;
  final double price;
  final String currency;
  final List<String> imageUrls;
  final int? stock;
  final String fulfillment;
  final bool isActive;

  const MarketplaceProduct({
    required this.id,
    this.gymId,
    required this.title,
    this.description,
    this.priceInMinor = 0,
    this.price = 0,
    this.currency = 'INR',
    this.imageUrls = const [],
    this.stock,
    this.fulfillment = 'DIGITAL_CODE',
    this.isActive = true,
  });

  factory MarketplaceProduct.fromJson(Map<String, dynamic> json) {
    return MarketplaceProduct(
      id: json['id'] as String? ?? '',
      gymId: json['gymId'] as String?,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      priceInMinor: (json['priceInMinor'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ??
          ((json['priceInMinor'] as num?)?.toDouble() ?? 0) / 100,
      currency: json['currency'] as String? ?? 'INR',
      imageUrls: (json['imageUrls'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      stock: (json['stock'] as num?)?.toInt(),
      fulfillment: json['fulfillment'] as String? ?? 'DIGITAL_CODE',
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class MarketplaceOffer {
  final String id;
  final String title;
  final String? body;
  final String? gymId;
  final String? productId;
  final String? couponId;

  const MarketplaceOffer({
    required this.id,
    required this.title,
    this.body,
    this.gymId,
    this.productId,
    this.couponId,
  });

  factory MarketplaceOffer.fromJson(Map<String, dynamic> json) {
    return MarketplaceOffer(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      gymId: json['gymId'] as String?,
      productId: json['productId'] as String?,
      couponId: json['couponId'] as String?,
    );
  }
}

class PaginatedMarketplaceProducts {
  final List<MarketplaceProduct> items;
  final int total;

  const PaginatedMarketplaceProducts({
    this.items = const [],
    this.total = 0,
  });

  factory PaginatedMarketplaceProducts.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map?;
    return PaginatedMarketplaceProducts(
      items: (json['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => MarketplaceProduct.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: (meta?['total'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ??
          0,
    );
  }
}
