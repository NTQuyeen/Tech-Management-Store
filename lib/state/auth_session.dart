class AuthSession {
  AuthSession._();
  static final AuthSession instance = AuthSession._();

  String? token;
  String? userId;
  String? username;
  String? fullName;
  String? role;

  bool get isLoggedIn => token != null && token!.isNotEmpty;

  void clear() {
    token = null;
    userId = null;
    username = null;
    fullName = null;
    role = null;
  }
}
