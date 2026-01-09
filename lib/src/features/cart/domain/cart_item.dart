import '../../products/domain/product.dart';

class CartItem {
  const CartItem({
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  final Product product;
  final int quantity;
  final DateTime addedAt;

  int get lineTotal => product.price * quantity;

  // Check if item expired (5 hours)
  bool get isExpired {
    final now = DateTime.now();
    final diff = now.difference(addedAt);
    return diff.inHours >= 5;
  }

  factory CartItem.fromJson(Map<String, Object?> json) {
    final addedAtStr = json['addedAt'] as String?;
    final addedAt = addedAtStr != null
        ? DateTime.tryParse(addedAtStr) ?? DateTime.now()
        : DateTime.now();

    return CartItem(
      product: Product.fromJson(
        (json['product'] as Map).cast<String, Object?>(),
      ),
      quantity: ((json['quantity'] as num?) ?? 1).toInt(),
      addedAt: addedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  CartItem copyWith({Product? product, int? quantity, DateTime? addedAt}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
