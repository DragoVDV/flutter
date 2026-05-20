import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lab_1/models/user.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
}

abstract final class ApiClient {
  static const _baseUrl = 'http://localhost:8000';

  static Future<({String token, String name, String email})> login(
    String email,
    String password,
  ) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));
    _checkStatus(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final token = body['access_token'] as String;
    final claims = _decodeJwtClaims(token);
    return (
      token: token,
      name: claims['name'] as String? ?? '',
      email: claims['sub'] as String? ?? email,
    );
  }

  static Future<({String token, String name, String email})> register(
    String name,
    String email,
    String password,
  ) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));
    _checkStatus(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final token = body['access_token'] as String;
    final claims = _decodeJwtClaims(token);
    return (
      token: token,
      name: claims['name'] as String? ?? name,
      email: claims['sub'] as String? ?? email,
    );
  }

  static Future<User> getMe(String token) async {
    final res = await http
        .get(
          Uri.parse('$_baseUrl/auth/me'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));
    _checkStatus(res);
    return User.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static void _checkStatus(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    String message;
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      message = body['detail'] as String? ?? 'Помилка сервера';
    } catch (_) {
      message = 'Помилка сервера (${res.statusCode})';
    }
    throw ApiException(message);
  }

  static Map<String, dynamic> _decodeJwtClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final padded = parts[1].padRight(
        (parts[1].length + 3) & ~3,
        '=',
      );
      return jsonDecode(
        utf8.decode(base64Url.decode(padded)),
      ) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }
}
