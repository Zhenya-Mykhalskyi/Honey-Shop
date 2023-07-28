import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/product_model.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/providers/cart.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/widgets/liters_counter.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: _isExpanded ? 0.2 : 1,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                widget.product.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.title,
                                    style: const TextStyle(fontSize: 26),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Залишилось ${widget.product.litersLeft} л',
                                    style: const TextStyle(
                                        fontSize: 16, color: Color(0xFF929292)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    '₴ ${widget.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: AppColors.primaryColor,
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
                                        color:
                                            Color.fromARGB(255, 114, 114, 114),
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
                                text: widget.product.productDescription
                                            .length <=
                                        140
                                    ? widget.product.productDescription
                                    : '${widget.product.productDescription.substring(0, 140)}... ',
                                style: const TextStyle(
                                    height: 1.45,
                                    fontSize: 16,
                                    fontFamily: 'MA'),
                              ),
                              TextSpan(
                                text: 'Детальніше',
                                style: const TextStyle(
                                  height: 1.45,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      _isExpanded = true;
                                    });
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
                              child: LitersCounter(
                                product: widget.product,
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.04,
                              width: MediaQuery.of(context).size.width * 0.25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(255, 65, 65, 65),
                              ),
                              child: Center(
                                child: Text(
                                  cartProvider
                                      .getTotalAmountForProductById(
                                          widget.product.id)
                                      .toString(),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child:
                          CustomButton(action: () {}, text: 'Додати до кошика'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isExpanded)
            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.black.withOpacity(0.9),
                    child: SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.product.title,
                                      style: const TextStyle(
                                        color: AppColors.primaryColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isExpanded = false;
                                      });
                                    },
                                    icon: const Icon(Icons.close),
                                    iconSize: 30,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                widget.product.productDescription,
                                style: const TextStyle(
                                  height: 1.45,
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
