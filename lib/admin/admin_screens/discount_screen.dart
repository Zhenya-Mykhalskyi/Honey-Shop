import 'package:flutter/material.dart';
import 'package:honey/widgets/title_appbar.dart';

class DiscountScreen extends StatelessWidget {
  final double productPrice;
  final String productTitle;
  const DiscountScreen(
      {super.key, required this.productPrice, required this.productTitle});

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
              // Text(
              //   productTitle,
              //   style:
              //       const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              // ),
              // Text(
              //   productPrice.toString(),
              //   style:
              //       const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
