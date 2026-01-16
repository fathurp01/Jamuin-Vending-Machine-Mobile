import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/application/cart_controller.dart';
import '../../session/application/session_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../../map/presentation/machine_providers.dart';
import '../../transactions/application/payments_providers.dart';
import '../../transactions/domain/transaction_record.dart';
import '../domain/payment_flow.dart';

class PlaceOrderResult {
  const PlaceOrderResult._({
    required this.first,
    required this.remaining,
    required this.error,
  });

  final PaymentStep? first;
  final List<PaymentStep> remaining;
  final String? error;

  factory PlaceOrderResult.success({
    required PaymentStep first,
    List<PaymentStep> remaining = const [],
  }) => PlaceOrderResult._(first: first, remaining: remaining, error: null);

  factory PlaceOrderResult.failure(String message) =>
      PlaceOrderResult._(first: null, remaining: const [], error: message);
}

class CheckoutController extends Notifier<String?> {
  @override
  String? build() => null;
      
  Future<PlaceOrderResult> placeOrder() async {
    final cart = ref.read(cartControllerProvider);
    if (cart.subtotal == 0) {
      return PlaceOrderResult.failure('Keranjang masih kosong.');
    }

    final session = ref.read(sessionControllerProvider);
    
    // Check if user is authenticated
    if (!session.isAuthenticated) {
      return PlaceOrderResult.failure(
        'Silakan login terlebih dahulu untuk melakukan transaksi.',
      );
    }
    
    final machineId = session.selectedMachineId;
    final machineName = session.selectedMachineName;

    if (machineId == null || machineName == null) {
      return PlaceOrderResult.failure(
        'Silakan pilih mesin vending terlebih dahulu.',
      );
    }

    final machineIdNum = int.tryParse(machineId);
    if (machineIdNum == null) {
      return PlaceOrderResult.failure('ID mesin vending tidak valid.');
    }

    // Backend requires machine status to be ONLINE. Re-check at checkout time
    // because machine can go offline after user selects it.
    try {
      final onlineMachines = await ref.read(machinesProvider.future);
      final isOnline = onlineMachines.any((m) => m.id == machineId);
      if (!isOnline) {
        return PlaceOrderResult.failure(
          'Mesin $machineName sedang tidak online. Silakan pilih mesin lain.',
        );
      }
    } catch (_) {
      return PlaceOrderResult.failure(
        'Gagal memeriksa status mesin. Coba lagi.',
      );
    }

    try {
      final repo = ref.read(paymentsRepositoryProvider);
      final inventory = ref.read(inventoryControllerProvider.notifier);
      final steps = <PaymentStep>[];
      for (final item in cart.items.values) {
        final productId = int.tryParse(item.product.id);
        if (productId == null) {
          return PlaceOrderResult.failure('ID produk tidak valid.');
        }

        // Check stock dari inventory per-machine
        final stock = inventory.stockFor(
          machineId: machineId,
          productId: item.product.id,
        );
        if (item.quantity > stock) {
          return PlaceOrderResult.failure(
            'Stok tidak mencukupi untuk ${item.product.name}.',
          );
        }

        final created = await repo.create(
          productId: productId,
          quantity: item.quantity,
          machineId: machineIdNum,
        );
        steps.add(
          PaymentStep(orderId: created.orderId, snapUrl: created.snapUrl),
        );

        // Remove successfully-created items to avoid accidental duplicates.
        ref.read(cartControllerProvider.notifier).remove(item.product.id);
      }

      if (steps.isEmpty) {
        return PlaceOrderResult.failure('Keranjang masih kosong.');
      }

      state = steps.first.orderId;
      return PlaceOrderResult.success(
        first: steps.first,
        remaining: steps.skip(1).toList(growable: false),
      );
    } catch (e) {
      return PlaceOrderResult.failure('Gagal membuat pembayaran.');
    }
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, String?>(CheckoutController.new);
