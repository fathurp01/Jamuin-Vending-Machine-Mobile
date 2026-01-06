class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.benefits,
    this.stock = 0, // Deprecated: use InventoryController for per-machine stock
    required this.image,
    this.machineProducts = const [],
  });

  final String id;
  final String name;
  final int price;
  final String description;
  final String benefits;

  /// @deprecated Stock is now per-machine. Use InventoryController instead.
  /// This field is kept for backward compatibility and defaults to 0.
  final int stock;

  /// Can be a filename or full URL.
  final String? image;

  /// Machine-specific stock information from backend.
  /// Each item contains machineId and stok.
  final List<MachineProductStock> machineProducts;

  factory Product.fromJson(Map<String, Object?> json) {
    // Parse machineProducts array if present
    final machineProductsRaw = json['machineProducts'] as List<dynamic>?;
    final machineProducts = <MachineProductStock>[];
    if (machineProductsRaw != null) {
      for (final item in machineProductsRaw) {
        if (item is Map<String, dynamic>) {
          machineProducts.add(MachineProductStock.fromJson(item));
        }
      }
    }

    return Product(
      id: ((json['id'] as num?) ?? 0).toInt().toString(),
      name: (json['name'] as String?) ?? (json['nama'] as String?) ?? '',
      description:
          (json['deskripsi'] as String?) ??
          (json['description'] as String?) ??
          '',
      benefits:
          (json['manfaat'] as String?) ?? (json['benefits'] as String?) ?? '',
      price: ((json['harga'] as num?) ?? (json['price'] as num?) ?? 0).toInt(),
      stock: ((json['stok'] as num?) ?? (json['stock'] as num?) ?? 0)
          .toInt(), // Fallback for compatibility
      image: (json['gambar'] as String?) ?? (json['image'] as String?),
      machineProducts: machineProducts,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': int.tryParse(id) ?? id,
      'name': name,
      'deskripsi': description,
      'manfaat': benefits,
      'harga': price,
      'stok': stock,
      'gambar': image,
    };
  }

  /// Get stock for a specific machine from machineProducts
  int stockForMachine(String machineId) {
    final machineIdNum = int.tryParse(machineId);
    if (machineIdNum == null) return 0;

    for (final mp in machineProducts) {
      if (mp.machineId == machineIdNum) {
        return mp.stok;
      }
    }
    return 0;
  }
}

/// Represents stock of a product in a specific machine
class MachineProductStock {
  const MachineProductStock({
    required this.id,
    required this.machineId,
    required this.productId,
    required this.stok,
  });

  final int id;
  final int machineId;
  final int productId;
  final int stok;

  factory MachineProductStock.fromJson(Map<String, dynamic> json) {
    return MachineProductStock(
      id: (json['id'] as num?)?.toInt() ?? 0,
      machineId: (json['machineId'] as num?)?.toInt() ?? 0,
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      stok: (json['stok'] as num?)?.toInt() ?? 0,
    );
  }
}
