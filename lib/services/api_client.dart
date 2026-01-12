import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  final String baseUrl;
  final http.Client _http;
  final TokenProvider? tokenProvider;

  ApiClient({
    required this.baseUrl,
    this.tokenProvider,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse(
      '$normalizedBase$normalizedPath',
    ).replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers(Map<String, String>? headers) async {
    final token = tokenProvider == null ? null : await tokenProvider!.call();

    return {
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      ...?headers,
    };
  }

  dynamic _decodeBody(String body) {
    final text = body.trim();
    if (text.isEmpty) return null;
    return jsonDecode(text);
  }

  Never _throwForStatus(http.Response res) {
    throw ApiException(res.statusCode, res.body);
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await _http.get(
      _uri(path, query),
      headers: await _headers(headers),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) _throwForStatus(res);

    final decoded = _decodeBody(res.body);
    if (decoded == null) return <String, dynamic>{};

    if (decoded is Map<String, dynamic>) return decoded;
    // Sometimes APIs return a raw list; wrap it
    return <String, dynamic>{'data': decoded};
  }

  Future<List<dynamic>> getListJson(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await _http.get(
      _uri(path, query),
      headers: await _headers(headers),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) _throwForStatus(res);

    final decoded = _decodeBody(res.body);
    return _extractList(decoded);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await _http.post(
      _uri(path, query),
      headers: {
        ...(await _headers(headers)),
        'Content-Type': 'application/json',
      },
      body: body == null ? null : jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) _throwForStatus(res);

    final decoded = _decodeBody(res.body);
    if (decoded == null) return <String, dynamic>{};

    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await _http.put(
      _uri(path, query),
      headers: {
        ...(await _headers(headers)),
        'Content-Type': 'application/json',
      },
      body: body == null ? null : jsonEncode(body),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) _throwForStatus(res);

    final decoded = _decodeBody(res.body);
    if (decoded == null) return <String, dynamic>{};

    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }

  Future<void> delete(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    final res = await _http.delete(
      _uri(path, query),
      headers: await _headers(headers),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) _throwForStatus(res);
  }

  List<dynamic> _extractList(dynamic decoded) {
    if (decoded == null) return const [];

    if (decoded is List) return decoded;

    if (decoded is Map) {
      final candidates = [
        decoded['data'],
        decoded['items'],
        decoded['results'],
        decoded['content'],
      ];
      for (final c in candidates) {
        if (c is List) return c;
      }
    }

    // Unknown shape
    return const [];
  }
}
