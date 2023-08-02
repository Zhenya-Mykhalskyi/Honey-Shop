import 'package:flutter/material.dart';
import 'package:honey/admin/admin_widgets/admin_product_edit_card.dart';
import 'package:honey/widgets/title_appbar.dart';

class DiscountScreen extends StatelessWidget {
  final double price;
  final String title;
  final double litersLeft;
  final String? imageUrl;
  const DiscountScreen(
      {super.key,
      required this.price,
      required this.title,
      required this.litersLeft,
      this.imageUrl});

  get productData => {
        'price': price,
        'title': title,
        'litersLeft': litersLeft,
        'imageUrl': imageUrl,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: 'Застосування акції',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(
          child: Column(
            children: [
              AdminProductEditCard(
                productData: productData,
                isDiscountScreen: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}
