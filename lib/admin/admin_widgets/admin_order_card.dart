import 'package:flutter/material.dart';

import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/my_divider.dart';
import 'admin_order_dialog.dart';

class AdminOrderCard extends StatelessWidget {
  final order;
  final orderProductData;
  const AdminOrderCard({super.key, this.order, this.orderProductData});

  @override
  Widget build(BuildContext context) {
    bool ok = false;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        color: Colors.white.withOpacity(0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['fullName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        order['address'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AdminOrderDetailsDialog(
                            order: order, orderProductData: orderProductData),
                      );
                    },
                    icon: const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 7),
              const MyDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Switch(
                        value: ok,
                        onChanged: (value) {
                          value = !value;
                          print(value);
                        },
                      ),
                      Text(
                        '₴${order['totalAmount']}',
                        style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
