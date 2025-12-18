import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/realtime/realtime_providers.dart';
import '../../../core/realtime/socket_io_service.dart';
import '../../map/presentation/machine_models.dart';
import '../../map/presentation/machine_providers.dart';
import '../../../shared/widgets/rounded_card.dart';

class AdminMachinesMonitorScreen extends ConsumerStatefulWidget {
  const AdminMachinesMonitorScreen({super.key});

  @override
  ConsumerState<AdminMachinesMonitorScreen> createState() =>
      _AdminMachinesMonitorScreenState();
}

class _AdminMachinesMonitorScreenState
    extends ConsumerState<AdminMachinesMonitorScreen> {
  final Map<int, MachineRealtimeData> _machineData = {};
  final Set<int> _subscribedMachineIds = {};
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Connect to socket.io when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = ref.read(socketIoServiceProvider);
      service.connect();

      // Start periodic polling for new machines (every 30 seconds)
      _startPolling();
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      // Refresh machine list to detect new machines
      ref.invalidate(machinesProvider);
    });
  }

  void _subscribeToNewMachines(List<VendingMachine> machines) {
    final service = ref.read(socketIoServiceProvider);

    for (final machine in machines) {
      final id = int.tryParse(machine.id);
      if (id != null && !_subscribedMachineIds.contains(id)) {
        service.subscribeMachine(id);
        _subscribedMachineIds.add(id);
        print(
          '🔔 Auto-subscribed to new machine: vm-${machine.code} (ID: $id)',
        );
      }
    }
  }

  void _handleSocketEvent(SocketEvent event) {
    switch (event) {
      case TemperatureUpdate(
        :final machineId,
        :final temperature,
        :final humidity,
      ):
        setState(() {
          final existing =
              _machineData[machineId] ??
              MachineRealtimeData(machineId: machineId);
          _machineData[machineId] = MachineRealtimeData(
            machineId: machineId,
            temperature: temperature,
            humidity: humidity,
            status: existing.status,
            lastHeartbeat: existing.lastHeartbeat,
          );
        });
        break;
      case StatusUpdate(:final machineId, :final status):
        setState(() {
          final existing =
              _machineData[machineId] ??
              MachineRealtimeData(machineId: machineId);
          _machineData[machineId] = MachineRealtimeData(
            machineId: machineId,
            temperature: existing.temperature,
            humidity: existing.humidity,
            status: status,
            lastHeartbeat: existing.lastHeartbeat,
          );
        });
        break;
      case Heartbeat(:final machineId, :final machineCode):
        setState(() {
          final existing =
              _machineData[machineId] ??
              MachineRealtimeData(machineId: machineId);
          _machineData[machineId] = MachineRealtimeData(
            machineId: machineId,
            temperature: existing.temperature,
            humidity: existing.humidity,
            status: existing.status,
            lastHeartbeat: DateTime.now(),
            machineCode: machineCode,
          );
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final machinesAsync = ref.watch(machinesProvider);
    final scheme = Theme.of(context).colorScheme;

    // Listen to socket events
    final socketService = ref.watch(socketIoServiceProvider);

    // Subscribe to event stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketService.events.listen(_handleSocketEvent);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Machine Monitor'),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final service = ref.watch(socketIoServiceProvider);
              final isConnected = service.isConnected;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isConnected ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isConnected ? 'Connected' : 'Disconnected',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: machinesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: scheme.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load machines',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  e.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (machines) {
          if (machines.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No machines available',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add machines to start monitoring',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Subscribe to all machines (including new ones)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _subscribeToNewMachines(machines);
          });

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(machinesProvider);
              await ref.read(machinesProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: machines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final machine = machines[index];
                final machineId = int.tryParse(machine.id);
                final realtimeData = machineId != null
                    ? _machineData[machineId]
                    : null;

                return _MachineMonitorCard(
                  machine: machine,
                  realtimeData: realtimeData,
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Cancel polling timer
    _pollTimer?.cancel();

    // Unsubscribe from all machines when screen closes
    final service = ref.read(socketIoServiceProvider);
    for (final machineId in _subscribedMachineIds) {
      service.unsubscribeMachine(machineId);
    }
    _subscribedMachineIds.clear();
    super.dispose();
  }
}

class MachineRealtimeData {
  const MachineRealtimeData({
    required this.machineId,
    this.temperature,
    this.humidity,
    this.status,
    this.lastHeartbeat,
    this.machineCode,
  });

  final int machineId;
  final double? temperature;
  final double? humidity;
  final String? status;
  final DateTime? lastHeartbeat;
  final String? machineCode;

  String get statusDisplay {
    if (status != null && status!.isNotEmpty) return status!;
    if (lastHeartbeat != null) {
      final diff = DateTime.now().difference(lastHeartbeat!);
      if (diff.inSeconds < 30) return 'Online';
      if (diff.inMinutes < 5) return 'Idle';
      return 'Offline';
    }
    return 'Unknown';
  }

  Color statusColor(ColorScheme scheme) {
    final stat = statusDisplay.toLowerCase();
    if (stat.contains('online') || stat.contains('active')) {
      return Colors.green;
    }
    if (stat.contains('idle') || stat.contains('ready')) {
      return Colors.orange;
    }
    if (stat.contains('offline') || stat.contains('error')) {
      return Colors.red;
    }
    return scheme.onSurfaceVariant;
  }
}

class _MachineMonitorCard extends StatelessWidget {
  const _MachineMonitorCard({required this.machine, this.realtimeData});

  final VendingMachine machine;
  final MachineRealtimeData? realtimeData;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasRealtimeData = realtimeData != null;

    return RoundedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Machine name and status
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_drink_outlined,
                  color: scheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      machine.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      machine.code.isNotEmpty
                          ? machine.code
                          : realtimeData?.machineCode ?? 'N/A',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color:
                      (realtimeData?.statusColor(scheme) ??
                              scheme.onSurfaceVariant)
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            realtimeData?.statusColor(scheme) ??
                            scheme.onSurfaceVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      realtimeData?.statusDisplay ??
                          (machine.status.isNotEmpty
                              ? machine.status
                              : 'Unknown'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            realtimeData?.statusColor(scheme) ??
                            scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Location
          if (machine.location.trim().isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    machine.location,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          // Real-time data: Temperature and Humidity
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.thermostat_outlined,
                            size: 16,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Temperature',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (hasRealtimeData && realtimeData!.temperature != null)
                            ? '${realtimeData!.temperature!.toStringAsFixed(1)}°C'
                            : (machine.currentTemperature != null
                                  ? '${machine.currentTemperature!.toStringAsFixed(1)}°C'
                                  : 'N/A'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.water_drop_outlined,
                            size: 16,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Humidity',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        (hasRealtimeData && realtimeData!.humidity != null)
                            ? '${realtimeData!.humidity!.toStringAsFixed(0)}%'
                            : (machine.currentHumidity != null
                                  ? '${machine.currentHumidity!.toStringAsFixed(0)}%'
                                  : 'N/A'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Last heartbeat
          if (realtimeData?.lastHeartbeat != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.favorite_outline,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Last heartbeat: ${_formatTimestamp(realtimeData!.lastHeartbeat!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
