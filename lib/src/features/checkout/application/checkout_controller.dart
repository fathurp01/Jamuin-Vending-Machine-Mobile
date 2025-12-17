import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/application/cart_controller.dart';
import '../../session/application/session_controller.dart';
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

  Future<PlaceOrderResult> placeOrder({required CustomerInfo customer}) async {
    final cart = ref.read(cartControllerProvider);
    if (cart.subtotal == 0) {
      return PlaceOrderResult.failure('Keranjang masih kosong.');
    }

    final session = ref.read(sessionControllerProvider);
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

    try {
      final repo = ref.read(paymentsRepositoryProvider);
      final steps = <PaymentStep>[];
      for (final item in cart.items.values) {
        final productId = int.tryParse(item.product.id);
        if (productId == null) {
          return PlaceOrderResult.failure('ID produk tidak valid.');
        }
        if (item.quantity > item.product.stock) {
          return PlaceOrderResult.failure(
            'Stok tidak mencukupi untuk produk ini.',
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
