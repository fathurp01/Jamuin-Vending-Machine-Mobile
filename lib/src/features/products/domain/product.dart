class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.benefits,
    required this.stock,
    required this.image,
  });

  final String id;
  final String name;
  final int price;
  final String description;
  final String benefits;
  final int stock;

  /// Can be a filename or full URL.
  final String? image;

  factory Product.fromJson(Map<String, Object?> json) {
    return Product(
      id: ((json['id'] as num?) ?? 0).toInt().toString(),
      name: (json['nama'] as String?) ?? (json['name'] as String?) ?? '',
      description:
          (json['deskripsi'] as String?) ??
          (json['description'] as String?) ??
          '',
      benefits:
          (json['manfaat'] as String?) ?? (json['benefits'] as String?) ?? '',
      price: ((json['harga'] as num?) ?? (json['price'] as num?) ?? 0).toInt(),
      stock: ((json['stok'] as num?) ?? (json['stock'] as num?) ?? 0).toInt(),
      image: (json['gambar'] as String?) ?? (json['image'] as String?),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': int.tryParse(id) ?? id,
      'nama': name,
      'deskripsi': description,
      'manfaat': benefits,
      'harga': price,
      'stok': stock,
      'gambar': image,
    };
  }
}
