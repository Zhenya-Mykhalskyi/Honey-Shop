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
    final cart = Provider.of<CartProvider>(context);
    //  final cart = Provider.of<CartProvider>(context);
    final productsProvider = Provider.of<ProductsProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final cartData = cart.items.values.toList()[index];
                final product = productsProvider.getProductById(cartData.id);
                return CartItem(
                  id: cartData.id,
                  title: cartData.title,
                  liters: cartData.liters,
                  price: cartData.price,
                  imageUrl: cartData.imageUrl,
                  productId: cart.items.keys.toList()[index],
                  product: product,
                );
              },
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
