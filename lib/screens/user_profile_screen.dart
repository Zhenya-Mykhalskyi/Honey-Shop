import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:honey/providers/theme_provider.dart';
import 'package:honey/widgets/custom_divider.dart';
import 'package:honey/widgets/order_card.dart';
import 'package:honey/widgets/profile_info_card_single_row.dart';
import 'order_and_edit_profile_screen.dart';

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
  final Timestamp timestamp;
  final num usedBonuses;
  final bool isFinished;
  final bool isDeleted;

  final List<Map<String, dynamic>> products;
  Order({
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.postOfficeNumber,
    required this.date,
    required this.time,
    required this.timestamp,
    required this.usedBonuses,
    required this.orderId,
    required this.userId,
    required this.totalAmount,
    required this.products,
    required this.isFinished,
    required this.isDeleted,
  });
}

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? _userName;
  String? _phoneNumber;
  String? _fullName;
  String? _address;
  String? _selectedDelivery;
  String? _deliveryPhoneNumber;
  String? _postOfficeNumber;
  String? _imageUrl;
  num? _bonuses;
  Key _profileImageKey = UniqueKey();

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
            _userName = userDoc.data()?['name'];
            _phoneNumber = user.phoneNumber;
            _fullName = userDoc.data()?['fullName'];
            _address = userDoc.data()?['address'];
            _selectedDelivery = userDoc.data()?['selectedDelivery'];
            _deliveryPhoneNumber = userDoc.data()?['deliveryPhoneNumber'];
            _postOfficeNumber = userDoc.data()?['postOfficeNumber'];
            _profileImageKey = UniqueKey();
            _imageUrl = userDoc.data()?['profileImage'];
            _bonuses = userDoc.data()?['bonuses'] ?? 0;
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
                  totalAmount: data['totalAmount'],
                  date: data['date'],
                  time: data['time'],
                  timestamp: data['timestamp'],
                  usedBonuses: data['usedBonuses'],
                  products: products,
                  isFinished: data['isFinished'],
                  isDeleted: data['isVisibleForAdmin']);
            }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: fetchUserData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
            child: Column(
              children: [
                Card(
                  color: Theme.of(context).cardColor,
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
                            flex: 4,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: _imageUrl == null
                                      ? Icon(
                                          Icons.person_rounded,
                                          color: Theme.of(context).primaryColor,
                                          size: 85,
                                        )
                                      : AspectRatio(
                                          aspectRatio: 1,
                                          child: CachedNetworkImage(
                                            key: _profileImageKey,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(
                                              color: AppColors.primaryColor,
                                            ),
                                            imageUrl: _imageUrl!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
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
                                      text: _userName.toString(),
                                    ),
                                    const SizedBox(height: 7),
                                    ProfileInfoCardSingleRow(
                                      icon: Icons.phone_outlined,
                                      text: _phoneNumber.toString(),
                                    ),
                                  ],
                                ),
                                ProfileInfoCardSingleRow(
                                  icon: Icons.star_border_sharp,
                                  text:
                                      'Мої бонуси: ${_bonuses?.toStringAsFixed(0)}',
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  showInfoIcon: true,
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
                                    builder: (context) =>
                                        const OrderAndEditProfileScreen(
                                      isEditProfile: true,
                                    ),
                                  ));
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
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
                Column(
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
                                  fontSize: 17),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: _fullName == null
                          ? const Text(
                              'Будь ласка, зробіть перше замовлення, або заповніть дані про доставку')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DeliveryInfoSingleText(text: _fullName ?? ''),
                                DeliveryInfoSingleText(
                                    text: _deliveryPhoneNumber ?? ''),
                                DeliveryInfoSingleText(text: _address ?? ''),
                                DeliveryInfoSingleText(
                                    text: _selectedDelivery ?? ''),
                                DeliveryInfoSingleText(
                                    text: 'Відділення: $_postOfficeNumber'),
                              ],
                            ),
                    ),
                    const SizedBox(height: 5),
                    const MyDivider(),
                    const Padding(
                      padding: EdgeInsets.only(top: 15, bottom: 15),
                      child: Text(
                        'Мої замовлення:',
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 17),
                      ),
                    ),
                    StreamBuilder<List<Order>>(
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
                          snapshot.data!.sort(
                              (a, b) => b.timestamp.compareTo(a.timestamp));
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return OrderCard(order: snapshot.data![index]);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
      style: const TextStyle(fontSize: 15, height: 1.7),
    );
  }
}
