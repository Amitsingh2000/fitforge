/// Invoice from `GET /subscriptions/me/invoices`.
class Invoice {
  final String id;
  final String planName;
  final double amountPaid;
  final int amountInMinor;
  final String currency;
  final DateTime? paidAt;
  final String status;
  final String? receiptPdfUrl;

  const Invoice({
    required this.id,
    required this.planName,
    this.amountPaid = 0,
    this.amountInMinor = 0,
    this.currency = 'INR',
    this.paidAt,
    this.status = 'PAID',
    this.receiptPdfUrl,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ??
          ((json['amountInMinor'] as num?)?.toDouble() ?? 0) / 100,
      amountInMinor: (json['amountInMinor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'INR',
      paidAt: json['paidAt'] is String
          ? DateTime.tryParse(json['paidAt'] as String)
          : null,
      status: json['status'] as String? ?? 'PAID',
      receiptPdfUrl: json['receiptPdfUrl'] as String?,
    );
  }
}

class InvoiceList {
  final List<Invoice> invoices;

  const InvoiceList({this.invoices = const []});

  factory InvoiceList.fromJson(Map<String, dynamic> json) {
    return InvoiceList(
      invoices: (json['invoices'] as List? ?? [])
          .whereType<Map>()
          .map((e) => Invoice.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
