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
    return data
        .whereType<Map>()
        .map((e) => VendingMachine.fromJson(e.cast<String, Object?>()))
        .toList(growable: false);
  }
}
