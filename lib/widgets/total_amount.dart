import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/cart.dart';

class TotalAmountOfCart extends StatelessWidget {
  const TotalAmountOfCart({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Text(
          '₴ ${cartProvider.totalAmountOfCart.toString()}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
