import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:honey/admin/admin_widgets/admin_order_card.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Text('Помилка завантаження замовлень');
          }

          final orders = snapshot.data?.docs ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('Немає замовлень'));
          }

          orders.sort((order1, order2) {
            final data1 = order1.data();
            final data2 = order2.data();
            final bool isFinished1 = data1['isFinished'] ?? false;
            final bool isFinished2 = data2['isFinished'] ?? false;

            if (isFinished1 == isFinished2) {
              return data2['timestamp'].compareTo(data1['timestamp']);
            } else {
              return isFinished1 ? 1 : -1;
            }
          });

          final adminOrders = orders
              .where((order) => (order.data()['isVisibleForAdmin'] ?? false))
              .toList();

          return ListView.builder(
            itemCount: adminOrders.length,
            itemBuilder: (context, index) {
              final order = adminOrders[index].data();
              final Map<String, dynamic> productsData =
                  (order['products'] as Map<String, dynamic>);

              final List productsList = productsData.values.toList();

              return AdminOrderCard(
                order: order,
                orderProductsData: productsList,
                onDelete: () async {
                  final String orderId = order['orderId'];
                  DocumentSnapshot orderSnapshot = await FirebaseFirestore
                      .instance
                      .collection('orders')
                      .doc(orderId)
                      .get();

                  if (orderSnapshot.exists) {
                    Map<String, dynamic> orderData =
                        orderSnapshot.data() as Map<String, dynamic>;
                    bool isFinished = orderData['isFinished'] ?? false;
                    if (!isFinished) {
                      String userId = orderData['userId'];
                      num usedBonuses = orderData['usedBonuses'] ?? 0.0;
                      print(usedBonuses);
                      print('usedBonuses');
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .update({
                        'bonuses': FieldValue.increment(usedBonuses),
                      });

                      await FirebaseFirestore.instance
                          .collection('orders')
                          .doc(orderId)
                          .update({
                        'isFinished': true,
                        'isVisibleForAdmin': false,
                      });
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
