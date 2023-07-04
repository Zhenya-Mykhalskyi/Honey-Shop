import 'package:flutter/material.dart';

class ProductItem extends StatelessWidget {
  final String title;
  final double price;
  final String imageUrl;
  const ProductItem(
      {super.key,
      required this.title,
      required this.price,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final _imgWidth = MediaQuery.of(context).size.width;

    return GridTile(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 14, right: 14, top: 15, bottom: 10), //
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      onTap: () {},
                      child: Hero(
                        tag: Image.asset('assets/img/honey1'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text(
                        price.toString(),
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      const Text(
                        ' / 0.5 л',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),

              //ЛІЧИЛЬНИК ЛІЧИЛЬНИК ЛІЧИЛЬНИК ЛІЧИЛЬНИК ЛІЧИЛЬНИК
              Container(
                height: MediaQuery.of(context).size.height * 0.04,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 65, 65, 65),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.093,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 179, 0)
                                .withOpacity(0.85),
                            borderRadius: BorderRadius.circular(15)),
                        child: const Center(
                          child:
                              Icon(Icons.add, size: 20.0, color: Colors.black),
                        ),
                      ),
                    ),
                    const Text(
                      '0.5 л',
                      style: TextStyle(
                        fontSize: 13.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.093,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 179, 0)
                                .withOpacity(0.85),
                            borderRadius: BorderRadius.circular(15)),
                        child: const Center(
                          child: Icon(Icons.remove,
                              size: 20.0, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

                  // Padding(
                  //   padding: EdgeInsets.only(left: 9.0, right: 9.0, bottom: 15),
                  //   child: Container(
                  //     // width: 180,
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(15),
                  //       color: Color.fromARGB(255, 65, 65, 65),
                  //     ),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //       children: [
                  //         GestureDetector(
                  //           onTap: () {},
                  //           child: Container(
                  //             // width: 40.0,
                  //             decoration: BoxDecoration(
                  //                 // color: ColorPalette().coffeeSelected2,
                  //                 borderRadius: BorderRadius.circular(15)),
                  //             child: Center(
                  //               child: Icon(
                  //                 Icons.remove,
                  //                 size: 20.0,
                  //                 // color: ColorPalette().scaffoldBg,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //         Padding(
                  //           padding: const EdgeInsets.symmetric(horizontal: 0),
                  //           child: Container(
                  //             // width: 100,
                  //             padding: EdgeInsets.all(0),
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(15),
                  //               // color: ColorPalette()
                  //               //     .searchBarFill2
                  //               //     .withOpacity(0.9),
                  //             ),
                  //             child: Center(
                  //               child: Text(
                  //                 '0.5 л',
                  //                 // style: GoogleFonts.montserratAlternates(
                  //                 //     fontWeight: FontWeight.w500,
                  //                 //     color: ColorPalette().text,
                  //                 //     fontSize: 15.0),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //         GestureDetector(
                  //           onTap: () {},
                  //           child: Container(
                  //             // width: 40.0,
                  //             decoration: BoxDecoration(
                  //                 // color: ColorPalette().coffeeSelected2,
                  //                 borderRadius: BorderRadius.circular(15.0)),
                  //             child: Center(
                  //               child: Icon(
                  //                 Icons.add,
                  //                 size: 20.0,
                  //                 // color: ColorPalette().scaffoldBg,
                  //               ),
                  //             ),
                  //           ),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // )
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // return Expanded(
  //   child: Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(10.0),
  //     ),
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       // mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Center(
  //           child: ClipRRect(
  //             borderRadius: BorderRadius.circular(10.0),
  //             child: Image.asset(
  //               'assets/img/honey1.png',
  //               fit: BoxFit.fill,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 12.0),
  //         const Text(
  //           'Мед гречаний',
  //           style: TextStyle(
  //             fontSize: 16.0,
  //           ),
  //         ),
  //         const SizedBox(height: 7),
  //         const Row(
  //           children: [
  //             Text(
  //               '₴120 ',
  //               style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
  //             ),
  //             Text(' / 0.5 л')
  //           ],
  //         ),
  //         const SizedBox(height: 10.0),
  // Row(
  //   mainAxisAlignment: MainAxisAlignment.center,
  //   children: [
  //     IconButton(
  //       icon: const Icon(Icons.remove),
  //       onPressed: () {
  //         // Логіка віднімання 0.5
  //       },
  //     ),
  //     Text(
  //       '0.5',
  //       style: TextStyle(
  //         fontSize: 16.0,
  //       ),
  //     ),
  //     IconButton(
  //       icon: const Icon(Icons.add),
  //       onPressed: () {
  //         // Логіка додавання 0.5
  //       },
  //     ),
  //   ],
  // ),
  //       ],
  //     ),
  //   ),
  // );

