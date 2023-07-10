class Product {
  final String id;
  late final String title;
  late final double price;
  late final String imageUrl;
  late final int litersLeft;
  late final String shortDescription;
  late final String longDescription;
  late final bool isHoney;
  double liters;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.litersLeft,
    required this.shortDescription,
    required this.longDescription,
    required this.isHoney,
    double? liters,
  }) : liters = liters ?? 0.0;
}
