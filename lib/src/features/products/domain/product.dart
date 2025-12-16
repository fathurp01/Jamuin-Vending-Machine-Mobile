class Product {
  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.description,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String subtitle;
  final int price;
  final String description;
  final List<String> tags;
}
