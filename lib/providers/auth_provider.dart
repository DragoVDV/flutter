import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:lab_1/core/api_client.dart';
import 'package:lab_1/core/secure_storage.dart';
import 'package:lab_1/models/user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _loading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isLoading => _loading;
  String? get errorMessage => _errorMessage;

  /// Called once before runApp — no notifyListeners needed.
  Future<void> tryAutoLogin() async {
    final token = await SecureStorage.readToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      return;
    }

    final results = await Connectivity().checkConnectivity();
    final isOnline = results.any((r) => r != ConnectivityResult.none);

    if (isOnline) {
      try {
        final user = await ApiClient.getMe(token);
        _user = user;
        _status = AuthStatus.authenticated;
      } catch (_) {
        await SecureStorage.deleteToken();
        _status = AuthStatus.unauthenticated;
      }
    } else {
      // Offline — decode token locally to get user info
      final claims = _decodeJwtClaims(token);
      if (claims == null) {
        await SecureStorage.deleteToken();
        _status = AuthStatus.unauthenticated;
        return;
      }
      _user = User(
        name: claims['name'] as String? ?? '',
        email: claims['sub'] as String? ?? '',
      );
      _status = AuthStatus.authenticated;
      // ConnectivityProvider will show the offline banner automatically
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final results = await Connectivity().checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) {
      _loading = false;
      _errorMessage = 'Немає підключення до інтернету';
      notifyListeners();
      return false;
    }

    try {
      final result = await ApiClient.login(email, password);
      await SecureStorage.saveToken(result.token);
      _user = User(name: result.name, email: result.email);
      _status = AuthStatus.authenticated;
      _loading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Помилка з\'єднання з сервером';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    final results = await Connectivity().checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) {
      _loading = false;
      _errorMessage = 'Немає підключення до інтернету';
      notifyListeners();
      return false;
    }

    try {
      final result = await ApiClient.register(name, email, password);
      await SecureStorage.saveToken(result.token);
      _user = User(name: result.name, email: result.email);
      _status = AuthStatus.authenticated;
      _loading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _loading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Помилка з\'єднання з сервером';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void updateName(String name) {
    if (_user == null) return;
    _user = _user!.copyWith(name: name);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  static Map<String, dynamic>? _decodeJwtClaims(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final padded = parts[1].padRight(
        (parts[1].length + 3) & ~3,
        '=',
      );
      final claims = jsonDecode(
        utf8.decode(base64Url.decode(padded)),
      ) as Map<String, dynamic>;
      final exp = claims['exp'] as int?;
      if (exp != null &&
          DateTime.fromMillisecondsSinceEpoch(exp * 1000)
              .isBefore(DateTime.now())) {
        return null;
      }
      return claims;
    } catch (_) {
      return null;
    }
  }
}
