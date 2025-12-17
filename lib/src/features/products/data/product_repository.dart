import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../domain/product.dart';
import '../../../core/networking/dio_provider.dart';

abstract class ProductRepository {
  Future<List<Product>> list();
  Future<Product?> getById(String id);

  /// Updates product fields (currently used for stock management).
  Future<Product?> updateStock({required String id, required int stock});
}

final class ApiProductRepository implements ProductRepository {
  ApiProductRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Product>> list() async {
    final res = await _dio.get<List<dynamic>>('/products');
    final data = res.data ?? const [];
    return data
        .whereType<Map>()
        .map((e) => Product.fromJson(e.cast<String, Object?>()))
        .toList(growable: false);
  }

  @override
  Future<Product?> getById(String id) async {
    final numeric = int.tryParse(id);
    if (numeric == null) return null;

    try {
      final res = await _dio.get<Map<String, Object?>>('/products/$numeric');
      final data = res.data;
      if (data == null) return null;
      return Product.fromJson(data);
    } on DioException {
      return null;
    }
  }

  @override
  Future<Product?> updateStock({required String id, required int stock}) async {
    final numeric = int.tryParse(id);
    if (numeric == null) return null;

    try {
      final res = await _dio.patch<Map<String, Object?>>(
        '/products/$numeric',
        data: {'stok': stock},
      );
      final data = res.data;
      if (data == null) return null;
      return Product.fromJson(data);
    } on DioException {
      return null;
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiProductRepository(dio);
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
