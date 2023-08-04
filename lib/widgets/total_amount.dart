import 'package:flutter/material.dart';

class TotalAmountOfCart extends StatelessWidget {
  final double totalAmount;

  const TotalAmountOfCart({
    super.key,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.1)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Text(
          '₴ ${totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}
