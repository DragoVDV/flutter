import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_1/core/api_client.dart';
import 'package:lab_1/core/secure_storage.dart';
import 'package:lab_1/cubits/auth/auth_state.dart';
import 'package:lab_1/models/user.dart';

export 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  Future<void> tryAutoLogin() async {
    final token = await SecureStorage.readToken();
    if (token == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    final results = await Connectivity().checkConnectivity();
    final isOnline = results.any((r) => r != ConnectivityResult.none);

    if (isOnline) {
      try {
        final user = await ApiClient.getMe(token);
        emit(AuthAuthenticated(user));
      } catch (_) {
        await SecureStorage.deleteToken();
        emit(const AuthUnauthenticated());
      }
    } else {
      final claims = ApiClient.decodeJwtClaims(token);
      if (claims == null) {
        await SecureStorage.deleteToken();
        emit(const AuthUnauthenticated());
        return;
      }
      emit(
        AuthAuthenticated(
          User(
            name: claims['name'] as String? ?? '',
            email: claims['sub'] as String? ?? '',
          ),
        ),
      );
    }
  }

  Future<void> login(String email, String password) async {
    if (!await _checkConnectivity()) return;
    emit(const AuthLoading());
    try {
      final result = await ApiClient.login(email, password);
      await SecureStorage.saveToken(result.token);
      emit(AuthAuthenticated(User(name: result.name, email: result.email)));
    } catch (e) {
      emit(
        AuthError(
          e is ApiException ? e.message : 'Помилка з\'єднання з сервером',
        ),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    if (!await _checkConnectivity()) return;
    emit(const AuthLoading());
    try {
      final result = await ApiClient.register(name, email, password);
      await SecureStorage.saveToken(result.token);
      emit(AuthAuthenticated(User(name: result.name, email: result.email)));
    } catch (e) {
      emit(
        AuthError(
          e is ApiException ? e.message : 'Помилка з\'єднання з сервером',
        ),
      );
    }
  }

  Future<void> logout() async {
    await SecureStorage.deleteToken();
    emit(const AuthUnauthenticated());
  }

  void updateName(String name) {
    final current = state;
    if (current is! AuthAuthenticated) return;
    emit(AuthAuthenticated(current.user.copyWith(name: name)));
  }

  Future<bool> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) {
      emit(const AuthError('Немає підключення до інтернету'));
      return false;
    }
    return true;
  }
}
