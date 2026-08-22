import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/checkout_session.dart';
import '../models/invoice.dart';
import 'api_client.dart';
import 'api_data.dart';

/// Member billing — premium checkout and invoice history.
class BillingService {
  final Dio dio;
  BillingService(this.dio);

  Future<CheckoutSession> checkout({
    required String idempotencyKey,
    String? couponCode,
  }) async {
    final res = await dio.post('/subscriptions/me/checkout', data: {
      'idempotencyKey': idempotencyKey,
      if (couponCode != null) 'couponCode': couponCode,
    });
    return CheckoutSession.fromJson(asMap(res.data));
  }

  Future<List<Invoice>> listInvoices() async {
    final res = await dio.get('/subscriptions/me/invoices');
    return InvoiceList.fromJson(asMap(res.data)).invoices;
  }
}

final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService(ref.watch(dioProvider));
});
