import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference productsCollection =
        FirebaseFirestore.instance.collection('products');

    return Scaffold(
      appBar: AppBar(
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
              items: [
                DropdownMenuItem(
                  value: 'logout',
                  child: Row(
                    children: const [
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
            return ListView.builder(
              itemCount: documents.length,
              itemBuilder: (context, index) {
                // Отримуємо дані з документа
                final productData =
                    documents[index].data() as Map<String, dynamic>;

                return Text(productData['title']);
                // subtitle: Text(productData['price'].toString()),
                // trailing: Image.network(productData['imageUrl']),
              },
            );
          }
        },
      ),
    );
  }
}
