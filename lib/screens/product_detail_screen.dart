import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/cart_provider.dart';
import 'package:honey/providers/product_model.dart';
import 'package:honey/providers/theme_provider.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/widgets/liters_counter.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
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
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Opacity(
              opacity: _isExpanded ? 0.2 : 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.95,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    widget.product.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              if (widget.product.isDiscount == true)
                                Positioned(
                                  right:
                                      MediaQuery.of(context).size.width * 0.035,
                                  child: Image.asset(
                                    'assets/img/promotional_sticker.png',
                                    height: MediaQuery.of(context).size.height *
                                        0.4,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                            ],
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
                                        fontSize: 16,
                                        color: AppColors.darkGreyColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 35),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Text(
                                    widget.product.isDiscount == true
                                        ? '₴ ${widget.product.discountPrice?.toStringAsFixed(2)}'
                                        : '₴ ${widget.product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (widget.product.isDiscount == true)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 25),
                                    child: Text(
                                      '₴ ${widget.product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          decoration:
                                              TextDecoration.lineThrough,
                                          decorationColor: AppColors.saleColor,
                                          color: AppColors.darkGreyColor,
                                          fontSize: 18),
                                    ),
                                  )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.product.productDescription
                                            .length <=
                                        125
                                    ? widget.product.productDescription
                                    : '${widget.product.productDescription.substring(0, 125)}...  ',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    height: 1.45,
                                    fontSize: 16,
                                    fontFamily: 'MA'),
                              ),
                              TextSpan(
                                text: 'Детальніше',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  height: 1.45,
                                  fontSize: 16,
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
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04),
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
                                color: Theme.of(context).cardColor,
                              ),
                              child: Center(
                                child: Text(
                                  cartProvider
                                      .getTotalAmountForProductById(
                                          widget.product.id)
                                      .toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
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
                      color: Theme.of(context).scaffoldBackgroundColor,
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
                                      color: Theme.of(context).primaryColor,
                                    )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  widget.product.productDescription,
                                  style: TextStyle(
                                    height: 1.45,
                                    color: Theme.of(context).primaryColor,
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
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
        child: CustomButton(
          action: () {
            Navigator.of(context).pop();
          },
          text: 'Продовжити покупки',
        ),
      ),
    );
  }
}
