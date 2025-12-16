import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/application/cart_controller.dart';
import '../../inventory/application/inventory_controller.dart';
import '../../session/application/session_controller.dart';
import '../../transactions/application/transaction_history_controller.dart';
import '../../transactions/domain/transaction_record.dart';

class PlaceOrderResult {
  const PlaceOrderResult._({required this.id, required this.error});

  final String? id;
  final String? error;

  factory PlaceOrderResult.success(String id) =>
      PlaceOrderResult._(id: id, error: null);

  factory PlaceOrderResult.failure(String message) =>
      PlaceOrderResult._(id: null, error: message);
}

class CheckoutController extends Notifier<String?> {
  @override
  String? build() => null;

  Future<PlaceOrderResult> placeOrder({required CustomerInfo customer}) async {
    final cart = ref.read(cartControllerProvider);
    if (cart.subtotal == 0) {
      return PlaceOrderResult.failure('Cart is empty.');
    }

    final session = ref.read(sessionControllerProvider);
    final machineId = session.selectedMachineId;
    final machineName = session.selectedMachineName;

    if (machineId == null || machineName == null) {
      return PlaceOrderResult.failure('Please select a vending machine first.');
    }

    final productQuantities = <String, int>{
      for (final it in cart.items.values) it.product.id: it.quantity,
    };

    final inventory = ref.read(inventoryControllerProvider.notifier);
    final ok = await inventory.consumeStock(
      machineId: machineId,
      productQuantities: productQuantities,
    );

    if (!ok) {
      return PlaceOrderResult.failure(
        'Some items are out of stock for the selected machine.',
      );
    }

    final id = _newId();
    final record = TransactionRecord(
      id: id,
      createdAt: DateTime.now(),
      machineId: machineId,
      machineName: machineName,
      status: TransactionStatus.pending,
      items: cart.items.values
          .map(
            (it) => TransactionLineItem(
              productId: it.product.id,
              productName: it.product.name,
              unitPrice: it.product.price,
              quantity: it.quantity,
            ),
          )
          .toList(growable: false),
      subtotal: cart.subtotal,
      serviceFee: cart.serviceFee,
      tax: cart.tax,
      total: cart.total,
      customer: customer,
    );

    await ref
        .read(transactionHistoryControllerProvider.notifier)
        .upsert(record);
    state = id;

    ref.read(cartControllerProvider.notifier).clear();

    // Simulate payment completion.
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final isFailed = Random().nextInt(10) == 0; // ~10% fail
    if (isFailed) {
      await ref
          .read(transactionHistoryControllerProvider.notifier)
          .updateStatus(id, TransactionStatus.failed);

      // Rollback stock on failure.
      for (final entry in productQuantities.entries) {
        await inventory.addStock(
          machineId: machineId,
          productId: entry.key,
          delta: entry.value,
        );
      }

      return PlaceOrderResult.success(id);
    }

    await ref
        .read(transactionHistoryControllerProvider.notifier)
        .updateStatus(id, TransactionStatus.paid);

    return PlaceOrderResult.success(id);
  }

  static String _newId() {
    final r = Random();
    final n = 100000 + r.nextInt(900000);
    return 'TX$n';
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, String?>(CheckoutController.new);
