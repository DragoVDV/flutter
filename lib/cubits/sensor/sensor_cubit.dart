import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab_1/cubits/sensor/sensor_state.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

export 'sensor_state.dart';

class SensorCubit extends Cubit<SensorState> {
  SensorCubit() : super(const SensorDisconnected());

  static const _broker = 'ws://localhost';
  static const _wsPort = 9001;
  static const _topic = 'medbox/sensor/pillbox';

  MqttServerClient? _client;

  Future<void> connect() async {
    if (state is SensorConnected || state is SensorConnecting) return;
    emit(const SensorConnecting());

    final clientId = 'medbox_flutter_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient(_broker, clientId)
      ..port = _wsPort
      ..useWebSocket = true
      ..websocketProtocols = MqttClientConstants.protocolsSingleDefault
      ..keepAlivePeriod = 20
      ..autoReconnect = true
      ..logging(on: false)
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected;

    _client!.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    try {
      await _client!.connect();
    } catch (e) {
      emit(SensorError('Помилка підключення: $e'));
      _client?.disconnect();
      return;
    }

    if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.subscribe(_topic, MqttQos.atLeastOnce);
      _client!.updates!.listen(_onMessage);
    } else {
      emit(
        SensorError(
          'Не вдалося підключитись (${_client!.connectionStatus?.state})',
        ),
      );
    }
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
    emit(const SensorDisconnected());
  }

  void _onConnected() =>
      emit(SensorConnected(slots: const [], lastUpdate: DateTime.now()));

  void _onDisconnected() => emit(const SensorDisconnected());

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> events) {
    final raw = events[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
      raw.payload.message,
    );
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final now = DateTime.now();
      final slots = (json['slots'] as List<dynamic>).map((s) {
        final slot = s as Map<String, dynamic>;
        return SlotState(
          id: slot['id'] as int,
          label: slot['label'] as String,
          hasPill: slot['has_pill'] as bool,
          lastUpdated: now,
        );
      }).toList();
      emit(SensorConnected(slots: slots, lastUpdate: now));
    } catch (_) {}
  }

  @override
  Future<void> close() {
    disconnect();
    return super.close();
  }
}
