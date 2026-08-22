/// Checkout session from `POST /subscriptions/me/checkout`.
class CheckoutSession {
  final String paymentIntentId;
  final String provider;
  final String? providerRef;
  final String? checkoutUrl;
  final String? clientSecret;
  final String? razorpayKeyId;
  final int amountInMinor;
  final String currency;
  final String status;
  final bool reused;

  const CheckoutSession({
    required this.paymentIntentId,
    required this.provider,
    this.providerRef,
    this.checkoutUrl,
    this.clientSecret,
    this.razorpayKeyId,
    this.amountInMinor = 0,
    this.currency = 'INR',
    this.status = 'PENDING',
    this.reused = false,
  });

  factory CheckoutSession.fromJson(Map<String, dynamic> json) {
    return CheckoutSession(
      paymentIntentId: json['paymentIntentId'] as String? ?? '',
      provider: json['provider'] as String? ?? '',
      providerRef: json['providerRef'] as String?,
      checkoutUrl: json['checkoutUrl'] as String?,
      clientSecret: json['clientSecret'] as String?,
      razorpayKeyId: json['razorpayKeyId'] as String?,
      amountInMinor: (json['amountInMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'PENDING',
      reused: json['reused'] as bool? ?? false,
    );
  }

  double get amountMajor => amountInMinor / 100;
}
