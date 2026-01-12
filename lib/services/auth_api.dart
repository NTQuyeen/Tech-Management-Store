import '../config/api_config.dart';
import '../config/api_routes.dart';
import '../state/auth_session.dart';
import 'api_client.dart';

class AuthUser {
  final String? userId;
  final String username;
  final String fullName;
  final String role;
  final String? token;

  const AuthUser({
    required this.username,
    required this.fullName,
    required this.role,
    this.userId,
    this.token,
  });
}

class AuthApi {
  final ApiClient _client;

  AuthApi({ApiClient? client})
    : _client = client ?? ApiClient(baseUrl: ApiConfig.baseUrl);

  /// BE:
  /// POST /shopqtqt/login
  /// Body: {"username":"...","password":"..."}
  /// Response: Users entity (không có token)
  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    final json = await _client.postJson(
      ApiRoutes.authLogin,
      body: {'username': username, 'password': password},
    );

    final Map<String, dynamic> root = (json['data'] is Map<String, dynamic>)
        ? (json['data'] as Map<String, dynamic>)
        : json;

    final role = (root['role'] ?? 'staff').toString();
    final fullName = (root['fullName'] ?? username).toString();
    final userId = (root['id'] ?? root['userId'])?.toString();
    final serverUsername = (root['username'] ?? username).toString();

    final authUser = AuthUser(
      userId: userId,
      username: serverUsername,
      fullName: fullName,
      role: role.toLowerCase() == 'admin' ? 'admin' : 'staff',
      token: null, // BE chưa trả JWT
    );

    final session = AuthSession.instance;
    session.token = authUser.token;
    session.userId = authUser.userId;
    session.username = authUser.username;
    session.fullName = authUser.fullName;
    session.role = authUser.role;

    return authUser;
  }
}
