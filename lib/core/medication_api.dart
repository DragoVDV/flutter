import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lab_1/core/api_client.dart';
import 'package:lab_1/models/medication.dart';

abstract final class MedicationApi {
  static const _baseUrl = 'http://192.168.10.102:8000';

  static Future<List<Medication>> getMedications(String token) async {
    final res = await http
        .get(
          Uri.parse('$_baseUrl/medications'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));
    _checkStatus(res);
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => Medication.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Medication> addMedication(String token, Medication med) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/medications'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(med.toJson()),
        )
        .timeout(const Duration(seconds: 10));
    _checkStatus(res);
    return Medication.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<Medication> updateMedication(
    String token,
    Medication med,
  ) async {
    final res = await http
        .put(
          Uri.parse('$_baseUrl/medications/${med.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(med.toJson()),
        )
        .timeout(const Duration(seconds: 10));
    _checkStatus(res);
    return Medication.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<void> deleteMedication(String token, String id) async {
    final res = await http
        .delete(
          Uri.parse('$_baseUrl/medications/$id'),
          headers: {'Authorization': 'Bearer $token'},
        )
        .timeout(const Duration(seconds: 10));
    _checkStatus(res);
  }

  static void _checkStatus(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    String message;
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      message = body['detail'] as String? ?? 'Помилка сервера';
    } catch (_) {
      message = 'Помилка сервера (${res.statusCode})';
    }
    throw ApiException(message);
  }
}
