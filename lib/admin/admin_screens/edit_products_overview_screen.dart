import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:honey/admin/admin_widgets/admin_product_edit_card.dart';
import 'product_edit_screen.dart';
import 'package:honey/widgets/custom_button.dart';

class EditProductsOverviewScreen extends StatelessWidget {
  final bool isHoney;

  const EditProductsOverviewScreen({
    required this.isHoney,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference productCollection =
        FirebaseFirestore.instance.collection('products');

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Помилка при отриманні даних');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  final products = snapshot.data!.docs;
                  final filteredProducts = products.where((product) {
                    final productData = product.data() as Map<String, dynamic>;
                    return productData['isHoney'] == isHoney;
                  }).toList();
                  return ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final productData = filteredProducts[index].data()
                          as Map<String, dynamic>;
                      return AdminProductEditCard(
                        productData: productData,
                        productId: filteredProducts[index].id,
                      );
                    },
                  );
                }
                return Container();
              },
            ),
          ),
          CustomButton(
            action: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductEditScreen(
                    isAddProduct: true,
                    productId: FirebaseFirestore.instance
                        .collection('products')
                        .doc()
                        .id,
                  ),
                ),
              );
            },
            text: 'Додати товар',
          ),
        ],
      ),
    );
  }
}
