import 'package:flutter/material.dart';
import 'package:honey/providers/product.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';

class LitersCounter extends StatefulWidget {
  final Product product;
  const LitersCounter({
    super.key,
    required this.product,
  });

  @override
  State<LitersCounter> createState() => _LitersCounterState();
}

class _LitersCounterState extends State<LitersCounter> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final productsProvider = Provider.of<ProductsProvider>(context);

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
              productsProvider.subtractHalfLiter(widget.product);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.093,
              decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 255, 179, 0).withOpacity(0.85),
                  borderRadius: BorderRadius.circular(15)),
              child: const Center(
                child: Icon(Icons.remove, size: 20.0, color: Colors.black),
              ),
            ),
          ),
          Text(
            '${widget.product.liters.toString()} л',
            style: const TextStyle(
              fontSize: 15.0,
            ),
          ),
          GestureDetector(
            onTap: () {
              productsProvider.addHalfLiter(widget.product);
              cart.addItemToCart(widget.product.id, widget.product.price,
                  widget.product.title, widget.product.imageUrl);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.093,
              decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 255, 179, 0).withOpacity(0.85),
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
