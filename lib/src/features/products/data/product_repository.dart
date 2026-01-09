import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../domain/product.dart';
import '../../../core/networking/dio_provider.dart';

abstract class ProductRepository {
  Future<List<Product>> list();
  Future<Product?> getById(String id);

  /// Get products available in specific machine
  Future<List<Product>> listByMachine(String machineId);

  /// Get stock of product in specific machine
  Future<int> getMachineStock({
    required String productId,
    required String machineId,
  });

  /// Set stock of product in specific machine
  Future<void> setMachineStock({
    required String productId,
    required String machineId,
    required int stock,
  });

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

  @override
  Future<List<Product>> listByMachine(String machineId) async {
    final numeric = int.tryParse(machineId);
    if (numeric == null) return const [];

    try {
      final res = await _dio.get<List<dynamic>>('/products/machine/$numeric');
      final data = res.data ?? const [];
      return data
          .whereType<Map>()
          .map((e) {
            final map = e.cast<String, Object?>();
            // Response structure: { product: {...}, stok: number }
            final productData = map['product'] as Map<String, Object?>?;
            if (productData == null) return null;

            // Inject stock from machine_products into product object
            final stok = (map['stok'] as num?)?.toInt() ?? 0;
            final productWithStock = Map<String, Object?>.from(productData);
            productWithStock['stok'] = stok;

            return Product.fromJson(productWithStock);
          })
          .whereType<Product>()
          .toList(growable: false);
    } on DioException {
      return const [];
    }
  }

  @override
  Future<int> getMachineStock({
    required String productId,
    required String machineId,
  }) async {
    final productNum = int.tryParse(productId);
    final machineNum = int.tryParse(machineId);
    if (productNum == null || machineNum == null) return 0;

    try {
      final res = await _dio.get<int>(
        '/products/$productNum/machine/$machineNum/stock',
      );
      return res.data ?? 0;
    } on DioException {
      return 0;
    }
  }

  @override
  Future<void> setMachineStock({
    required String productId,
    required String machineId,
    required int stock,
  }) async {
    final productNum = int.tryParse(productId);
    final machineNum = int.tryParse(machineId);
    if (productNum == null || machineNum == null) return;

    await _dio.put(
      '/products/$productNum/machine/$machineNum/stock',
      data: {'stok': stock},
    );
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

/// Provider to get products for a specific machine
final productsByMachineProvider = FutureProvider.family<List<Product>, String>((
  ref,
  machineId,
) async {
  final repo = ref.read(productRepositoryProvider);
  return repo.listByMachine(machineId);
});
