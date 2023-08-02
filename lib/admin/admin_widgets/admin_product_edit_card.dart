import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:honey/admin/admin_screens/product_edit_screen.dart';

class AdminProductEditCard extends StatelessWidget {
  final Map<String, dynamic> productData;
  final String? productId;
  const AdminProductEditCard({
    super.key,
    required this.productData,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      child: Card(
        color: Colors.white.withOpacity(0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CachedNetworkImage(
                          imageUrl: productData['imageUrl'] ??
                              'https://cdn-icons-png.flaticon.com/128/3875/3875172.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        '₴${productData['price'].toStringAsFixed(2)} / 0.5',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Залишилось  ${productData['litersLeft']} л',
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductEditScreen(
                            isAddProduct: false,
                            productId: productId!,
                          ),
                        ),
                      );
                    },
                    color: const Color.fromARGB(255, 217, 217, 217),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
