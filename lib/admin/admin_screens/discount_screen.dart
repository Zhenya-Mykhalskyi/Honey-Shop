import 'package:flutter/material.dart';

class DiscountScreen extends StatelessWidget {
  final double productPrice;
  final String productTitle;
  const DiscountScreen(
      {super.key, required this.productPrice, required this.productTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Застосування акції'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [Text(productPrice.toString())],
        ),
      ),
    );
  }
}
