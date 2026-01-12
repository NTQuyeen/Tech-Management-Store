import '../config/api_config.dart';
import '../state/auth_session.dart';
import 'api_client.dart';

class RevenueApi {
  final ApiClient _client;

  RevenueApi({ApiClient? client})
    : _client =
          client ??
          ApiClient(
            baseUrl: ApiConfig.baseUrl,
            tokenProvider: () async => AuthSession.instance.token,
          );

  /// Expected: {label: '01/12', revenue: 123, orders: 5}
  Future<List<Map<String, dynamic>>> getDaily() async {
    return <Map<String, dynamic>>[];
  }

  /// Expected: {label: 'Thg 1', revenue: 123, orders: 5}
  Future<List<Map<String, dynamic>>> getMonthly() async {
    return <Map<String, dynamic>>[];
  }

  /// Expected: {name: '...', qty: 120, revenue: 3800000000}
  Future<List<Map<String, dynamic>>> getTopProducts() async {
    return <Map<String, dynamic>>[];
  }
}
