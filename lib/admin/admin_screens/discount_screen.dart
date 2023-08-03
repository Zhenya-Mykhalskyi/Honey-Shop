import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/widgets/title_appbar.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/providers/product_model.dart';
import 'package:honey/providers/products.dart';
import 'package:honey/admin/admin_widgets/admin_product_edit_card.dart';

class DiscountScreen extends StatefulWidget {
  final Product product;

  const DiscountScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  int _discountPercentage = 0;
  @override
  void initState() {
    super.initState();
    _fetchDiscountPercentage();
  }

  void _fetchDiscountPercentage() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.product.id)
          .get();

      if (productSnapshot.exists) {
        Map<String, dynamic> data =
            productSnapshot.data() as Map<String, dynamic>;
        setState(() {
          _discountPercentage = data['discountPercentage'] ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching discount percentage: $e');
    }
  }

  get productData => {
        'price': widget.product.price,
        'title': widget.product.title,
        'litersLeft': widget.product.litersLeft,
        'imageUrl': widget.product.imageUrl,
      };

  void _applyDiscount(int percentage) {
    setState(() {
      _discountPercentage = percentage;
    });
  }

  double calculateDiscountedPrice() {
    double discountAmount = widget.product.price * (_discountPercentage / 100);
    double discountedPrice = widget.product.price - discountAmount;
    return discountedPrice;
  }

  Future<void> saveDiscount() async {
    final navContext = Navigator.of(context);
    double discountedPrice = calculateDiscountedPrice();
    try {
      await Provider.of<ProductsProvider>(context, listen: false).applyDiscount(
        widget.product.id,
        _discountPercentage,
        discountedPrice,
      );
      navContext.pop();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(
        title: 'Застосування акції',
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  AdminProductEditCard(
                    productData: productData,
                    isDiscountScreen: true,
                  ),
                  const SizedBox(height: 35),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDiscountButton(10),
                      _buildDiscountButton(15),
                      _buildDiscountButton(20),
                      _buildDiscountButton(30),
                      _buildDiscountButton(50),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ціна з урахуванням акції:',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${calculateDiscountedPrice().toStringAsFixed(2)} грн',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              CustomButton(action: saveDiscount, text: 'Зберегти')
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountButton(int percentage) {
    bool isActive = percentage == _discountPercentage;
    return Padding(
      padding: const EdgeInsets.all(7),
      child: GestureDetector(
        onTap: () => _applyDiscount(percentage),
        child: Container(
          width: 115,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
          child: Text(
            textAlign: TextAlign.center,
            '${percentage.toInt()}%',
            style: TextStyle(
              fontSize: 16,
              color: isActive ? Colors.white : AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
