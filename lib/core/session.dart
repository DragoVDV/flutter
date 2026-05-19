import 'package:lab_1/data/local/local_medication_repository.dart';
import 'package:lab_1/data/local/local_user_repository.dart';
import 'package:lab_1/data/medication_repository.dart';
import 'package:lab_1/data/user_repository.dart';
import 'package:lab_1/models/user.dart';

class Session {
  Session._();
  static final instance = Session._();

  final UserRepository userRepo = LocalUserRepository();
  final MedicationRepository medRepo = LocalMedicationRepository();
  User? currentUser;
}
