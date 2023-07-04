import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/product_item.dart';

//Кнопка категорії
class TabButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final VoidCallback onPressed;

  const TabButton({
    super.key,
    required this.text,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: isActive
              ? const Color.fromARGB(255, 255, 179, 0)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isActive ? Colors.transparent : Colors.white, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'MA',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

//Сітка в залежності від категорії
class ProductGrid extends StatelessWidget {
  final Stream<QuerySnapshot> stream;

  const ProductGrid({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Продуктів не знайдено'));
        } else {
          // Отримуємо список документів
          final documents = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 25,
                mainAxisSpacing: 20,
                childAspectRatio: 1 / 1.7,
              ),
              itemCount: documents.length,
              itemBuilder: (context, index) {
                final title = documents[index].get('title');
                final price = documents[index].get('price');
                final imageUrl = documents[index].get('imageUrl');
                return ProductItem(
                  title: title,
                  price: price,
                  imageUrl: imageUrl,
                );
              },
            ),
          );
        }
      },
    );
  }
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late int activeIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    activeIndex = 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference productsCollection =
        FirebaseFirestore.instance.collection('products');
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                TabButton(
                  text: 'мед',
                  isActive: activeIndex == 0,
                  onPressed: () {
                    setState(() {
                      activeIndex = 0;
                    });
                  },
                ),
                const SizedBox(width: 10),
                TabButton(
                  text: 'інші продукти',
                  isActive: activeIndex == 1,
                  onPressed: () {
                    setState(() {
                      activeIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
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
      body: TabBarView(
        controller: _tabController,
        children: [
          activeIndex == 0
              ? ProductGrid(
                  stream: productsCollection
                      .where('isHoney', isEqualTo: true)
                      .snapshots(),
                )
              : ProductGrid(
                  stream: productsCollection
                      .where('isHoney', isEqualTo: false)
                      .snapshots(),
                ),
        ],
      ),
    );
  }
}
