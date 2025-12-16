import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/platform/app_config.dart';
import '../../session/application/session_controller.dart';
import 'machine_providers.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final machines = ref.watch(machinesProvider);
    final scheme = Theme.of(context).colorScheme;

    Widget machineListFallback({String? header}) {
      return Scaffold(
        appBar: AppBar(title: const Text('Machines')),
        body: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: machines.length + (header == null ? 0 : 1),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (header != null) {
              if (index == 0) {
                return Text(
                  header,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                );
              }
              index -= 1;
            }

            final m = machines[index];
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
                'Lat ${m.lat}, Lng ${m.lng}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ref
                    .read(sessionControllerProvider.notifier)
                    .selectMachine(m.name);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Selected: ${m.name}')));
              },
            );
          },
        ),
      );
    }

    // google_maps_flutter does not support all platforms equally.
    if (kIsWeb) {
      return machineListFallback();
    }

    final markers = machines
        .map(
          (m) => Marker(
            markerId: MarkerId(m.id),
            position: LatLng(m.lat, m.lng),
            infoWindow: InfoWindow(
              title: m.name,
              onTap: () {
                ref
                    .read(sessionControllerProvider.notifier)
                    .selectMachine(m.name);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Selected: ${m.name}')));
              },
            ),
          ),
        )
        .toSet();

    final initial = machines.isNotEmpty
        ? LatLng(machines.first.lat, machines.first.lng)
        : const LatLng(-6.2, 106.8);

    // On Android, missing/empty API key can hard-crash the native map view.
    // Guard it and show a fallback list instead.
    if (defaultTargetPlatform == TargetPlatform.android) {
      return FutureBuilder<String?>(
        future: AppConfig.getAndroidMapsApiKey(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              appBar: AppBar(title: Text('Machines')),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final key = (snapshot.data ?? '').trim();
          if (key.isEmpty) {
            return machineListFallback(
              header:
                  'Map is unavailable (missing Google Maps API key).\nSet MAPS_API_KEY in android/gradle.properties.',
            );
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Machines')),
            body: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: initial,
                zoom: 13.2,
              ),
              onMapCreated: (c) => _controller = c,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: markers,
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Machines')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: initial, zoom: 13.2),
        onMapCreated: (c) => _controller = c,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        markers: markers,
      ),
    );
  }
}
