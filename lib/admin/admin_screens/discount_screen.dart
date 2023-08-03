import 'package:flutter/material.dart';
import 'package:honey/admin/admin_widgets/admin_product_edit_card.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/title_appbar.dart';

class DiscountScreen extends StatefulWidget {
  final double price;
  final String title;
  final double litersLeft;
  final String? imageUrl;

  const DiscountScreen({
    Key? key,
    required this.price,
    required this.title,
    required this.litersLeft,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<DiscountScreen> createState() => _DiscountScreenState();
}

class _DiscountScreenState extends State<DiscountScreen> {
  get productData => {
        'price': widget.price,
        'title': widget.title,
        'litersLeft': widget.litersLeft,
        'imageUrl': widget.imageUrl,
      };

  double _discountPercentage = 0.0;

  void _applyDiscount(double percentage) {
    setState(() {
      _discountPercentage = percentage;
    });
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
            children: [
              AdminProductEditCard(
                productData: productData,
                isDiscountScreen: true,
              ),
              const SizedBox(height: 20),
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountButton(double percentage) {
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

  double calculateDiscountedPrice() {
    double discountAmount = widget.price * (_discountPercentage / 100);
    double discountedPrice = widget.price - discountAmount;
    return discountedPrice;
  }
}
