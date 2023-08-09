import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/product_model.dart';
import 'package:honey/providers/cart.dart';
import 'app_colors.dart';
import 'custom_confirm_dialog.dart';

class LitersCounter extends StatefulWidget {
  final Product? product;
  final bool? isCart;

  const LitersCounter({super.key, this.product, this.isCart});

  @override
  State<LitersCounter> createState() => _LitersCounterState();
}

class _LitersCounterState extends State<LitersCounter> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    double currentLiters =
        cartProvider.getProductLitersById(widget.product!.id);
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
              if (widget.isCart == true && currentLiters == 0.5) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmationDialog(
                      title: 'Видалити товар з корзини?',
                      confirmButtonText: 'Так',
                      cancelButtonText: 'Ні',
                      onConfirm: () {
                        Navigator.of(context).pop();
                        cartProvider.removeItemFromCart(widget.product!.id);
                      },
                    );
                  },
                );
              } else {
                cartProvider.removeHalfLiterFromCart(
                    widget.product!.id, widget.isCart ?? false);
              }
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
              '${cartProvider.getProductLitersById(widget.product!.id).toString()} л',
              style: const TextStyle(
                fontSize: 15.0,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (widget.product!.litersLeft > currentLiters) {
                cartProvider.addHalfLiterToCart(
                  product: widget.product!,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 2),
                    content: Text(
                        'В наявності залишилось ${widget.product?.litersLeft} літри')));
                return;
              }
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
