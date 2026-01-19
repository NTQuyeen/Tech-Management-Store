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

  /// KHO HÀNG: lấy từ /product rồi lọc theo stock
  Future<List<Product>> getInventory({String? query}) async {
    final items = await _client.getListJson(ApiRoutes.products);

    final all = items
        .whereType<Map>()
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final q = (query ?? '').trim().toLowerCase();
    final filtered = q.isEmpty
        ? all
        : all.where((p) {
            final name = p.name.toLowerCase();
            final code = (p.productCode ?? '').toLowerCase();
            return name.contains(q) || code.contains(q);
          }).toList();

    // ✅ Kho = có stock
    return filtered.where((p) => p.stock > 0).toList();
  }

  /// ✅ NHẬP HÀNG:
  /// POST /shopqtqt/import
  /// Body tối thiểu: { productCode, quantity }
  ///
  /// Lưu ý: BE của bạn nếu sản phẩm CHƯA TỒN TẠI thì sẽ yêu cầu thêm:
  /// name, idCategory, price, priceIn...
  /// => bạn có 2 lựa chọn:
  /// 1) Chỉ cho nhập hàng các SP đã tồn tại (khuyến nghị)
  /// 2) Nếu muốn nhập tạo mới luôn thì truyền thêm các field đó ở đây.
  Future<void> importStock({
    required String productCode,
    required int quantity,
    String? name,
    int? idCategory,
    num? price,
    num? priceIn,
    String? description,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('quantity phải > 0');
    }

    final body = <String, dynamic>{
      "productCode": productCode,
      "quantity": quantity,
    };

    // Nếu bạn muốn nhập hàng cho SP chưa tồn tại thì phải gửi thêm các field này:
    if (name != null) body["name"] = name;
    if (idCategory != null) body["idCategory"] = idCategory;
    if (price != null) body["price"] = price;
    if (priceIn != null) body["priceIn"] = priceIn;
    if (description != null) body["description"] = description;

    await _client.postJson("/shopqtqt/import", body: body);
  }

  // =========================
  // ✅ STOCK -> AVAILABLE (ĐƯA LÊN BÁN) từ màn Kho cũng gọi chung endpoint
  // BE: POST /shopqtqt/product/{id}/release?qty=...
  // =========================
  Future<void> releaseToSale({
    required String productId,
    required int qty,
  }) async {
    if (qty <= 0) {
      throw ArgumentError('qty phải > 0');
    }

    await _client.postJson(
      "/shopqtqt/product/$productId/release?qty=$qty",
      body: const {},
    );
  }
}
