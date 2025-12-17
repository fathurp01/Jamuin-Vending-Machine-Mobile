import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/cart_item.dart';
import '../../products/domain/product.dart';
import '../../session/application/session_persistence_providers.dart';

class CartState {
  const CartState({required this.items});

  final Map<String, CartItem> items;

  int get itemCount => items.values.fold(0, (sum, e) => sum + e.quantity);
  int get subtotal => items.values.fold(0, (sum, e) => sum + e.lineTotal);

  // Keep it simple & transparent.
  int get serviceFee => subtotal == 0 ? 0 : 2000;
  int get tax => (subtotal * 0.11).round();
  int get total => subtotal + serviceFee + tax;

  CartState copyWith({Map<String, CartItem>? items}) =>
      CartState(items: items ?? this.items);

  static const empty = CartState(items: {});
}

class CartController extends Notifier<CartState> {
  static const _storageKey = 'cart.v1';

  @override
  CartState build() {
    _load();
    return CartState.empty;
  }

  Future<void> _load() async {
    final storageAsync = ref.read(localStorageProvider);
    final storage = storageAsync.valueOrNull;
    if (storage == null) return;

    final raw = storage.getJsonMap(_storageKey);
    if (raw == null) return;
    final itemsRaw = raw['items'];
    if (itemsRaw is! List) return;

    final items = <String, CartItem>{};
    for (final v in itemsRaw) {
      if (v is Map) {
        final item = CartItem.fromJson(v.cast<String, Object?>());
        items[item.product.id] = item;
      }
    }
    state = CartState(items: items);
  }

  Future<void> _persist() async {
    final storageAsync = ref.read(localStorageProvider);
    final storage = storageAsync.valueOrNull;
    if (storage == null) return;

    await storage.setJson(_storageKey, {
      'items': state.items.values
          .map((e) => e.toJson())
          .toList(growable: false),
    });
  }

  void add(Product product, {int quantity = 1}) {
    final next = Map<String, CartItem>.from(state.items);
    final existing = next[product.id];
    if (existing == null) {
      next[product.id] = CartItem(product: product, quantity: quantity);
    } else {
      next[product.id] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    }
    state = state.copyWith(items: next);
    _persist();
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }

    final next = Map<String, CartItem>.from(state.items);
    final existing = next[productId];
    if (existing == null) return;
    next[productId] = existing.copyWith(quantity: quantity);
    state = state.copyWith(items: next);
    _persist();
  }

  void remove(String productId) {
    final next = Map<String, CartItem>.from(state.items)..remove(productId);
    state = state.copyWith(items: next);
    _persist();
  }

  void clear() {
    state = CartState.empty;
    _persist();
  }
}

final cartControllerProvider = NotifierProvider<CartController, CartState>(
  CartController.new,
);
