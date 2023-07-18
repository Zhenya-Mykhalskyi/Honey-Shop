import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:honey/providers/product_model.dart';
import 'package:honey/providers/products.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
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
    final cartProvider = Provider.of<CartProvider>(context);
    final productProvider = Provider.of<ProductsProvider>(context);
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        IconButton(

                            // onPressed: () {
                            //   cartProvider.removeItemFromCart(widget.productId);
                            //   productProvider.resetLiters(widget.product);
                            // },
                            icon: const Icon(Icons.delete),
                            color: Colors.white.withOpacity(0.6),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor:
                                        const Color.fromARGB(255, 27, 27, 27),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(30.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 15),
                                          const Text(
                                            'Впевнені, що хочете видалити товар з корзини?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'MA',
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          ButtonBar(
                                            alignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.of(context).pop();
                                                  cartProvider
                                                      .removeItemFromCart(
                                                          widget.productId);
                                                  productProvider.resetLiters(
                                                      widget.product);
                                                },
                                                child: const Text(
                                                  'Так',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily: 'MA'),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const Text(
                                                  'Скасувати',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: 'MA'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            })
                      ],
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
