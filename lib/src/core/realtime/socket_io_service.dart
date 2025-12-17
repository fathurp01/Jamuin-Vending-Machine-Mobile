import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../config/backend_config.dart';

sealed class SocketEvent {
  const SocketEvent();
}

final class SocketConnected extends SocketEvent {
  const SocketConnected(this.payload);
  final Map<String, Object?> payload;
}

final class TemperatureUpdate extends SocketEvent {
  const TemperatureUpdate({
    required this.machineId,
    this.temperature,
    this.humidity,
  });
  final int machineId;
  final double? temperature;
  final double? humidity;
}

final class StatusUpdate extends SocketEvent {
  const StatusUpdate({required this.machineId, required this.status});
  final int machineId;
  final String status;
}

final class Heartbeat extends SocketEvent {
  const Heartbeat({required this.machineId, required this.machineCode});
  final int machineId;
  final String machineCode;
}

final class SocketIoService {
  SocketIoService() {
    _events = StreamController<SocketEvent>.broadcast();
  }

  late final StreamController<SocketEvent> _events;
  io.Socket? _socket;

  Stream<SocketEvent> get events => _events.stream;

  bool get isConnected => _socket?.connected ?? false;

  String _socketBaseUrl() {
    // socket.io client expects http(s) base.
    return BackendConfig.baseUrl;
  }

  void connect() {
    if (_socket != null) return;

    final socket = io.io(
      _socketBaseUrl(),
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableReconnection()
          .setReconnectionAttempts(999)
          .setReconnectionDelay(1000)
          .build(),
    );

    socket.onConnect((_) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('socket.io connected');
      }
    });

    socket.on('connected', (data) {
      final payload = data is Map
          ? data.cast<String, Object?>()
          : const <String, Object?>{};
      _events.add(SocketConnected(payload));
    });

    socket.on('temperature-update', (data) {
      if (data is! Map) return;
      final m = data.cast<String, Object?>();
      final machineId = ((m['machineId'] as num?) ?? 0).toInt();
      if (machineId <= 0) return;
      final t = m['temperature'];
      final h = m['humidity'];
      _events.add(
        TemperatureUpdate(
          machineId: machineId,
          temperature: t is num ? t.toDouble() : null,
          humidity: h is num ? h.toDouble() : null,
        ),
      );
    });

    socket.on('status-update', (data) {
      if (data is! Map) return;
      final m = data.cast<String, Object?>();
      final machineId = ((m['machineId'] as num?) ?? 0).toInt();
      if (machineId <= 0) return;
      final status = (m['status'] as String?) ?? '';
      _events.add(StatusUpdate(machineId: machineId, status: status));
    });

    socket.on('heartbeat', (data) {
      if (data is! Map) return;
      final m = data.cast<String, Object?>();
      final machineId = ((m['machineId'] as num?) ?? 0).toInt();
      if (machineId <= 0) return;
      final machineCode = (m['machineCode'] as String?) ?? '';
      _events.add(Heartbeat(machineId: machineId, machineCode: machineCode));
    });

    _socket = socket;
  }

  void subscribeMachine(int machineId) {
    _socket?.emit('subscribe-machine', machineId);
  }

  void unsubscribeMachine(int machineId) {
    _socket?.emit('unsubscribe-machine', machineId);
  }

  Future<void> dispose() async {
    try {
      _socket?.dispose();
      _socket = null;
    } finally {
      await _events.close();
    }
  }
}
