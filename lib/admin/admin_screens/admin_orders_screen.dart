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
                onDelete: () {
                  final String orderId = order['orderId'];
                  FirebaseFirestore.instance
                      .collection('orders')
                      .doc(orderId)
                      .update({'isVisibleForAdmin': false});
                },
              );
            },
          );
        },
      ),
    );
  }
}
