import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/providers/theme_provider.dart';
import 'package:honey/widgets/custom_confirm_dialog.dart';
import 'package:honey/widgets/custom_divider.dart';
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
    bool isOrderFinished = order['isFinished'] ?? false;

    Future<Map<String, dynamic>> getCashbackData() async {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc('cashback')
          .get();
      final data = docSnapshot.data();
      if (data == null) {
        return {};
      }
      final percentages = (data['percentages'] as List<dynamic>)
          .map<int>((value) => int.parse(value))
          .toList();
      final amounts = (data['amounts'] as List<dynamic>)
          .map<int>((value) => int.parse(value))
          .toList();

      return {
        'percentages': percentages,
        'amounts': amounts,
      };
    }

    void updateIsFinishedStatus(bool newValue) async {
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

    void updateUserTotalAmountAndBonuses(
        String userId, double orderAmount, double bonusAmount) async {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          final currentOrdersTotalAmount =
              userDoc.data()?['ordersTotalAmount'] ?? 0.0;
          final newOrdersTotalAmount = currentOrdersTotalAmount + orderAmount;
          final currentBonuses = userDoc.data()?['bonuses'] ?? 0.0;
          final newBonuses = currentBonuses + bonusAmount.toInt();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'ordersTotalAmount': newOrdersTotalAmount,
            'bonuses': newBonuses,
          });
        }
      } catch (e) {
        print('Error updating user totalAmount: $e');
      }
    }

    void confirmOrder() async {
      final navContext = Navigator.of(context);
      final hasInternetConnection =
          await CheckConnectivityUtil.checkInternetConnectivity(context);
      try {
        if (!hasInternetConnection) {
          return;
        }
        final cashbackData = await getCashbackData();
        isOrderFinished = true;
        final userId = order['userId'];
        final double orderAmount = order['totalAmount'];
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        final userOrdersTotalAmount =
            userDoc.data()?['ordersTotalAmount'] ?? 0.0;

        int maxAmountIndex = -1;
        for (int i = 0; i < cashbackData['amounts'].length; i++) {
          if (cashbackData['amounts'][i] <=
              orderAmount + userOrdersTotalAmount) {
            maxAmountIndex = i;
          } else {
            break;
          }
        }
        int percentage = maxAmountIndex >= 0
            ? cashbackData['percentages'][maxAmountIndex]
            : 0;
        double bonusAmount = (percentage / 100) * orderAmount;

        updateUserTotalAmountAndBonuses(userId, orderAmount, bonusAmount);
        updateIsFinishedStatus(true);
        navContext.pop();
      } catch (e) {
        print(e);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        color: isOrderFinished
            ? Theme.of(context).primaryColor.withOpacity(0.25)
            : Theme.of(context).cardColor,
        elevation: 0,
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
                    icon: Icon(
                      Icons.arrow_downward,
                      color: Theme.of(context).primaryColor,
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmationDialog(
                            title:
                                'Якщо замовлення не було завершене, то витрачені бонуси повернуться клієнтові. Впевнені, що хочете видалити замовлення? Цю дію неможливо відмінити!',
                            confirmButtonText: 'Так',
                            cancelButtonText: 'Повернутися',
                            onConfirm: () {
                              Navigator.of(context).pop();
                              onDelete();
                            },
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Row(
                    children: [
                      Switch(
                        activeColor: AppColors.darkGreyColor,
                        activeTrackColor: AppColors.blackColor.withOpacity(0.4),
                        value: isOrderFinished,
                        onChanged: (value) {
                          if (!isOrderFinished) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ConfirmationDialog(
                                  title:
                                      'Впевнені, що хочете завершити замовлення та начислити бонуси клієнту? Цю дію неможливо відмінити!',
                                  confirmButtonText: 'Так',
                                  cancelButtonText: 'Повернутися',
                                  onConfirm: () {
                                    confirmOrder();
                                  },
                                );
                              },
                            );
                          }
                        },
                      ),
                      Text(
                        '₴${order['totalAmount'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: isOrderFinished
                              ? AppColors.whiteColor.withOpacity(0.4)
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
