class Product {
  String id;
  String title;
  double price;
  String imageUrl;
  int litersLeft;
  String shortDescription;
  String longDescription;
  bool isHoney;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.litersLeft,
    required this.shortDescription,
    required this.longDescription,
    required this.isHoney,
  });
}
