import 'package:lab_1/core/api_client.dart';
import 'package:lab_1/core/medication_api.dart';
import 'package:lab_1/core/secure_storage.dart';
import 'package:lab_1/data/medication_repository.dart';
import 'package:lab_1/models/medication.dart';

class RemoteMedicationRepository implements MedicationRepository {
  Future<String> _token() async {
    final t = await SecureStorage.readToken();
    if (t == null) throw const ApiException('Не авторизовано');
    return t;
  }

  @override
  Future<List<Medication>> getAll(String userEmail) async {
    final token = await _token();
    return MedicationApi.getMedications(token);
  }

  @override
  Future<void> save(Medication med, String userEmail) async {
    final token = await _token();
    await MedicationApi.addMedication(token, med);
  }

  @override
  Future<void> update(Medication med, String userEmail) async {
    final token = await _token();
    await MedicationApi.updateMedication(token, med);
  }

  @override
  Future<void> delete(String id, String userEmail) async {
    final token = await _token();
    await MedicationApi.deleteMedication(token, id);
  }
}
