class Product {
  final String id;
  String title;
  double price;
  String imageUrl;
  int litersLeft;
  String productDescription;

  bool isHoney;
  double liters;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.litersLeft,
    required this.productDescription,
    required this.isHoney,
    double? liters,
  }) : liters = liters ?? 0.0;
}
