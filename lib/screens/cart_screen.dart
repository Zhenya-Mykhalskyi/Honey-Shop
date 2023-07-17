import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/admin/admin_screens/product_edit_screen.dart';
import 'package:honey/widgets/custom_button.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/cart_item.dart';

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
    return Padding(
      padding: const EdgeInsets.only(top: 15, right: 20, left: 20),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final cartData = cartProvider.items.values.toList()[index];
                final product = productsProvider.getProductById(cartData.id);
                return CartItem(
                  id: cartData.id,
                  title: cartData.title,
                  liters: cartData.liters,
                  price: cartData.price,
                  imageUrl: cartData.imageUrl,
                  productId: cartProvider.items.keys.toList()[index],
                  product: product,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Загальна сума',
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 179, 0),
                          fontWeight: FontWeight.w500,
                          fontSize: 22),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white.withOpacity(0.1)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20),
                        child: Text(
                          '₴ ${cartProvider.totalAmount.toString()}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(children: [
                  const Text('Використати бонуси (55)'),
                  // Checkbox(value: null, onChanged: print)
                ])
              ],
            ),
          ),
          CustomButton(
            action: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductEditScreen(
                    isAdd: true,
                    productId: FirebaseFirestore.instance
                        .collection('products')
                        .doc()
                        .id,
                  ),
                ),
              );
            },
            text: 'Оформити',
          ),
        ],
      ),
    );
  }
}
