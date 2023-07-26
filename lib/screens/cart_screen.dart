import 'package:flutter/material.dart';
import 'package:honey/widgets/total_amount.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/cart.dart';
import 'package:honey/providers/products.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/cart_item.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/widgets/my_divider.dart';
import 'package:honey/widgets/title_appbar.dart';
import 'orders_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: const TitleAppBar(title: 'Корзина'),
      body: cartProvider.items.isEmpty
          ? const Center(child: Text('Ваша корзина порожня'))
          : Padding(
              padding: const EdgeInsets.only(top: 15, right: 10, left: 10),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartProvider.items.length,
                      itemBuilder: (context, index) {
                        final cartData =
                            cartProvider.items.values.toList()[index];
                        final product =
                            productsProvider.getProductById(cartData.id);
                        return CartItem(
                          product: product,
                        );
                      },
                    ),
                  ),
                  const MyDivider(),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Загальна сума',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22),
                            ),
                            TotalAmountOfCart(),
                          ],
                        ),
                        Row(children: [
                          Text('Використати бонуси (55)'),
                          // Checkbox(value: null, onChanged: print)
                        ])
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const MyDivider(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: CustomButton(
                      action: () {
                        final cartData = cartProvider.items;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => OrdersScreen(
                                cartData: cartData, isEditProfile: false),
                          ),
                        );
                      },
                      text: 'Оформити',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
