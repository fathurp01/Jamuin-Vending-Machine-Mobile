import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../core/config/public_apis.dart';
import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';
import '../application/machine_realtime_controller.dart';
import 'machine_models.dart';
import 'machine_providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  /// Navigation mode after machine selection:
  /// - 'cart': navigates back to cart
  /// - 'products': navigates to products with selected machine
  /// - null: just shows snackbar and stays on map
  final String? navigateTo;

  const MapScreen({super.key, this.navigateTo});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  MapLibreMapController? _controller;
  final Map<String, VendingMachine> _symbolToMachine = {};
  bool _symbolsAdded = false;

  // Panel height: minHeight to maxHeight range
  double? _currentPanelHeight;
  bool _isDraggingPanel = false;
  bool _isPanelHidden = false;

  void _snapToMin(double minHeight) {
    setState(() {
      _currentPanelHeight = minHeight;
      _isDraggingPanel = false;
      _isPanelHidden = false;
    });
  }

  void _snapToMax(double maxHeight) {
    setState(() {
      _currentPanelHeight = maxHeight;
      _isDraggingPanel = false;
      _isPanelHidden = false;
    });
  }

  void _snapHide(double minHeight) {
    setState(() {
      _currentPanelHeight = minHeight;
      _isDraggingPanel = false;
      _isPanelHidden = true;
    });
  }

  void _snapShow(double minHeight) {
    setState(() {
      _currentPanelHeight = minHeight;
      _isDraggingPanel = false;
      _isPanelHidden = false;
    });
  }

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

    // Handle navigation based on mode
    if (widget.navigateTo == 'cart') {
      // User came from cart, return to cart
      context.pop();
      return;
    } else if (widget.navigateTo == 'products') {
      // User selected machine first, go to products
      context.go('/app/products');
      return;
    }

    // Default: just show snackbar
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

            final screenHeight = MediaQuery.sizeOf(context).height;
            final minSheetHeight = (screenHeight * 0.25).clamp(220.0, 340.0);
            final maxSheetHeight = (screenHeight * 0.50).clamp(
              350.0,
              screenHeight - 120,
            );

            // Initialize panel height on first build
            _currentPanelHeight ??= minSheetHeight;

            // Allow height to go below minSheetHeight while dragging down (so it can be held
            // and visually collapsed). Snap logic will decide whether to hide or return to min.
            final panelHeight = _currentPanelHeight!.clamp(0.0, maxSheetHeight);

            return Scaffold(
              appBar: AppBar(title: const Text('Pilih mesin')),
              body: Stack(
                children: [
                  // Full map occupies entire screen
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
                    myLocationEnabled: true,
                    myLocationTrackingMode: MyLocationTrackingMode.none,
                    compassEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: false,
                  ),

                  // Machine list at bottom (expandable/collapsible)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: _isDraggingPanel
                          ? Duration.zero
                          : const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _isPanelHidden ? 0 : panelHeight,
                      decoration: BoxDecoration(
                        color: scheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Drag area (handle + header) so it's easy to drag.
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragStart: (_) {
                              setState(() => _isDraggingPanel = true);
                            },
                            onVerticalDragUpdate: (details) {
                              // Negative dy = drag up (expand), positive dy = drag down (shrink)
                              setState(() {
                                final newHeight =
                                    _currentPanelHeight! - details.delta.dy;
                                _currentPanelHeight = newHeight.clamp(
                                  0.0,
                                  maxSheetHeight,
                                );
                              });
                            },
                            onVerticalDragEnd: (details) {
                              final velocityY =
                                  details.velocity.pixelsPerSecond.dy;
                              final currentHeight = _currentPanelHeight!;
                              final midHeight =
                                  (minSheetHeight + maxSheetHeight) / 2;

                              // Fast swipe down -> hide
                              if (velocityY > 700) {
                                _snapHide(minSheetHeight);
                              }
                              // Fast swipe up -> expand to max
                              else if (velocityY < -700) {
                                _snapToMax(maxSheetHeight);
                              }
                              // If dragged close to hidden, hide. Otherwise snap to min/max.
                              else if (currentHeight < minSheetHeight * 0.7) {
                                _snapHide(minSheetHeight);
                              } else if (currentHeight < midHeight) {
                                _snapToMin(minSheetHeight);
                              } else {
                                _snapToMax(maxSheetHeight);
                              }
                            },
                            onVerticalDragCancel: () {
                              _snapToMin(minSheetHeight);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 40,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: scheme.onSurfaceVariant
                                              .withValues(alpha: 0.4),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.store_mall_directory_outlined,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Mesin Terdekat',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 0),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: machines.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final m = machines[index];
                                final numericId = int.tryParse(m.id);
                                final live = numericId == null
                                    ? null
                                    : realtime[numericId];
                                final liveBits = <String>[];

                                if ((m.status).trim().isNotEmpty) {
                                  liveBits.add('Status: ${m.status}');
                                } else if ((live?.status ?? '')
                                    .trim()
                                    .isNotEmpty) {
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

                                return InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => _persistSelectedMachine(m),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: scheme.primary.withValues(
                                              alpha: 0.12,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.store,
                                            color: scheme.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                m.name,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              if (m.location.trim().isNotEmpty)
                                                Text(
                                                  m.location,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: scheme
                                                            .onSurfaceVariant,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              if (liveBits.isNotEmpty)
                                                Text(
                                                  liveBits.join(' • '),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: scheme
                                                            .onSurfaceVariant,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Floating button to toggle list when hidden
                  if (_isPanelHidden)
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            // Drag up on FAB also shows the panel
                            if (details.delta.dy < -5) {
                              _snapShow(minSheetHeight);
                            }
                          },
                          child: FloatingActionButton(
                            onPressed: () => _snapShow(minSheetHeight),
                            backgroundColor: scheme.surfaceContainerHighest,
                            foregroundColor: scheme.primary,
                            child: const Icon(Icons.keyboard_arrow_up),
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
