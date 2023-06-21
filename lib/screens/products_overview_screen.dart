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

// import 'package:flutter/material.dart';

// enum FilterOptions {
//   Favorites,
//   All,
// }

// class ProductsOverviewScreen extends StatefulWidget {
//   const ProductsOverviewScreen({required Key key}) : super(key: key);

//   @override
//   State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
// }

// class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
//   var _showOnlyFavorites = false;
//   var _isInit = true;
//   var _isLoading = false;

//   @override
//   void initState() {
//     // Future.delayed(Duration.zero).then((_) {
//     //future з затримкою, але виконується зразу, бо затримка нульова
//     Provider.of<Products>(context, listen: false).fetchAndSetProducts();
//     // });
//     super.initState();
//   }

  // @override
  // void didChangeDependencies() {
  //   //запускається після повної ініціалізації віджета. Може запускатися декілька разів, а не один як initState
  //   if (_isInit) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     Provider.of<Products>(context, listen: false)
  //         .fetchAndSetProducts()
  //         .then((_) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     });
  //   }
    // _isInit = false;
  //   super.didChangeDependencies();
  // }

//   @override
//   Widget build(BuildContext context) {
//      FirebaseFirestore firestore = FirebaseFirestore.instance;
//     CollectionReference productsCollection = firestore.collection('products');
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Honey'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: productsCollection.snapshots(),
//         builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (snapshot.hasError) {
//             return const Text('Помилка отримання даних');
//           }
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           var products = snapshot.data!.docs;
//           return ListView.builder(
//             itemCount: products.length,
//             itemBuilder: (BuildContext context, int index) {
//               return ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: GridTile(
//                   child: GestureDetector(
//                     child: Hero(
//                       tag: products[index].id,
//                       child: Column(
//                         children: [
//                           Image(
//                             image: NetworkImage(products[index]['imageUrl']),
//                             fit: BoxFit.cover,
//                             width: 300,
//                           ),
//                           Text(products[index]['title']),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

    // MyAppBar(
    //   title: 'Exotic Fruits Shop',
    //   // style: TextStyle(
    //   //     fontFamily: 'Anton', color: Color.fromARGB(232, 255, 255, 255)),
    //   actions: Row(
    //     children: [
    //       PopupMenuButton(
    //           onSelected: (FilterOptions selectedValue) {
    //             setState(() {
    //               if (selectedValue == FilterOptions.Favorites) {
    //                 _showOnlyFavorites = true;
    //               } else {
    //                 _showOnlyFavorites = false;
    //               }
    //             });
    //           },
    //           itemBuilder: (_) => [
    //                 const PopupMenuItem(
    //                   value: FilterOptions.Favorites,
    //                   child: Text(
    //                     'Only Favorites',
    //                   ),
    //                 ),
    //                 const PopupMenuItem(
    //                   value: FilterOptions.All,
    //                   child: Text(
    //                     'Show All',
    //                   ),
    //                 )
    //               ],
    //           icon: const Icon(
    //             Icons.more_vert,
    //           )),
    //       Consumer<Cart>(
    //         builder: (_, cart, ch) => Badgee(
    //           value: cart.itemCount.toString(),
    //           child: ch,
    //         ),
    //         child: IconButton(
    //           onPressed: () {
    //             Navigator.of(context).pushNamed(CartScreen.routeName);
    //           },
    //           icon: const Icon(
    //             Icons.shopping_cart,
    //           ),
    //         ),
    //       ),
    //     ],
    //   ),
    // ),
    // drawer: const AppDrawer(),
    //   body: _isLoading
    //       ? const Center(
    //           child: CircularProgressIndicator(),
    //         )
    //       : ProductsGrid(_showOnlyFavorites),
    // );
//  }
//  }
