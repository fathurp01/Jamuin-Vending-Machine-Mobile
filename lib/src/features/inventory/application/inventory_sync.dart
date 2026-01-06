import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../products/data/product_repository.dart';
import 'inventory_controller.dart';

/// Syncs inventory stock from backend for a specific machine
Future<void> syncInventoryForMachine(
  WidgetRef ref, {
  required String machineId,
}) async {
  try {
    // Fetch products with machine-specific stock from backend
    final products = await ref
        .read(productRepositoryProvider)
        .listByMachine(machineId);

    final inventory = ref.read(inventoryControllerProvider.notifier);

    // Update inventory with stock from backend
    for (final product in products) {
      await inventory.setStock(
        machineId: machineId,
        productId: product.id,
        stock: product.stock, // This will be from the machineProducts relation
      );
    }
  } catch (e) {
    // Silently fail - inventory will use default values
    return;
  }
}

/// Syncs inventory stock from product's machineProducts array
Future<void> syncInventoryFromProducts(
  WidgetRef ref, {
  required List<dynamic> products,
}) async {
  final inventory = ref.read(inventoryControllerProvider.notifier);

  for (final product in products) {
    if (product == null) continue;

    // Parse machineProducts if present
    final machineProducts = product.machineProducts;
    if (machineProducts == null || machineProducts.isEmpty) continue;

    // Update inventory for each machine
    for (final mp in machineProducts) {
      await inventory.setStock(
        machineId: mp.machineId.toString(),
        productId: mp.productId.toString(),
        stock: mp.stok,
      );
    }
  }
}
