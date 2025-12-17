import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/application/cart_controller.dart';
import '../../session/application/session_controller.dart';
import '../../transactions/application/payments_providers.dart';
import '../../transactions/domain/transaction_record.dart';

class PlaceOrderResult {
  const PlaceOrderResult._({
    required this.orderId,
    required this.snapUrl,
    required this.error,
  });

  final String? orderId;
  final String? snapUrl;
  final String? error;

  factory PlaceOrderResult.success({
    required String orderId,
    required String snapUrl,
  }) => PlaceOrderResult._(orderId: orderId, snapUrl: snapUrl, error: null);

  factory PlaceOrderResult.failure(String message) =>
      PlaceOrderResult._(orderId: null, snapUrl: null, error: message);
}

class CheckoutController extends Notifier<String?> {
  @override
  String? build() => null;

  Future<PlaceOrderResult> placeOrder({required CustomerInfo customer}) async {
    final cart = ref.read(cartControllerProvider);
    if (cart.subtotal == 0) {
      return PlaceOrderResult.failure('Cart is empty.');
    }

    if (cart.items.length != 1) {
      return PlaceOrderResult.failure(
        'Backend checkout currently supports 1 product per transaction. Please adjust your cart.',
      );
    }

    final session = ref.read(sessionControllerProvider);
    final machineId = session.selectedMachineId;
    final machineName = session.selectedMachineName;

    if (machineId == null || machineName == null) {
      return PlaceOrderResult.failure('Please select a vending machine first.');
    }

    final item = cart.items.values.single;
    final productId = int.tryParse(item.product.id);
    if (productId == null) {
      return PlaceOrderResult.failure('Invalid product id.');
    }
    if (item.quantity > item.product.stock) {
      return PlaceOrderResult.failure('Not enough stock for this product.');
    }

    try {
      final repo = ref.read(paymentsRepositoryProvider);
      final created = await repo.create(
        productId: productId,
        quantity: item.quantity,
      );

      state = created.orderId;
      ref.read(cartControllerProvider.notifier).clear();

      return PlaceOrderResult.success(
        orderId: created.orderId,
        snapUrl: created.snapUrl,
      );
    } catch (e) {
      return PlaceOrderResult.failure('Failed to create payment.');
    }
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, String?>(CheckoutController.new);
