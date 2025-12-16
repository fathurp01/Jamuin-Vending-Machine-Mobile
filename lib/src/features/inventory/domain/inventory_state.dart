class InventoryState {
  const InventoryState({required this.stockByMachine});

  /// machineId -> (productId -> qty)
  final Map<String, Map<String, int>> stockByMachine;

  int stockFor({required String machineId, required String productId}) {
    return stockByMachine[machineId]?[productId] ?? 0;
  }

  InventoryState copyWith({Map<String, Map<String, int>>? stockByMachine}) {
    return InventoryState(
      stockByMachine: stockByMachine ?? this.stockByMachine,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'stockByMachine': stockByMachine.map(
        (machineId, productMap) => MapEntry(
          machineId,
          productMap.map((productId, qty) => MapEntry(productId, qty)),
        ),
      ),
    };
  }

  static InventoryState fromJson(Map<String, Object?> json) {
    final raw = json['stockByMachine'];
    if (raw is! Map) return InventoryDefaults.initial;

    final result = <String, Map<String, int>>{};
    for (final entry in raw.entries) {
      final machineId = entry.key;
      final productRaw = entry.value;
      if (machineId is! String || productRaw is! Map) continue;

      final productMap = <String, int>{};
      for (final pEntry in productRaw.entries) {
        final productId = pEntry.key;
        final qty = pEntry.value;
        if (productId is! String) continue;
        if (qty is int) {
          productMap[productId] = qty;
        } else if (qty is num) {
          productMap[productId] = qty.toInt();
        }
      }
      result[machineId] = productMap;
    }

    return InventoryState(stockByMachine: result);
  }
}

class InventoryDefaults {
  InventoryDefaults._();

  static const initial = InventoryState(
    stockByMachine: {
      'm1': {'latte': 8, 'americano': 12, 'matcha': 5, 'choco': 0},
      'm2': {'latte': 0, 'americano': 10, 'matcha': 2, 'choco': 6},
      'm3': {'latte': 4, 'americano': 0, 'matcha': 8, 'choco': 3},
    },
  );
}
