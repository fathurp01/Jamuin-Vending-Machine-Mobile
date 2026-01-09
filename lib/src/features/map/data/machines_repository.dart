import 'package:dio/dio.dart';

import '../presentation/machine_models.dart';

abstract class MachinesRepository {
  Future<List<VendingMachine>> listAll();
  Future<List<VendingMachine>> listOnline();
  Future<VendingMachine> createMachine(Map<String, dynamic> machineData);
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

    return data
        .whereType<Map>()
        .map((e) => VendingMachine.fromJson(e.cast<String, Object?>()))
        .toList(growable: false);
  }

  @override
  Future<VendingMachine> createMachine(Map<String, dynamic> machineData) async {
    final res = await _dio.post('/machines', data: machineData);
    return VendingMachine.fromJson(res.data as Map<String, dynamic>);
  }
}
