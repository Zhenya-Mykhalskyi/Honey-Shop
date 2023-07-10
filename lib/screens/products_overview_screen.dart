import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/products.dart';
import '../widgets/product_item.dart';

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

class ProductGrid extends StatelessWidget {
  final bool isHoney;
  const ProductGrid({Key? key, required this.isHoney}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ProductsProvider productProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    return FutureBuilder<List<Product>>(
      future: productProvider.getProductList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<Product> products = snapshot.data ?? [];
          List<Product> filteredProducts = isHoney
              ? products.where((product) => product.isHoney).toList()
              : products.where((product) => !product.isHoney).toList();

          if (filteredProducts.isEmpty) {
            return const Center(
                child: Text('Продуктів цієї категорії не знайдено'));
          }

          return Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 25,
                mainAxisSpacing: 20,
                childAspectRatio: 1 / 1.7,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ProductItem(
                  product: product,
                );
              },
            ),
          );
        }
      },
    );
  }
}

// class ProductScreen extends StatefulWidget {
//   const ProductScreen({Key? key}) : super(key: key);

//   @override
//   State<ProductScreen> createState() => _ProductScreenState();
// }

// class _ProductScreenState extends State<ProductScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late int activeIndex;

//   @override
//   void initState() {
//     _tabController = TabController(length: 1, vsync: this);
//     activeIndex = 0;
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         // appBar: AppBar(
//         //   elevation: 0,
//         // leading: PreferredSize(
//         //   preferredSize: const Size.fromHeight(50),
//         //   child: Container(
//         //     padding: const EdgeInsets.symmetric(horizontal: 15),
//         //     child: Row(
//         //       children: [
//         //         TabButton(
//         //           text: 'мед',
//         //           isActive: activeIndex == 0,
//         //           onPressed: () {
//         //             setState(() {
//         //               activeIndex = 0;
//         //             });
//         //           },
//         //         ),
//         //         const SizedBox(width: 10),
//         //         TabButton(
//         //           text: 'інше',
//         //           isActive: activeIndex == 1,
//         //           onPressed: () {
//         //             setState(() {
//         //               activeIndex = 1;
//         //             });
//         //           },
//         //         ),
//         //       ],
//         //     ),
//         //   ),
//         // ),
//         // toolbarHeight: 100,
//         // elevation: 0,
//         // leading: Container(
//         //   margin: const EdgeInsets.only(left: 20, top: 20),
//         //   child: Image.asset('./assets/img/logo.png'),
//         // ),
//         // leadingWidth: 95,
//         // actions: [
//         //   Container(
//         //     margin: const EdgeInsets.only(top: 35, right: 10),
//         //     child: DropdownButton(
//         //       underline: Container(),
//         //       icon: const Icon(
//         //         Icons.person,
//         //         color: Colors.white,
//         //         size: 40,
//         //       ),
//         //       items: const [
//         //         DropdownMenuItem(
//         //           value: 'logout',
//         //           child: Row(
//         //             children: [
//         //               Icon(Icons.exit_to_app),
//         //               SizedBox(width: 8),
//         //               Text(
//         //                 'Logout',
//         //                 style: TextStyle(color: Colors.black),
//         //               )
//         //             ],
//         //           ),
//         //         )
//         //       ],
//         //       onChanged: (itemIdentifier) {
//         //         if (itemIdentifier == 'logout') {
//         //           FirebaseAuth.instance.signOut();
//         //         }
//         //       },
//         //     ),
//         //   )
//         // ],
//         // ),
//         // body: TabBarView(
//         //   controller: _tabController,
//         //   children: [
//         //     activeIndex == 0
//         //         ? const ProductGrid(
//         //             isHoney: true,
//         //           )
//         //         : const ProductGrid(
//         //             isHoney: false,
//         //           ),
//         //   ],
//         // ),
//         );
//   }
// }
