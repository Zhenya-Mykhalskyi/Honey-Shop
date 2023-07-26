import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:honey/screens/orders_screen.dart';

import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/my_divider.dart';
import 'package:honey/widgets/order_card.dart';

class Order {
  final String orderId;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String postOfficeNumber;
  final double totalAmount;
  final String date;
  final String time;
  final List<Map<String, dynamic>> products;
  Order({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.postOfficeNumber,
    required this.date,
    required this.time,
    required this.orderId,
    required this.userId,
    required this.totalAmount,
    required this.products,
  });
}

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

//для виклику функції fetchUserData з класу OrdersScreen після заповнення форми
  static _UserProfileScreenState? instance;
  @override
  _UserProfileScreenState createState() {
    instance = _UserProfileScreenState();
    return instance!;
  }
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? userName;
  String? phoneNumber;
  String? fullName;
  String? address;
  String? selectedDelivery;
  String? deliveryPhoneNumber;
  String? postOfficeNumber;

  late Stream<List<Order>> _ordersStream;

  @override
  void initState() {
    fetchUserData();
    _ordersStream = _fetchOrdersStream();
    super.initState();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc.data()?['name'];
            phoneNumber = user.phoneNumber;
            fullName = userDoc.data()?['fullName'];
            address = userDoc.data()?['address'];
            selectedDelivery = userDoc.data()?['selectedDelivery'];
            deliveryPhoneNumber = userDoc.data()?['deliveryPhoneNumber'];
            postOfficeNumber = userDoc.data()?['postOfficeNumber'];
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Stream<List<Order>> _fetchOrdersStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    return FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              final List<Map<String, dynamic>> products =
                  (data['products'] as Map<String, dynamic>)
                      .entries
                      .map((entry) => {
                            'id': entry.key,
                            'title': entry.value['title'],
                            'liters': entry.value['liters'],
                            'price': entry.value['price'],
                            'imageUrl': entry.value['imageUrl'],
                          })
                      .toList();
              return Order(
                orderId: doc.id,
                userId: data['userId'],
                fullName: data['fullName'],
                phoneNumber: data['phoneNumber'],
                address: data['address'],
                postOfficeNumber: data['postOfficeNumber'],
                totalAmount: double.parse(data['totalAmount']),
                date: data['date'],
                time: data['time'],
                products: products,
              );
            }).toList());
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
          child: Column(
            children: [
              Card(
                color: Colors.white.withOpacity(0.1),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Colors.white,
                                  size: 85,
                                ),
                                // child: AspectRatio(
                                //   aspectRatio: 1,
                                //   child: CachedNetworkImage(
                                //     imageUrl:
                                //     fit: BoxFit.cover,
                                //   ),
                                // ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  ProfileInfoCardSingleRow(
                                    icon: Icons.person_2_outlined,
                                    text: userName.toString(),
                                  ),
                                  const SizedBox(height: 7),
                                  ProfileInfoCardSingleRow(
                                    icon: Icons.phone_outlined,
                                    text: phoneNumber.toString(),
                                  ),
                                ],
                              ),
                              const ProfileInfoCardSingleRow(
                                icon: Icons.star_border_sharp,
                                text: 'Мої бонуси:',
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const OrdersScreen(
                                    isEditProfile: true,
                                  ),
                                ));
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Color.fromARGB(255, 217, 217, 217),
                                size: 22,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const MyDivider(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/img/delivery_info_truck.png',
                              height: 25,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Інформація доставки:',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: fullName == null
                          ? const Text(
                              'Будь ласка, зробіть перше замовлення, або заповніть дані про доставку')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DeliveryInfoSingleText(text: fullName ?? ''),
                                DeliveryInfoSingleText(
                                    text: deliveryPhoneNumber ?? ''),
                                DeliveryInfoSingleText(text: address ?? ''),
                                DeliveryInfoSingleText(
                                    text: selectedDelivery ?? ''),
                                DeliveryInfoSingleText(
                                    text: 'Відділення: $postOfficeNumber'),
                              ],
                            ),
                    ),
                    const SizedBox(height: 5),
                    const MyDivider(),
                    const Padding(
                      padding: EdgeInsets.only(top: 25, bottom: 15),
                      child: Text(
                        'Мої замовлення:',
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 18),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<List<Order>>(
                        stream: _ordersStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text(
                                'Помилка отримання замовлень: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text('Немає замовлень');
                          } else {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return OrderCard(order: snapshot.data![index]);
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () => _logout(context),
                child: const Text('Вийти з акаунту'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoCardSingleRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  const ProfileInfoCardSingleRow({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color ?? Colors.white,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
              fontSize: 17,
              color: color ?? Colors.white,
              fontWeight: fontWeight),
        ),
      ],
    );
  }
}

class DeliveryInfoSingleText extends StatelessWidget {
  final String text;
  const DeliveryInfoSingleText({
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 17, height: 1.7),
    );
  }
}
