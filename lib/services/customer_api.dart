import '../config/api_config.dart';
import '../config/api_routes.dart';
import '../state/auth_session.dart';
import 'api_client.dart';

class CustomerApi {
  final ApiClient _client;

  CustomerApi({ApiClient? client})
    : _client =
          client ??
          ApiClient(
            baseUrl: ApiConfig.baseUrl,
            tokenProvider: () async => AuthSession.instance.token,
          );

  /// Trả về Map (customer json) hoặc null nếu không có
  Future<Map<String, dynamic>?> getByPhone(String phone) async {
    try {
      final json = await _client.getJson(ApiRoutes.customerByPhone(phone));
      final dynamic root = json['data'] ?? json;
      if (root is Map<String, dynamic>) return root;
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
}
