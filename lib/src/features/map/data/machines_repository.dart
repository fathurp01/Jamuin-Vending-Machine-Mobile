import 'package:dio/dio.dart';

import '../presentation/machine_models.dart';

abstract class MachinesRepository {
  Future<List<VendingMachine>> listAll();
  Future<List<VendingMachine>> listOnline();
}

final class ApiMachinesRepository implements MachinesRepository {
  ApiMachinesRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<VendingMachine>> listAll() async {
    final res = await _dio.get<List<dynamic>>('/machines');
    final data = res.data ?? const [];
    return data
        .whereType<Map>()
        .map((e) => VendingMachine.fromJson(e.cast<String, Object?>()))
        .toList(growable: false);
  }

  @override
  Future<List<VendingMachine>> listOnline() async {
    final res = await _dio.get<List<dynamic>>('/machines/online');
    final data = res.data ?? const [];

    final machines = data
        .whereType<Map>()
        .map((e) => VendingMachine.fromJson(e.cast<String, Object?>()))
        .toList();

    // TEMPORARY: Add dummy coordinates for testing if backend doesn't provide them
    // Remove this once backend provides real lat/lng
    final machinesWithCoords = <VendingMachine>[];
    final baseLatLng = [
      [-6.2088, 106.8456], // Jakarta area
      [-6.2118, 106.8476],
      [-6.2078, 106.8436],
      [-6.2098, 106.8466],
      [-6.2108, 106.8446],
    ];

    for (var i = 0; i < machines.length; i++) {
      final machine = machines[i];
      if (machine.hasCoordinates) {
        machinesWithCoords.add(machine);
      } else {
        // Add dummy coordinates based on index
        final coords = baseLatLng[i % baseLatLng.length];
        final offset = i ~/ baseLatLng.length;
        machinesWithCoords.add(
          VendingMachine(
            id: machine.id,
            code: machine.code,
            name: machine.name,
            location: machine.location,
            status: machine.status,
            currentTemperature: machine.currentTemperature,
            currentHumidity: machine.currentHumidity,
            lastOnline: machine.lastOnline,
            lat: coords[0] + (offset * 0.001),
            lng: coords[1] + (offset * 0.001),
          ),
        );
      }
    }

    return machinesWithCoords;
  }
}
