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

  /// Lấy tất cả từ /product (BE trả: stock + available)
  Future<List<Product>> listAll({String? query}) async {
    final items = await _client.getListJson(ApiRoutes.products);

    final all = items
        .whereType<Map>()
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final q = (query ?? '').trim().toLowerCase();
    if (q.isEmpty) return all;

    return all.where((p) {
      final name = p.name.toLowerCase();
      final code = (p.productCode).toLowerCase();
      return name.contains(q) || code.contains(q);
    }).toList();
  }

  /// ✅ DANH SÁCH BÁN: available > 0
  Future<List<Product>> listForSale({String? query}) async {
    final all = await listAll(query: query);
    return all.where((p) => p.available > 0).toList();
  }

  Future<Product> getImportProductByCode(String code) async {
    final c = code.trim();
    final json = await _client.getJson("/shopqtqt/import/product/$c");
    return Product.fromJson(Map<String, dynamic>.from(json));
  }

  /// ✅ DANH SÁCH KHO: stock > 0 (hoặc show hết nếu onlyHasStock=false)
  Future<List<Product>> listWarehouse({
    String? query,
    bool onlyHasStock = true,
  }) async {
    final all = await listAll(query: query);
    if (!onlyHasStock) return all;
    return all.where((p) => p.stock > 0).toList();
  }

  Future<Product?> getById(String id) async {
    final items = await listAll();
    try {
      return items.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // =========================
  // CRUD SẢN PHẨM (KHÔNG ĐỤNG STOCK/AVAILABLE)
  // =========================

  /// body chỉ gồm thông tin sản phẩm:
  /// {productCode, name, idCategory, price, priceIn, description}
  Future<void> createRaw(Map<String, dynamic> body) async {
    // ✅ đảm bảo không gửi nhầm số lượng
    final safeBody = Map<String, dynamic>.from(body)
      ..remove('stock')
      ..remove('available');

    await _client.postJson(ApiRoutes.products, body: safeBody);
  }

  /// body chỉ gồm thông tin sản phẩm:
  /// {id, productCode, name, idCategory, price, priceIn, description}
  Future<void> updateRaw(Map<String, dynamic> body) async {
    // ✅ đảm bảo không gửi nhầm số lượng
    final safeBody = Map<String, dynamic>.from(body)
      ..remove('stock')
      ..remove('available');

    await _client.putJson(ApiRoutes.products, body: safeBody);
  }

  Future<void> deleteById(String id) async {
    await _client.delete(ApiRoutes.productById(id));
  }

  // =========================
  // ✅ UPDATE FULL (DÙNG CHO "SẢN PHẨM BÁN")
  // - cập nhật price + available (+ stock nếu cần giữ nguyên)
  // BE của bạn: PUT /shopqtqt/product
  // body: {id, productCode, name, idCategory, price, stock, available}
  // =========================
  Future<void> updateProduct({
    required String id,
    required String productCode,
    required String name,
    required int idCategory,
    required double price,
    required int available,
    required int stock,
  }) async {
    final body = <String, dynamic>{
      "id": int.tryParse(id) ?? id,
      "productCode": productCode.trim(),
      "name": name.trim(),
      "idCategory": idCategory,
      "price": price,
      "available": available,
      "stock": stock,
    };

    await _client.putJson(ApiRoutes.products, body: body);
  }

  /// Alias cho đồng bộ tên gọi với màn hình quản lý (nếu cần)
  Future<void> deleteProduct(String id) async {
    await deleteById(id);
  }

  // =========================
  // ✅ STOCK -> AVAILABLE (ĐƯA LÊN BÁN)
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
