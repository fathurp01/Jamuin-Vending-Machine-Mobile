import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/networking/dio_provider.dart';
import '../data/machines_repository.dart';
import 'machine_models.dart';

final machinesRepositoryProvider = Provider<MachinesRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiMachinesRepository(dio);
});

/// Online machines only (matches backend requirement: machine must be ONLINE).
final machinesProvider = FutureProvider<List<VendingMachine>>((ref) async {
  final repo = ref.read(machinesRepositoryProvider);
  return repo.listOnline();
});
