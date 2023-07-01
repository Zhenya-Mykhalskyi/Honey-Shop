import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:honey/admin/admin_screens/product_edit_screen.dart';
import 'package:honey/widgets/custom_button.dart';

class EditOverViewScreen extends StatelessWidget {
  const EditOverViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference productCollection =
        FirebaseFirestore.instance.collection('products');

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 15, bottom: 30),
          child: Image.asset('./assets/img/logo.png'),
        ),
        leadingWidth: 90,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: StreamBuilder(
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
                    return ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final productData =
                            products[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          child: Card(
                            color: Colors.white.withOpacity(0.1),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      productData['imageUrl'] ??
                                          'https://cdn-icons-png.flaticon.com/128/3875/3875172.png',
                                      width: 75,
                                      height: 75,
                                    ),
                                  ),
                                  const SizedBox(width: 25),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          productData['title'],
                                          style: const TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '₴${productData['price'].toStringAsFixed(0)} / 0.5',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            // fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          'Залишилось  ${productData['litersLeft']} л',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            // fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 25),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 50),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProductEditScreen(
                                              isAdd: false,
                                              productId: products[index].id,
                                            ),
                                          ),
                                        );
                                      },
                                      color: const Color.fromARGB(
                                          255, 217, 217, 217),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Container();
                }),
          ),
          CustomButton(
            action: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductEditScreen(
                    isAdd: true,
                    productId: productCollection.doc().id,
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
