import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String? id;
  final String? title;
  final String? shortDescription;
  final String? longDescription;
  final String? imageUrl;
  final double? price;
  final double? litersLeft;
  final double? quantity;
  final bool? isHoney;

  Product({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.imageUrl,
    required this.price,
    required this.litersLeft,
    required this.quantity,
    this.isHoney = true,
  });
}
