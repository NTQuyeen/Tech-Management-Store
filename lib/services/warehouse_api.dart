import '../config/api_config.dart';
import '../config/api_routes.dart';
import '../models/product.dart';
import '../state/auth_session.dart';
import 'api_client.dart';

class WarehouseApi {
  final ApiClient _client;

  WarehouseApi({ApiClient? client})
    : _client =
          client ??
          ApiClient(
            baseUrl: ApiConfig.baseUrl,
            tokenProvider: () async => AuthSession.instance.token,
          );

  /// UI đang gọi: _warehouseApi.getInventory()
  /// BE chưa có kho riêng => lấy tồn kho từ /shopqtqt/product
  Future<List<Product>> getInventory() async {
    final items = await _client.getListJson(ApiRoutes.products);

    return items
        .whereType<Map>()
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// UI đang gọi: _warehouseApi.getStockHistory()
  /// BE chưa có endpoint lịch sử nhập/xuất => trả rỗng để UI vẫn chạy
  Future<List<Map<String, dynamic>>> getStockHistory() async {
    return <Map<String, dynamic>>[];
  }
}
