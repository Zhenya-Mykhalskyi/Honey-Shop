import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/cart.dart';
import 'package:honey/providers/products.dart';
import 'package:honey/widgets/total_amount.dart';
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
  num? _bonuses;
  bool _useBonuses = false;

  @override
  void initState() {
    fetchBonusesFromFirestore();
    super.initState();
  }

  Future<void> fetchBonusesFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _bonuses = userDoc.data()?['bonuses'] ?? 0;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    final finalAmount = _useBonuses == false
        ? cartProvider.totalAmountOfCart
        : (cartProvider.totalAmountOfCart -
            num.parse(_bonuses!.toStringAsFixed(2)));
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Загальна сума',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22),
                            ),
                            TotalAmountOfCart(
                              totalAmount: finalAmount,
                            ),
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Використати бонуси (${_bonuses?.toStringAsFixed(0)})',
                                style: const TextStyle(fontSize: 17),
                              ),
                              Transform.scale(
                                scale: 1.4,
                                child: Checkbox(
                                  fillColor: MaterialStateProperty.all<Color>(
                                    AppColors.primaryColor,
                                  ),
                                  checkColor: Colors.black,
                                  activeColor: AppColors.primaryColor,
                                  value: _useBonuses,
                                  onChanged: (value) {
                                    if (_bonuses == 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          duration: Duration(seconds: 2),
                                          content: Text('У вас немає бонусів'),
                                        ),
                                      );
                                    } else {
                                      setState(() {
                                        _useBonuses = value ?? false;
                                      });
                                    }
                                  },
                                ),
                              ),
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
                              cartData: cartData,
                              isEditProfile: false,
                              finalAmount: finalAmount,
                              bonuses: _bonuses,
                              useBonuses: _useBonuses,
                            ),
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
