import '../../products/domain/product.dart';

class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  int get lineTotal => product.price * quantity;

  factory CartItem.fromJson(Map<String, Object?> json) {
    return CartItem(
      product: Product.fromJson(
        (json['product'] as Map).cast<String, Object?>(),
      ),
      quantity: ((json['quantity'] as num?) ?? 1).toInt(),
    );
  }

  Map<String, Object?> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }

  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
