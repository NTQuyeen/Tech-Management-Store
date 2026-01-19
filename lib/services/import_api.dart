import '../config/api_config.dart';
import '../state/auth_session.dart';
import 'api_client.dart';

class ImportApi {
  final ApiClient _client;

  ImportApi({ApiClient? client})
    : _client =
          client ??
          ApiClient(
            baseUrl: ApiConfig.baseUrl,
            tokenProvider: () async => AuthSession.instance.token,
          );

  /// GET /shopqtqt/import/product/{code}
  /// - Nếu có: trả Products
  /// - Nếu không có: BE trả 404
  Future<Map<String, dynamic>> findProductByCode(String code) async {
    final safe = Uri.encodeComponent(code.trim());
    final res = await _client.getJson("/shopqtqt/import/product/$safe");
    return Map<String, dynamic>.from(res as Map);
  }

  /// GET /shopqtqt/import/provider/{phone}
  /// - Nếu có: trả Provider
  /// - Nếu không có: BE trả 404
  Future<Map<String, dynamic>> findProviderByPhone(String phone) async {
    final res = await _client.getJson("/shopqtqt/import/provider/$phone");
    return Map<String, dynamic>.from(res as Map);
  }

  /// POST /shopqtqt/import
  Future<void> importStock({
    required String productCode,
    required int quantity,

    // bắt buộc nếu tạo mới
    String? name,
    int? idCategory,
    num? price,
    num? priceIn,
    String? description,

    // supplier info (optional)
    String? supplierPhone,
    String? supplierName,
    String? supplierEmail,
    String? supplierAddress,
  }) async {
    final body = <String, dynamic>{
      "productCode": productCode.trim(),
      "quantity": quantity,
    };

    if (name != null && name.trim().isNotEmpty) body["name"] = name.trim();
    if (idCategory != null) body["idCategory"] = idCategory;
    if (price != null) body["price"] = price;
    if (priceIn != null) body["priceIn"] = priceIn;
    if (description != null) body["description"] = description;

    if (supplierPhone != null && supplierPhone.trim().isNotEmpty) {
      body["phone"] = supplierPhone.trim();
    }
    if (supplierName != null && supplierName.trim().isNotEmpty) {
      body["nameProvider"] = supplierName.trim();
    }
    if (supplierEmail != null && supplierEmail.trim().isNotEmpty) {
      body["email"] = supplierEmail.trim();
    }
    if (supplierAddress != null && supplierAddress.trim().isNotEmpty) {
      body["address"] = supplierAddress.trim();
    }

    await _client.postJson("/shopqtqt/import", body: body);
  }
}
