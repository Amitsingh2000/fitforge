import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/marketplace_order.dart';
import '../models/marketplace_product.dart';
import 'api_client.dart';
import 'api_data.dart';

/// Marketplace browse + order API.
class MarketplaceService {
  final Dio dio;
  MarketplaceService(this.dio);

  Future<PaginatedMarketplaceProducts> listProducts({
    String? gymId,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await dio.get('/marketplace/products', queryParameters: {
      if (gymId != null) 'gymId': gymId,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page,
      'limit': limit,
    });
    return PaginatedMarketplaceProducts.fromJson(asMap(res.data));
  }

  Future<List<MarketplaceOffer>> listOffers({String? gymId}) async {
    final res = await dio.get(
      '/marketplace/offers',
      queryParameters: {if (gymId != null) 'gymId': gymId},
    );
    final map = asMap(res.data);
    return (map['offers'] as List? ?? extractList(res.data))
        .whereType<Map>()
        .map((e) => MarketplaceOffer.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<MarketplaceOrderCheckout> createOrder({
    required String idempotencyKey,
    required List<Map<String, dynamic>> lines,
  }) async {
    final res = await dio.post('/marketplace/orders', data: {
      'idempotencyKey': idempotencyKey,
      'lines': lines,
    });
    return MarketplaceOrderCheckout.fromJson(asMap(res.data));
  }

  Future<PaginatedMarketplaceOrders> listMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final res = await dio.get('/marketplace/orders/me', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return PaginatedMarketplaceOrders.fromJson(asMap(res.data));
  }
}

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  return MarketplaceService(ref.watch(dioProvider));
});
