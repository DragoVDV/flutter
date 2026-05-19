import 'dart:convert';

import 'package:lab_1/data/medication_repository.dart';
import 'package:lab_1/models/medication.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalMedicationRepository implements MedicationRepository {
  static const _prefix = 'meds_';

  Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  @override
  Future<List<Medication>> getAll(String userEmail) async {
    final prefs = await _prefs;
    final raw = prefs.getString('$_prefix$userEmail');
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Medication.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> save(Medication med, String userEmail) async {
    final meds = await getAll(userEmail);
    meds.add(med);
    await _persist(meds, userEmail);
  }

  @override
  Future<void> update(Medication med, String userEmail) async {
    final meds = await getAll(userEmail);
    final idx = meds.indexWhere((m) => m.id == med.id);
    if (idx == -1) return;
    meds[idx] = med;
    await _persist(meds, userEmail);
  }

  @override
  Future<void> delete(String id, String userEmail) async {
    final meds = await getAll(userEmail);
    meds.removeWhere((m) => m.id == id);
    await _persist(meds, userEmail);
  }

  Future<void> _persist(
    List<Medication> meds,
    String userEmail,
  ) async {
    final prefs = await _prefs;
    await prefs.setString(
      '$_prefix$userEmail',
      jsonEncode(meds.map((m) => m.toJson()).toList()),
    );
  }
}
