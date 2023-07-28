import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/my_divider.dart';
import 'admin_order_dialog.dart';

class AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final List orderProductsData;
  final VoidCallback onDelete;
  const AdminOrderCard(
      {super.key,
      required this.order,
      required this.orderProductsData,
      required this.onDelete});

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

    Future<void> _showBonusesConfirmaDialog(BuildContext context) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 27, 27, 27),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    'Впевнені, що хочете завершити замовлення та начислити бонуси клієнту? Цю дію неможливо відмінити!',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'MA',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      isFinished = true;
                      _updateIsFinished(true);
                    },
                    child: const Text(
                      'Так',
                      style: TextStyle(color: Colors.red, fontFamily: 'MA'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Повернутися',
                      style: TextStyle(color: Colors.white, fontFamily: 'MA'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    void _showDeleteConfirmaDialog(BuildContext context) async {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 27, 27, 27),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    'Впевнені, що хочете видалити замовлення? Видаляйте замовлення тільки після начислення бонусів клієнту. Цю дію неможливо відмінити!',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'MA',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {
                      onDelete();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Так',
                      style: TextStyle(color: Colors.red, fontFamily: 'MA'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Повернутися',
                      style: TextStyle(color: Colors.white, fontFamily: 'MA'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        color: isFinished
            ? Colors.white.withOpacity(0.01)
            : Colors.white.withOpacity(0.1),
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
                    onPressed: () {
                      _showDeleteConfirmaDialog(context);
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Switch(
                        activeColor: Colors.black.withOpacity(0.85),
                        activeTrackColor: const Color.fromARGB(255, 0, 0, 0),
                        value: isFinished,
                        onChanged: (value) async {
                          if (!isFinished) {
                            await _showBonusesConfirmaDialog(context);
                          }
                        },
                      ),
                      Text(
                        '₴${order['totalAmount']}',
                        style: TextStyle(
                          color: isFinished
                              ? Colors.white.withOpacity(0.4)
                              : AppColors.primaryColor,
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
