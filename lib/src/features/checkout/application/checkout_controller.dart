import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cart/application/cart_controller.dart';

enum TransactionStatus { pending, brewing, ready, completed, failed }

class TransactionState {
  const TransactionState({
    required this.id,
    required this.status,
    required this.total,
  });

  final String id;
  final TransactionStatus status;
  final int total;

  TransactionState copyWith({TransactionStatus? status}) {
    return TransactionState(
      id: id,
      status: status ?? this.status,
      total: total,
    );
  }
}

class CheckoutController extends Notifier<TransactionState?> {
  @override
  TransactionState? build() => null;

  Future<String?> placeOrder() async {
    final cart = ref.read(cartControllerProvider);
    if (cart.subtotal == 0) return null;

    final id = _newId();
    state = TransactionState(
      id: id,
      status: TransactionStatus.pending,
      total: cart.total,
    );

    // Simulate status updates.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    state = state?.copyWith(status: TransactionStatus.brewing);

    await Future<void>.delayed(const Duration(milliseconds: 650));
    state = state?.copyWith(status: TransactionStatus.ready);

    await Future<void>.delayed(const Duration(milliseconds: 500));
    state = state?.copyWith(status: TransactionStatus.completed);

    ref.read(cartControllerProvider.notifier).clear();
    return id;
  }

  static String _newId() {
    final r = Random();
    final n = 100000 + r.nextInt(900000);
    return 'TX$n';
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, TransactionState?>(
      CheckoutController.new,
    );
