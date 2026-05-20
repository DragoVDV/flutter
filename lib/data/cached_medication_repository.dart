import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:lab_1/data/local/local_medication_repository.dart';
import 'package:lab_1/data/medication_repository.dart';
import 'package:lab_1/data/remote/remote_medication_repository.dart';
import 'package:lab_1/models/medication.dart';

class CachedMedicationRepository implements MedicationRepository {
  final _remote = RemoteMedicationRepository();
  final _local = LocalMedicationRepository();

  Future<bool> get _isOnline async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  @override
  Future<List<Medication>> getAll(String userEmail) async {
    if (!await _isOnline) return _local.getAll(userEmail);
    try {
      final meds = await _remote.getAll(userEmail);
      await _local.replaceAll(meds, userEmail);
      return meds;
    } catch (_) {
      return _local.getAll(userEmail);
    }
  }

  @override
  Future<void> save(Medication med, String userEmail) async {
    if (await _isOnline) {
      await _remote.save(med, userEmail);
    }
    await _local.save(med, userEmail);
  }

  @override
  Future<void> update(Medication med, String userEmail) async {
    if (await _isOnline) {
      await _remote.update(med, userEmail);
    }
    await _local.update(med, userEmail);
  }

  @override
  Future<void> delete(String id, String userEmail) async {
    if (await _isOnline) {
      await _remote.delete(id, userEmail);
    }
    await _local.delete(id, userEmail);
  }
}
