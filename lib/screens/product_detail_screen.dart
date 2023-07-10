import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:honey/widgets/custom_button.dart';

import 'package:honey/widgets/liters_counter.dart';
import '../providers/product.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(fontSize: 26),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Залишилось ${product.litersLeft} л',
                          style: const TextStyle(
                              fontSize: 16, color: Color(0xFF929292)),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Text(
                            '₴ ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Color.fromARGB(255, 255, 179, 0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 25),
                          child: Text(
                            '₴ 199',
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                decorationColor:
                                    Color.fromARGB(255, 201, 76, 76),
                                color: Color.fromARGB(255, 114, 114, 114),
                                fontSize: 18),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: product.shortDescription,
                        style: const TextStyle(
                            height: 1.45, fontSize: 16, fontFamily: 'MA'),
                      ),
                      TextSpan(
                        text: ' Детальніше',
                        style: const TextStyle(
                          height: 1.45,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Yo')),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: LitersCounter(product: product),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.04,
                      width: MediaQuery.of(context).size.width * 0.25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 65, 65, 65),
                      ),
                      child: const Center(
                        child: Text(
                          '597 грн',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            CustomButton(action: () {}, text: 'Додати до кошика'),
          ],
        ),
      ),
    );
  }
}
