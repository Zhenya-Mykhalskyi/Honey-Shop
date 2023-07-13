class Product {
  final String id;
  String title;
  double price;
  String imageUrl;
  int litersLeft;
  String shortDescription;
  String longDescription;
  bool isHoney;
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
