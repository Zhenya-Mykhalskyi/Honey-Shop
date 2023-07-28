import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/my_divider.dart';
import 'admin_order_dialog.dart';

class AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final List orderProductsData;
  const AdminOrderCard(
      {super.key, required this.order, required this.orderProductsData});

  @override
  Widget build(BuildContext context) {
    bool isFinished = order['isFinished'] ?? false;

    void _updateIsFinished(bool newValue) async {
      final hasInternetConnection =
          await CheckConnectivityUtil.checkInternetConnectivity(context);
      if (!hasInternetConnection) {
        return;
      }

      try {
        final String orderId = order['orderId'];
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({'isFinished': newValue});
      } catch (e) {
        print('Error updating isfinished field: $e');
      }
    }

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order['fullName'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          order['address'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AdminOrderDetailsDialog(
                          order: order,
                          orderProductData: orderProductsData,
                        ),
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
                        value: isFinished,
                        onChanged: (value) {
                          isFinished = value;
                          _updateIsFinished(value);
                        },
                      ),
                      Text(
                        '₴${order['totalAmount']}',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
