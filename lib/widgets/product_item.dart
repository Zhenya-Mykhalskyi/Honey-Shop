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
                    aspectRatio: 1, //відношення сторін 1:1
                    child: GestureDetector(
                      onTap: () {},
                      child: Hero(
                        tag: 'prodImg', //для анімації на детальній сторінці
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
                        '₴${price.toString()}',
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
