class Product {
  String id;
  String title;
  double price;
  String imageUrl;
  int litersLeft;
  String shortDescription;
  String longDescription;
  bool isHoney;
  double liters = 0;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.litersLeft,
    required this.shortDescription,
    required this.longDescription,
    required this.isHoney,
    required this.liters,
  });
}
