import 'dart:convert';

import 'package:lab_1/data/user_repository.dart';
import 'package:lab_1/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserRepository implements UserRepository {
  static const _prefix = 'user_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<void> save(User user) async {
    final prefs = await _prefs;
    await prefs.setString('$_prefix${user.email}', jsonEncode(user.toJson()));
  }

  @override
  Future<User?> findByEmail(String email) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_prefix$email');
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  Future<void> update(User user) => save(user);

  @override
  Future<void> delete(String email) async {
    final prefs = await _prefs;
    await prefs.remove('$_prefix$email');
  }
}
