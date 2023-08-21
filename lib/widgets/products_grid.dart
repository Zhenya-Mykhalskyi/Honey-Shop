import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/product_model.dart';
import 'package:honey/providers/products_provider.dart';
import 'package:honey/widgets/product_item.dart';
import 'package:honey/providers/theme_provider.dart';

class ProductsGrid extends StatelessWidget {
  final bool isHoney;
  const ProductsGrid({Key? key, required this.isHoney}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProductsProvider productProvider =
        Provider.of<ProductsProvider>(context, listen: false);

    return RefreshIndicator(
      onRefresh: () => productProvider.getProductList(),
      child: Consumer<ProductsProvider>(
        builder: (context, productProvider, _) {
          if (productProvider.items.isEmpty) {
            productProvider.getProductList();
          }
          List<Product> products = productProvider.items;
          List<Product> filteredProducts = isHoney
              ? products.where((product) => product.isHoney).toList()
              : products.where((product) => !product.isHoney).toList();

          if (productProvider.items.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ));
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
      ),
    );
  }
}
