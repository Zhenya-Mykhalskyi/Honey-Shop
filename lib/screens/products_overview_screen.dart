import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/product_item.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference productsCollection =
        FirebaseFirestore.instance.collection('products');

    return Scaffold(
      appBar: AppBar(
        // bottom: TabBar,
        toolbarHeight: 100,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 20, top: 20),
          child: Image.asset('./assets/img/logo.png'),
        ),
        leadingWidth: 95,
        actions: [
          Container(
            margin: const EdgeInsets.only(top: 35, right: 10),
            child: DropdownButton(
              underline: Container(), //скрити полоску
              icon: const Icon(
                Icons.person,
                color: Colors.white,
                size: 40,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                )
              ],
              onChanged: (itemIdentifier) {
                if (itemIdentifier == 'logout') {
                  FirebaseAuth.instance.signOut();
                }
              },
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('No products found');
          } else {
            // Отримуємо список документів
            final documents = snapshot.data!.docs;
            return Padding(
              padding: const EdgeInsets.only(right: 20, left: 20, top: 30),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 25,
                  childAspectRatio: 1 / 1.8,
                ),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final title = documents[index].get('title');
                  final price = documents[index].get('price');
                  final imageUrl = documents[index].get('imageUrl');

                  return ProductItem(
                      title: title, price: price, imageUrl: imageUrl);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
