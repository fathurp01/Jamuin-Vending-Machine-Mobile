import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/product.dart';

abstract class ProductRepository {
  Future<List<Product>> list();
  Future<Product?> getById(String id);
}

class MockProductRepository implements ProductRepository {
  static const _items = <Product>[
    Product(
      id: 'latte',
      name: 'Latte',
      subtitle: 'Smooth & creamy',
      price: 28000,
      description:
          'A balanced espresso with steamed milk. Great any time of day.',
      tags: ['Bestseller'],
    ),
    Product(
      id: 'americano',
      name: 'Americano',
      subtitle: 'Bold & clean',
      price: 24000,
      description: 'Espresso diluted with hot water for a clean, bold profile.',
      tags: ['Low Sugar'],
    ),
    Product(
      id: 'matcha',
      name: 'Matcha Latte',
      subtitle: 'Earthy & mellow',
      price: 32000,
      description: 'Creamy matcha with a soft finish. Comfort in a cup.',
      tags: ['New'],
    ),
    Product(
      id: 'choco',
      name: 'Chocolate',
      subtitle: 'Rich & cozy',
      price: 30000,
      description: 'A rich chocolate drink with a smooth texture.',
    ),
  ];

  @override
  Future<Product?> getById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _items.where((p) => p.id == id).cast<Product?>().firstOrNull;
  }

  @override
  Future<List<Product>> list() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _items;
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return MockProductRepository();
});

final productListProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.list();
});

final productByIdProvider = FutureProvider.family<Product?, String>((
  ref,
  id,
) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.getById(id);
});

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
