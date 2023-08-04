import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:honey/providers/product_model.dart';
import 'package:honey/screens/product_detail_screen.dart';
import 'package:honey/widgets/app_colors.dart';
import 'liters_counter.dart';

class ProductItem extends StatelessWidget {
  final Product product;
  const ProductItem({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product))),
      child: GridTile(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 14, right: 14, top: 15, bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double stickerSize = constraints.maxWidth;
                        return AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: CachedNetworkImage(
                                      imageUrl: product.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              if (product.isDiscount == true)
                                Positioned(
                                  top: 0,
                                  right: 10,
                                  child: SizedBox(
                                    height: stickerSize,
                                    child: Image.asset(
                                      'assets/img/promotional_sticker.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(product.title,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(
                          product.isDiscount == true
                              ? '₴${product.discountPrice!.toStringAsFixed(2)}'
                              : '₴${product.price.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: product.isDiscount == true
                                  ? AppColors.primaryColor
                                  : Colors.white),
                        ),
                        const SizedBox(width: 5),
                        if (product.isDiscount == true)
                          Text(
                            '₴${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Color.fromARGB(255, 201, 76, 76),
                              color: Color.fromARGB(255, 114, 114, 114),
                            ),
                          ),
                        const Text(
                          ' / 0.5 л',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                LitersCounter(
                  product: product,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
