import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/realtime/realtime_providers.dart';
import '../../../core/realtime/socket_io_service.dart';

class MachineRealtimeInfo {
  const MachineRealtimeInfo({
    this.status,
    this.temperature,
    this.humidity,
    this.lastHeartbeat,
  });

  final String? status;
  final double? temperature;
  final double? humidity;
  final DateTime? lastHeartbeat;

  MachineRealtimeInfo copyWith({
    String? status,
    double? temperature,
    double? humidity,
    DateTime? lastHeartbeat,
  }) {
    return MachineRealtimeInfo(
      status: status ?? this.status,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
    );
  }
}

class MachineRealtimeController
    extends Notifier<Map<int, MachineRealtimeInfo>> {
  @override
  Map<int, MachineRealtimeInfo> build() {
    ref.listen(socketEventsProvider, (prev, next) {
      next.whenData((event) {
        switch (event) {
          case StatusUpdate(:final machineId, :final status):
            final prevInfo = state[machineId] ?? const MachineRealtimeInfo();
            state = {
              ...state,
              machineId: prevInfo.copyWith(status: status.trim()),
            };

          case TemperatureUpdate(
            :final machineId,
            :final temperature,
            :final humidity,
          ):
            final prevInfo = state[machineId] ?? const MachineRealtimeInfo();
            state = {
              ...state,
              machineId: prevInfo.copyWith(
                temperature: temperature,
                humidity: humidity,
              ),
            };

          case Heartbeat(:final machineId):
            final prevInfo = state[machineId] ?? const MachineRealtimeInfo();
            state = {
              ...state,
              machineId: prevInfo.copyWith(lastHeartbeat: DateTime.now()),
            };

          default:
            break;
        }
      });
    });

    return const {};
  }
}

final machineRealtimeProvider =
    NotifierProvider<MachineRealtimeController, Map<int, MachineRealtimeInfo>>(
      MachineRealtimeController.new,
    );
