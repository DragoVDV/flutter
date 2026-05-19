import 'package:lab_1/models/medication.dart';

abstract interface class MedicationRepository {
  Future<List<Medication>> getAll(String userEmail);
  Future<void> save(Medication med, String userEmail);
  Future<void> update(Medication med, String userEmail);
  Future<void> delete(String id, String userEmail);
}
