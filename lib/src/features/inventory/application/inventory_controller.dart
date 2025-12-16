import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/application/session_controller.dart';
import '../../session/application/session_persistence_providers.dart';
import '../data/inventory_repository.dart';
import '../domain/inventory_state.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final storage = ref.watch(localStorageProvider).requireValue;
  return LocalInventoryRepository(storage);
});

class InventoryController extends Notifier<InventoryState> {
  @override
  InventoryState build() {
    unawaited(_load());
    return InventoryDefaults.initial;
  }

  Future<void> _load() async {
    final repo = ref.read(inventoryRepositoryProvider);
    final stored = await repo.read();
    if (stored == null) return;
    state = stored;
  }

  int stockFor({required String machineId, required String productId}) {
    return state.stockFor(machineId: machineId, productId: productId);
  }

  Future<void> setStock({
    required String machineId,
    required String productId,
    required int stock,
  }) async {
    final next = <String, Map<String, int>>{};
    for (final entry in state.stockByMachine.entries) {
      next[entry.key] = Map<String, int>.from(entry.value);
    }

    final productMap = next[machineId] ?? <String, int>{};
    productMap[productId] = stock < 0 ? 0 : stock;
    next[machineId] = productMap;

    state = state.copyWith(stockByMachine: next);
    await ref.read(inventoryRepositoryProvider).write(state);
  }

  Future<void> addStock({
    required String machineId,
    required String productId,
    required int delta,
  }) async {
    final current = stockFor(machineId: machineId, productId: productId);
    await setStock(
      machineId: machineId,
      productId: productId,
      stock: current + delta,
    );
  }

  Future<bool> consumeStock({
    required String machineId,
    required Map<String, int> productQuantities,
  }) async {
    // Validate.
    for (final entry in productQuantities.entries) {
      final need = entry.value;
      if (need <= 0) continue;
      final available = stockFor(machineId: machineId, productId: entry.key);
      if (available < need) return false;
    }

    final next = <String, Map<String, int>>{};
    for (final entry in state.stockByMachine.entries) {
      next[entry.key] = Map<String, int>.from(entry.value);
    }

    final machineMap = next[machineId] ?? <String, int>{};
    for (final entry in productQuantities.entries) {
      final need = entry.value;
      if (need <= 0) continue;
      final available = machineMap[entry.key] ?? 0;
      machineMap[entry.key] = (available - need).clamp(0, 1 << 30);
    }
    next[machineId] = machineMap;

    state = state.copyWith(stockByMachine: next);
    await ref.read(inventoryRepositoryProvider).write(state);
    return true;
  }

  Future<void> resetToDefaults() async {
    state = InventoryDefaults.initial;
    await ref.read(inventoryRepositoryProvider).write(state);
  }
}

final inventoryControllerProvider =
    NotifierProvider<InventoryController, InventoryState>(
      InventoryController.new,
    );

final stockForSelectedMachineProvider = Provider.family<int, String>((
  ref,
  productId,
) {
  final session = ref.watch(sessionControllerProvider);
  final machineId = session.selectedMachineId;
  if (machineId == null) return 0;

  final inventory = ref.watch(inventoryControllerProvider);
  return inventory.stockFor(machineId: machineId, productId: productId);
});
