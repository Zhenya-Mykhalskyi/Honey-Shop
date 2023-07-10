import 'package:flutter/material.dart';
import 'package:honey/widgets/liters_counter.dart';
import '../providers/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: Column(
        children: [
          Center(
            child: Text(product.title),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            child: LitersCounter(product: product),
          ),
        ],
      ),
    );
  }
}
