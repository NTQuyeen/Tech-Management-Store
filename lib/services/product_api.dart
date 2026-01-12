import '../config/api_config.dart';
import '../config/api_routes.dart';
import '../models/product.dart';
import '../state/auth_session.dart';
import 'api_client.dart';

class ProductApi {
  final ApiClient _client;

  ProductApi({ApiClient? client})
    : _client =
          client ??
          ApiClient(
            baseUrl: ApiConfig.baseUrl,
            tokenProvider: () async => AuthSession.instance.token,
          );

  Future<List<Product>> list({String? query}) async {
    // BE chưa có search query param => FE tự lọc client-side
    final items = await _client.getListJson(ApiRoutes.products);

    final products = items
        .whereType<Map>()
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final q = (query ?? '').trim().toLowerCase();
    if (q.isEmpty) return products;

    return products.where((p) => (p.name).toLowerCase().contains(q)).toList();
  }

  Future<Product?> getById(String id) async {
    // BE chưa có GET /product/{id} => lấy list rồi tìm
    final items = await list();
    try {
      return items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> createRaw(Map<String, dynamic> body) async {
    await _client.postJson(ApiRoutes.products, body: body);
  }

  Future<void> updateRaw(Map<String, dynamic> body) async {
    await _client.putJson(ApiRoutes.products, body: body);
  }

  Future<void> deleteById(String id) async {
    await _client.delete(ApiRoutes.productById(id));
  }
}
