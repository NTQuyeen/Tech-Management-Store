import '../config/api_config.dart';
import '../config/api_routes.dart';
import '../state/auth_session.dart';
import 'api_client.dart';

class InvoiceApi {
  final ApiClient _client;

  InvoiceApi({ApiClient? client})
    : _client =
          client ??
          ApiClient(
            baseUrl: ApiConfig.baseUrl,
            tokenProvider: () async => AuthSession.instance.token,
          );

  /// BE: POST /shopqtqt/product-invoice
  /// Body: { productCode: "P101", number: 2 }
  /// Response: { id, name, price, quantity }
  Future<Map<String, dynamic>> addProductToInvoice(
    Map<String, dynamic> body,
  ) async {
    final json = await _client.postJson(ApiRoutes.productInvoice, body: body);

    // đảm bảo luôn trả Map<String,dynamic>
    if (json is Map) return Map<String, dynamic>.from(json);

    // nếu BE trả kiểu khác -> coi như lỗi
    throw Exception('Invalid response from product-invoice: $json');
  }

  /// BE: POST /shopqtqt/invoice
  /// Body theo InvoiceRequired
  /// BE thường trả void/ok -> FE không cần parse
  Future<void> createInvoiceLegacy(Map<String, dynamic> invoiceRequired) async {
    await _client.postJson(ApiRoutes.invoice, body: invoiceRequired);
  }

  /// BE: GET /shopqtqt/customer/{phone}
  /// Response: Customers entity (ví dụ {customerId, fullName, phone, email,...})
  Future<Map<String, dynamic>> getCustomerByPhone(String phone) async {
    final json = await _client.getJson(ApiRoutes.customerByPhone(phone));

    if (json is Map) return Map<String, dynamic>.from(json);

    throw Exception('Invalid response from customerByPhone: $json');
  }
}
