class Product {
  final String id;
  String title;
  double price;
  String imageUrl;
  int litersLeft;
  String productDescription;
  bool isHoney;

  bool? isDiscount;
  double? discountPrice;
  int? discountPercentage;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.litersLeft,
    required this.productDescription,
    required this.isHoney,
    this.isDiscount,
    this.discountPrice,
    this.discountPercentage,
  });
}
