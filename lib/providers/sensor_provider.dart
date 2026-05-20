import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class SlotState {
  const SlotState({
    required this.id,
    required this.label,
    required this.hasPill,
    required this.lastUpdated,
  });

  final int id;
  final String label;
  final bool hasPill;
  final DateTime lastUpdated;
}

class SensorProvider extends ChangeNotifier {
  // Local Mosquitto — iOS simulator shares host network, so localhost works
  static const _broker = 'ws://localhost';
  static const _wsPort = 9001;
  static const _topic = 'medbox/sensor/pillbox';

  MqttServerClient? _client;
  bool _connected = false;
  List<SlotState> _slots = [];
  DateTime? _lastUpdate;
  String? _connectionError;

  bool get isConnected => _connected;
  List<SlotState> get slots => List.unmodifiable(_slots);
  DateTime? get lastUpdate => _lastUpdate;
  String? get connectionError => _connectionError;

  int get pillsPresent => _slots.where((s) => s.hasPill).length;
  int get totalSlots => _slots.length;

  Future<void> connect() async {
    if (_connected) return;

    final clientId =
        'medbox_flutter_${DateTime.now().millisecondsSinceEpoch}';

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
      _connectionError = 'Помилка підключення: $e';
      _client?.disconnect();
      notifyListeners();
      return;
    }

    if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.subscribe(_topic, MqttQos.atLeastOnce);
      _client!.updates!.listen(_onMessage);
    } else {
      _connectionError =
          'Не вдалося підключитись (${_client!.connectionStatus?.state})';
      notifyListeners();
    }
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
    _connected = false;
  }

  void _onConnected() {
    _connected = true;
    _connectionError = null;
    notifyListeners();
  }

  void _onDisconnected() {
    _connected = false;
    notifyListeners();
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> events) {
    final raw = events[0].payload as MqttPublishMessage;
    final payload = MqttPublishPayload.bytesToStringAsString(
      raw.payload.message,
    );
    try {
      final json = jsonDecode(payload) as Map<String, dynamic>;
      final now = DateTime.now();
      final rawSlots = json['slots'] as List<dynamic>;
      _slots = rawSlots.map((s) {
        final slot = s as Map<String, dynamic>;
        return SlotState(
          id: slot['id'] as int,
          label: slot['label'] as String,
          hasPill: slot['has_pill'] as bool,
          lastUpdated: now,
        );
      }).toList();
      _lastUpdate = now;
      notifyListeners();
    } catch (_) {
      // malformed message — ignore
    }
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
