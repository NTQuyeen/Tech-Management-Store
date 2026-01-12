class ApiConfig {
  /// Chạy app với:
  /// flutter run -d windows --dart-define=API_BASE_URL=http://localhost:8080
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
}
