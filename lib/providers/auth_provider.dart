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
        _user = await ApiClient.getMe(token);
        _status = AuthStatus.authenticated;
      } catch (_) {
        await SecureStorage.deleteToken();
        _status = AuthStatus.unauthenticated;
      }
    } else {
      final claims = ApiClient.decodeJwtClaims(token);
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
    }
  }

  Future<bool> login(String email, String password) async {
    if (!await _startRequest()) return false;
    try {
      final result = await ApiClient.login(email, password);
      await SecureStorage.saveToken(result.token);
      _handleAuthSuccess(result.name, result.email);
      return true;
    } catch (e) {
      _handleAuthError(e);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    if (!await _startRequest()) return false;
    try {
      final result = await ApiClient.register(name, email, password);
      await SecureStorage.saveToken(result.token);
      _handleAuthSuccess(result.name, result.email);
      return true;
    } catch (e) {
      _handleAuthError(e);
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

  Future<bool> _startRequest() async {
    final results = await Connectivity().checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) {
      _loading = false;
      _errorMessage = 'Немає підключення до інтернету';
      notifyListeners();
      return false;
    }
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void _handleAuthSuccess(String name, String email) {
    _user = User(name: name, email: email);
    _status = AuthStatus.authenticated;
    _loading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void _handleAuthError(Object e) {
    _errorMessage =
        e is ApiException ? e.message : 'Помилка з\'єднання з сервером';
    _loading = false;
    notifyListeners();
  }
}
