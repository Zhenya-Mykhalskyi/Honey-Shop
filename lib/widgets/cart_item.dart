import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:honey/providers/product_model.dart';

import 'liters_counter.dart';

class CartItem extends StatefulWidget {
  final String id;
  final String productId;
  final double price;
  final double liters;
  final String title;
  final String imageUrl;
  final Product? product;
  const CartItem({
    super.key,
    required this.id,
    required this.productId,
    required this.price,
    required this.title,
    required this.liters,
    required this.imageUrl,
    required this.product,
  });

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Card(
        color: Colors.white.withOpacity(0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₴${widget.price.toStringAsFixed(2)} / 0.5',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        LitersCounter(
                          product: widget.product,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
