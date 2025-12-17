import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../core/config/public_apis.dart';
import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';
import '../application/machine_realtime_controller.dart';
import 'machine_models.dart';
import 'machine_providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapLibreMapController? _controller;
  final Map<String, VendingMachine> _symbolToMachine = {};
  bool _symbolsAdded = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _persistSelectedMachine(VendingMachine machine) async {
    ref
        .read(sessionControllerProvider.notifier)
        .selectMachine(id: machine.id, name: machine.name);

    final repo = ref.read(sessionRepositoryProvider);
    await repo.write(ref.read(sessionControllerProvider));

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Terpilih: ${machine.name}')));
  }

  void _onSymbolTapped(Symbol symbol) {
    final machine = _symbolToMachine[symbol.id];
    if (machine == null) return;
    _persistSelectedMachine(machine);
  }

  Future<void> _addMachineSymbols(List<VendingMachine> machines) async {
    final controller = _controller;
    if (controller == null) return;
    if (_symbolsAdded) return;
    _symbolsAdded = true;

    // Add a symbol per machine and keep a lookup for tap handling.
    for (final m in machines.where((m) => m.hasCoordinates)) {
      final symbol = await controller.addSymbol(
        SymbolOptions(
          geometry: LatLng(m.lat!, m.lng!),
          iconImage: 'marker-15',
          iconSize: 1.3,
          textField: m.name,
          textOffset: const Offset(0, 1.2),
          textSize: 12.0,
        ),
      );
      _symbolToMachine[symbol.id] = m;
    }
  }

  @override
  Widget build(BuildContext context) {
    final storageAsync = ref.watch(localStorageProvider);
    return storageAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Machines')),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, __) => Scaffold(
        appBar: AppBar(title: const Text('Machines')),
        body: Center(child: Text('Failed to initialize storage: $e')),
      ),
      data: (_) {
        final machinesAsync = ref.watch(machinesProvider);
        final scheme = Theme.of(context).colorScheme;
        final session = ref.watch(sessionControllerProvider);

        return machinesAsync.when(
          loading: () => Scaffold(
            appBar: AppBar(title: const Text('Pilih mesin')),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, __) => Scaffold(
            appBar: AppBar(title: const Text('Pilih mesin')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Gagal memuat daftar mesin.\n$e',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          data: (machines) {
            final realtime = ref.watch(machineRealtimeProvider);

            Widget machineListFallback({String? header}) {
              return Scaffold(
                appBar: AppBar(title: const Text('Pilih mesin')),
                body: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: machines.length + (header == null ? 0 : 1),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (header != null) {
                      if (index == 0) {
                        return Text(
                          header,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        );
                      }
                      index -= 1;
                    }

                    final m = machines[index];
                    final numericId = int.tryParse(m.id);
                    final live = numericId == null ? null : realtime[numericId];
                    final liveBits = <String>[];
                    if ((m.status).trim().isNotEmpty) {
                      liveBits.add('Status: ${m.status}');
                    } else if ((live?.status ?? '').trim().isNotEmpty) {
                      liveBits.add('Status: ${live!.status}');
                    }

                    if (live?.temperature != null) {
                      liveBits.add(
                        'Temp: ${live!.temperature!.toStringAsFixed(1)}°C',
                      );
                    }
                    if (live?.humidity != null) {
                      liveBits.add(
                        'RH: ${live!.humidity!.toStringAsFixed(0)}%',
                      );
                    }

                    return ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      tileColor: scheme.surfaceContainerHighest,
                      title: Text(
                        m.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: Text(
                        [
                          m.location,
                          if (liveBits.isNotEmpty) liveBits.join(' • '),
                        ].where((e) => e.trim().isNotEmpty).join('\n'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _persistSelectedMachine(m),
                    );
                  },
                ),
              );
            }

            if (machines.isEmpty) {
              return machineListFallback(header: 'Belum ada mesin online.');
            }

            final machinesWithCoordinates = machines
                .where((m) => m.hasCoordinates)
                .toList(growable: false);
            if (machinesWithCoordinates.isEmpty) {
              // Backend does not provide coordinates, so we fall back to a simple list.
              return machineListFallback(
                header: 'Pilih mesin online yang tersedia.',
              );
            }

            final initial = LatLng(
              machinesWithCoordinates.first.lat!,
              machinesWithCoordinates.first.lng!,
            );

            return Scaffold(
              appBar: AppBar(title: const Text('Pilih mesin')),
              body: Stack(
                children: [
                  MapLibreMap(
                    styleString: PublicApis.maptilerStreetsV4StyleUrl,
                    initialCameraPosition: CameraPosition(
                      target: initial,
                      zoom: 13.2,
                    ),
                    onMapCreated: (c) {
                      _controller = c;
                      c.onSymbolTapped.add(_onSymbolTapped);
                    },
                    onStyleLoadedCallback: () =>
                        _addMachineSymbols(machinesWithCoordinates),
                    myLocationEnabled: false,
                    myLocationTrackingMode: MyLocationTrackingMode.none,
                    compassEnabled: false,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: false,
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Material(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.store_mall_directory_outlined),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                session.selectedMachineName ??
                                    'Pilih mesin dari daftar',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
