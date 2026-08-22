class MarketplaceOrderLine {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final int unitPriceInMinor;

  const MarketplaceOrderLine({
    required this.id,
    required this.productId,
    required this.title,
    this.quantity = 1,
    this.unitPriceInMinor = 0,
  });

  factory MarketplaceOrderLine.fromJson(Map<String, dynamic> json) {
    return MarketplaceOrderLine(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPriceInMinor: (json['unitPriceInMinor'] as num?)?.toInt() ?? 0,
    );
  }
}

class MarketplaceOrder {
  final String id;
  final String status;
  final int totalInMinor;
  final double total;
  final String currency;
  final dynamic fulfillmentPayload;
  final List<MarketplaceOrderLine> lines;
  final DateTime? createdAt;

  const MarketplaceOrder({
    required this.id,
    required this.status,
    this.totalInMinor = 0,
    this.total = 0,
    this.currency = 'INR',
    this.fulfillmentPayload,
    this.lines = const [],
    this.createdAt,
  });

  factory MarketplaceOrder.fromJson(Map<String, dynamic> json) {
    return MarketplaceOrder(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalInMinor: (json['totalInMinor'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toDouble() ??
          ((json['totalInMinor'] as num?)?.toDouble() ?? 0) / 100,
      currency: json['currency'] as String? ?? 'INR',
      fulfillmentPayload: json['fulfillmentPayload'],
      lines: (json['lines'] as List? ?? [])
          .whereType<Map>()
          .map((e) => MarketplaceOrderLine.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: json['createdAt'] is String
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }
}

class MarketplaceOrderCheckout {
  final String orderId;
  final String status;
  final int totalInMinor;
  final String currency;
  final String? paymentIntentId;
  final String? provider;
  final String? providerRef;
  final String? paymentStatus;
  final String? razorpayKeyId;
  final bool reused;

  const MarketplaceOrderCheckout({
    required this.orderId,
    required this.status,
    this.totalInMinor = 0,
    this.currency = 'INR',
    this.paymentIntentId,
    this.provider,
    this.providerRef,
    this.paymentStatus,
    this.razorpayKeyId,
    this.reused = false,
  });

  factory MarketplaceOrderCheckout.fromJson(Map<String, dynamic> json) {
    return MarketplaceOrderCheckout(
      orderId: json['orderId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      totalInMinor: (json['totalInMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      paymentIntentId: json['paymentIntentId'] as String?,
      provider: json['provider'] as String?,
      providerRef: json['providerRef'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      razorpayKeyId: json['razorpayKeyId'] as String?,
      reused: json['reused'] as bool? ?? false,
    );
  }
}

class PaginatedMarketplaceOrders {
  final List<MarketplaceOrder> items;
  final int total;

  const PaginatedMarketplaceOrders({
    this.items = const [],
    this.total = 0,
  });

  factory PaginatedMarketplaceOrders.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map?;
    return PaginatedMarketplaceOrders(
      items: (json['items'] as List? ?? [])
          .whereType<Map>()
          .map((e) => MarketplaceOrder.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      total: (meta?['total'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ??
          0,
    );
  }
}
