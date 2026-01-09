import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../../core/config/public_apis.dart';
import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';
import '../application/machine_realtime_controller.dart';
import 'machine_card_overlay.dart';
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
  final Map<String, Circle> _machineIdToCoreDot = {};
  final Map<String, Circle> _machineIdToInnerDot = {};
  bool _dotsAdded = false;

  // NOTE: Named this way to avoid hot-reload type conflicts from older builds
  // where `_cameraTick` might have been a different type.
  ValueNotifier<int>? _cameraTickNotifier;
  Timer? _cameraTickDebounce;

  VendingMachine? _previewMachine;

  StreamSubscription<Position>? _positionSub;
  LatLng? _myLatLng;
  Circle? _myPulseCircle;
  Circle? _myCoreCircle;
  Circle? _myInnerCircle;
  Timer? _pulseTimer;
  DateTime? _pulseStart;
  bool _didShowLocationHint = false;
  bool _didAutoPinpoint = false;

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

  Future<void> _recenterToMyLocation() async {
    final controller = _controller;
    if (controller == null) return;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GPS tidak aktif. Aktifkan lokasi dulu.'),
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak. Izinkan lokasi untuk pinpoint.',
            ),
          ),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final ll = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _myLatLng = ll;
        });
      }

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: ll, zoom: 16.0)),
      );

      // Ensure the pulsing dot becomes visible immediately and keeps updating.
      await _upsertMyLocationCircles();
      _startLocationStreamIfPossible();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal ambil lokasi: $e')));
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted && !_didShowLocationHint) {
        _didShowLocationHint = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'GPS tidak aktif. Aktifkan lokasi untuk melihat dot.',
            ),
          ),
        );
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final ok =
        permission != LocationPermission.denied &&
        permission != LocationPermission.deniedForever;
    if (!ok && mounted && !_didShowLocationHint) {
      _didShowLocationHint = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Izin lokasi belum diberikan. Izinkan untuk melihat dot.',
          ),
        ),
      );
    }
    return ok;
  }

  String _colorToHexRgb(Color c) {
    final rgb = (c.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0');
    return '#$rgb';
  }

  Future<void> _upsertMyLocationCircles() async {
    final controller = _controller;
    final ll = _myLatLng;
    if (controller == null || ll == null || !mounted) return;

    final scheme = Theme.of(context).colorScheme;
    final primaryHex = _colorToHexRgb(scheme.primary);
    final surfaceHex = _colorToHexRgb(scheme.surface);

    try {
      _myPulseCircle ??= await controller.addCircle(
        CircleOptions(
          geometry: ll,
          circleRadius: 16.0,
          circleColor: primaryHex,
          circleOpacity: 0.0,
        ),
      );
      _myCoreCircle ??= await controller.addCircle(
        CircleOptions(
          geometry: ll,
          circleRadius: 6.0,
          circleColor: primaryHex,
          circleOpacity: 1.0,
        ),
      );
      _myInnerCircle ??= await controller.addCircle(
        CircleOptions(
          geometry: ll,
          circleRadius: 3.2,
          circleColor: surfaceHex,
          circleOpacity: 1.0,
        ),
      );

      await controller.updateCircle(
        _myPulseCircle!,
        CircleOptions(geometry: ll),
      );
      await controller.updateCircle(
        _myCoreCircle!,
        CircleOptions(geometry: ll),
      );
      await controller.updateCircle(
        _myInnerCircle!,
        CircleOptions(geometry: ll),
      );

      _startPulseAnimation();
    } catch (_) {
      // Ignore (style may not be ready yet)
    }
  }

  void _startPulseAnimation() {
    if (_pulseTimer != null) return;
    _pulseStart ??= DateTime.now();
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 50), (_) async {
      final controller = _controller;
      final ll = _myLatLng;
      final pulse = _myPulseCircle;
      if (controller == null || ll == null || pulse == null || !mounted) {
        return;
      }

      final scheme = Theme.of(context).colorScheme;
      final primaryHex = _colorToHexRgb(scheme.primary);

      final elapsed = DateTime.now().difference(_pulseStart!).inMilliseconds;
      final t = (elapsed % 1100) / 1100.0;
      final radius = 10.0 + (22.0 * t);
      final opacity = (1.0 - t).clamp(0.0, 1.0) * 0.22;

      try {
        await controller.updateCircle(
          pulse,
          CircleOptions(
            geometry: ll,
            circleRadius: radius,
            circleColor: primaryHex,
            circleOpacity: opacity,
          ),
        );
      } catch (_) {
        // ignore
      }
    });
  }

  Future<void> _autoPinpointIfNeeded() async {
    if (_didAutoPinpoint) return;
    final controller = _controller;
    final ll = _myLatLng;
    if (controller == null || ll == null) return;

    _didAutoPinpoint = true;
    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: ll, zoom: 16.0)),
      );
    } catch (_) {
      // If the camera isn't ready yet, allow a later retry.
      _didAutoPinpoint = false;
    }
  }

  Future<void> _startLocationStreamIfPossible() async {
    final ok = await _ensureLocationPermission();
    if (!ok) return;

    // Prime once so dot can show immediately (stream may take a moment).
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final ll = LatLng(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _myLatLng = ll;
        });
      }
      await _autoPinpointIfNeeded();
      await _upsertMyLocationCircles();
    } catch (_) {
      // Ignore
    }

    _positionSub?.cancel();
    _positionSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 2,
          ),
        ).listen((pos) {
          final ll = LatLng(pos.latitude, pos.longitude);
          if (!mounted) return;
          setState(() {
            _myLatLng = ll;
          });
          _autoPinpointIfNeeded();
          _upsertMyLocationCircles();
        });
  }

  @override
  void initState() {
    super.initState();
    // Start listening early; if permission isn't granted yet, this will just no-op.
    _startLocationStreamIfPossible();
    _cameraTickNotifier ??= ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _pulseTimer?.cancel();
    _cameraTickDebounce?.cancel();
    _cameraTickNotifier?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  ValueNotifier<int> get _cameraTick =>
      _cameraTickNotifier ??= ValueNotifier<int>(0);

  void _scheduleCameraTick() {
    // Camera move can fire frequently; throttle screen-position updates.
    _cameraTickDebounce?.cancel();
    _cameraTickDebounce = Timer(const Duration(milliseconds: 16), () {
      _cameraTick.value = _cameraTick.value + 1;
    });
  }

  void _bumpCameraTickNow() {
    _cameraTickDebounce?.cancel();
    _cameraTick.value = _cameraTick.value + 1;
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
    }

    // Always go back to products page after selection (from any source)
    // This ensures user sees products with selected machine
    context.go('/app/products');

    // Show snackbar to confirm selection
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terpilih: ${machine.name}')));
    }
  }

  Future<void> _selectMachinePreview(
    VendingMachine machine, {
    bool centerMap = true,
  }) async {
    final previous = _previewMachine?.id;

    if (mounted) {
      setState(() {
        _previewMachine = machine;
      });
    }

    // Ensure the panel is visible so the user can confirm selection.
    if (_isPanelHidden) {
      final screenHeight = MediaQuery.sizeOf(context).height;
      final minSheetHeight = (screenHeight * 0.25).clamp(220.0, 340.0);
      _snapShow(minSheetHeight);
    }

    await _applySelectionVisuals(previousId: previous, currentId: machine.id);

    final controller = _controller;
    if (controller != null && centerMap && machine.hasCoordinates) {
      try {
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(machine.lat!, machine.lng!),
              zoom: 16.0,
            ),
          ),
        );
      } catch (_) {
        // ignore
      }
    }
  }

  Future<void> _applySelectionVisuals({
    required String? previousId,
    required String? currentId,
  }) async {
    // Selection is now handled by card re-renders in the Stack overlay.
    // No need to update circle/symbol properties here.
  }

  Future<void> _addMachineDots(List<VendingMachine> machines) async {
    final controller = _controller;
    if (controller == null) return;
    if (_dotsAdded) return;
    _dotsAdded = true;

    final scheme = Theme.of(context).colorScheme;
    final primaryHex = _colorToHexRgb(scheme.primary);
    // We intentionally render a hollow ring (transparent center) to match UX.
    // Using stroke avoids faking a hole with a solid inner color.

    // Add visible machine dots (stick to map like my-location dot).
    for (final m in machines.where((m) => m.hasCoordinates)) {
      final ll = LatLng(m.lat!, m.lng!);

      final core = await controller.addCircle(
        CircleOptions(
          geometry: ll,
          circleRadius: 6.0,
          // Transparent center (hollow)
          circleColor: primaryHex,
          circleOpacity: 0.0,
          circleStrokeColor: primaryHex,
          circleStrokeOpacity: 1.0,
          circleStrokeWidth: 2.25,
        ),
      );
      _machineIdToCoreDot[m.id] = core;
    }
  }

  Future<void> _handleStyleLoaded(List<VendingMachine> machines) async {
    // MapLibre clears annotations when style is (re)loaded.
    // Reset our state so dots/circles are re-created.
    _machineIdToCoreDot.clear();
    _machineIdToInnerDot.clear();
    _dotsAdded = false;
    _myPulseCircle = null;
    _myCoreCircle = null;
    _myInnerCircle = null;

    await _addMachineDots(machines);
    await _upsertMyLocationCircles();
    _bumpCameraTickNow();
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

            // Recenter button sits above the panel and follows its position.
            final recenterBottom = (_isPanelHidden ? 24.0 : panelHeight + 16.0);

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
                      setState(() {
                        _controller = c;
                      });
                      _startLocationStreamIfPossible();
                      _upsertMyLocationCircles();
                      _autoPinpointIfNeeded();
                    },
                    onStyleLoadedCallback: () {
                      _handleStyleLoaded(machinesWithCoordinates);
                    },
                    onCameraMove: (_) => _scheduleCameraTick(),
                    onCameraIdle: _bumpCameraTickNow,
                    onMapClick: (_, latLng) {
                      // Fallback selection: if user taps near a machine dot, select it.
                      if (machinesWithCoordinates.isEmpty) return;
                      VendingMachine? nearest;
                      double bestMeters = double.infinity;

                      for (final m in machinesWithCoordinates) {
                        final meters = Geolocator.distanceBetween(
                          latLng.latitude,
                          latLng.longitude,
                          m.lat!,
                          m.lng!,
                        );
                        if (meters < bestMeters) {
                          bestMeters = meters;
                          nearest = m;
                        }
                      }

                      // Threshold so random taps don't select a machine.
                      if (nearest != null && bestMeters <= 60) {
                        _selectMachinePreview(nearest);
                      }
                    },
                    // We render our own pulsing dot to match app theme.
                    myLocationEnabled: false,
                    myLocationTrackingMode: MyLocationTrackingMode.none,
                    compassEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: false,
                  ),

                  // Machine overlay cards above the map, but behind the bottom panel.
                  ...machinesWithCoordinates.map((machine) {
                    return MachineCardOverlay(
                      key: ValueKey(machine.id),
                      machine: machine,
                      controller: _controller,
                      cameraTickListenable: _cameraTick,
                      isSelected: _previewMachine?.id == machine.id,
                      onTap: () =>
                          _selectMachinePreview(machine, centerMap: false),
                    );
                  }),

                  // Pinpoint/recenter button (top-right of map area, above the bottom panel)
                  Positioned(
                    right: 16,
                    bottom: recenterBottom,
                    child: FloatingActionButton.small(
                      heroTag: 'recenter_location',
                      onPressed: _recenterToMyLocation,
                      backgroundColor: scheme.surfaceContainerHighest,
                      foregroundColor: scheme.primary,
                      child: const Icon(Icons.my_location),
                    ),
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
                                final isSelected = _previewMachine?.id == m.id;
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
                                  onTap: () => _selectMachinePreview(m),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      // Selected row becomes grey (abu) to indicate preview.
                                      color: isSelected
                                          ? scheme.surfaceVariant
                                          : scheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? scheme.onSurface.withValues(
                                                    alpha: 0.08,
                                                  )
                                                : scheme.primary.withValues(
                                                    alpha: 0.12,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.store,
                                            color: isSelected
                                                ? scheme.onSurfaceVariant
                                                : scheme.primary,
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

                  // Bottom action bar when machine is selected
                  if (_previewMachine != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      // Overlay in front of the bottom panel, fixed to the bottom of screen.
                      bottom: 0,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _persistSelectedMachine(_previewMachine!),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    backgroundColor: scheme.primaryContainer,
                                    foregroundColor: scheme.onPrimaryContainer,
                                  ),
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    size: 20,
                                  ),
                                  label: const Text('Pilih mesin'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  if (mounted) {
                                    setState(() {
                                      _previewMachine = null;
                                    });
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                    horizontal: 20,
                                  ),
                                ),
                                icon: const Icon(Icons.close, size: 19),
                                label: const Text('Batal'),
                              ),
                            ],
                          ),
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
