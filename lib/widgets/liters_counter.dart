import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/product_model.dart';
import 'package:honey/providers/cart.dart';
import 'app_colors.dart';

class LitersCounter extends StatefulWidget {
  final Product? product;
  final String? productId;
  const LitersCounter({super.key, this.product, this.productId});

  @override
  State<LitersCounter> createState() => _LitersCounterState();
}

class _LitersCounterState extends State<LitersCounter> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.04,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color.fromARGB(255, 65, 65, 65),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              cart.removeSingleItemFromCart(widget.product!.id);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.093,
              decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(15)),
              child: const Center(
                child: Icon(Icons.remove, size: 20.0, color: Colors.black),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${cart.getLitersForProduct(widget.productId!).toString()} л',
              style: const TextStyle(
                fontSize: 15.0,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              cart.addItemToCart(
                product: widget.product!,
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.093,
              decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(15)),
              child: const Center(
                child: Icon(Icons.add, size: 20.0, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
