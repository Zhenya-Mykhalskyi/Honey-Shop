import 'package:flutter/material.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/my_divider.dart';

class AdminOrderDetailsDialog extends StatelessWidget {
  final order;
  final orderProductData;
  const AdminOrderDetailsDialog({super.key, this.order, this.orderProductData});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      backgroundColor: const Color.fromARGB(255, 27, 27, 27),
      child: Container(
        padding: const EdgeInsets.only(right: 20, left: 20, bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Замовлення за:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Text(order['date']),
                        const SizedBox(width: 10),
                        Text(order['time'])
                      ],
                    )
                  ],
                ),
                Text(
                  '₴ ${order['totalAmount']}',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const MyDivider(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderProductData.length,
                  itemBuilder: (context, index) {
                    final product = orderProductData[index];
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              product['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${product['liters'].toString()} л',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const MyDivider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Image.asset(
                      'assets/img/delivery_info_truck.png',
                      height: 20,
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Інформація доставки:',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DeliveryInfoText(text: order['fullName']),
                DeliveryInfoText(text: order['phoneNumber']),
                DeliveryInfoText(text: order['address']),
                DeliveryInfoText(text: order['selectedDelivery']),
                DeliveryInfoText(
                    text: 'Відділення: ${order['postOfficeNumber']}'),
                order['comment'] != '' ? const MyDivider() : Container(),
                order['comment'] != ''
                    ? DeliveryInfoText(
                        text: 'Коментар до замовлення: ${order['comment']}')
                    : Container(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryInfoText extends StatelessWidget {
  final String text;
  const DeliveryInfoText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        height: 1.4,
        fontSize: 15,
      ),
    );
  }
}
