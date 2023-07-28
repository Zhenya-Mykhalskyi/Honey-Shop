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

          orders.sort((a, b) {
            final orderA = a.data();
            final orderB = b.data();
            final bool isFinishedA = orderA['isFinished'] ?? false;
            final bool isFinishedB = orderB['isFinished'] ?? false;

            if (isFinishedA == isFinishedB) {
              return orderB['timestamp'].compareTo(orderA['timestamp']);
            } else {
              return isFinishedA ? 1 : -1;
            }
          });

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data();
              final Map<String, dynamic> productsData =
                  (order['products'] as Map<String, dynamic>);

              final List productsList = productsData.values.toList();
              return AdminOrderCard(
                order: order,
                orderProductsData: productsList,
              );
            },
          );
        },
      ),
    );
  }
}
