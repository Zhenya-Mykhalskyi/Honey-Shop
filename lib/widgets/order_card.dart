import 'package:flutter/material.dart';

import 'package:honey/screens/user_profile_screen.dart';
import 'package:honey/widgets/order_detail_dialog.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Замовлення за:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Text(order.date),
                      const SizedBox(width: 10),
                      Text(order.time)
                    ],
                  )
                ],
              ),
              Row(
                children: [
                  Text(
                    '₴ ${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) =>
                              OrderDetailsDialog(order: order),
                        );
                      },
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Theme.of(context).primaryColor,
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
