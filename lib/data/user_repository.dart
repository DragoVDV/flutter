import 'package:lab_1/models/user.dart';

abstract interface class UserRepository {
  Future<void> save(User user);
  Future<User?> findByEmail(String email);
  Future<void> update(User user);
  Future<void> delete(String email);
}
