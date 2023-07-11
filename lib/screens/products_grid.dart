import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';
import '../widgets/product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool isHoney;
  const ProductGrid({Key? key, required this.isHoney}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (context, productProvider, _) {
        if (productProvider.items.isEmpty) {
          productProvider.getProductList();
        }
        List<Product> products = productProvider.items;
        List<Product> filteredProducts = isHoney
            ? products.where((product) => product.isHoney).toList()
            : products.where((product) => !product.isHoney).toList();

        if (filteredProducts.isEmpty) {
          return const Center(
              child: Text('Продуктів цієї категорії не знайдено'));
        }

        return Padding(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 25,
              mainAxisSpacing: 20,
              childAspectRatio: 1 / 1.7,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return ProductItem(
                product: product,
              );
            },
          ),
        );
      },
    );
  }
}
