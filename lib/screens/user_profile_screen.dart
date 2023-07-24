import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/my_divider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? userName;

  @override
  void initState() {
    _fetchUserName();
    super.initState();
  }

  void _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          final userNameData = userDoc.data()?['name'];
          print('Fetched user name: $userNameData');
          setState(() {
            userName = userNameData;
          });
        } else {
          print('User document does not exist for id: ${user.uid}');
        }
      } else {
        print('User is not logged in.');
      }
    } catch (e) {
      print("Error fetching user name: $e");
    }
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
    final user = FirebaseAuth.instance.currentUser;

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
                                  const SizedBox(height: 9),
                                  ProfileInfoCardSingleRow(
                                    icon: Icons.phone_outlined,
                                    text: user!.phoneNumber.toString(),
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
                        IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.edit,
                              color: Color.fromARGB(255, 217, 217, 217),
                              size: 25,
                            ))
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DeliveryInfoSingleText(
                            text: 'Євгеній Михальський'),
                        DeliveryInfoSingleText(
                            text: user.phoneNumber.toString()),
                        const DeliveryInfoSingleText(text: 'м. Тернопіль'),
                        const DeliveryInfoSingleText(text: 'УкрПошта'),
                        const DeliveryInfoSingleText(
                            text: '46003 Клопотенка 44'),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const MyDivider(),
                    const SizedBox(height: 30),
                    const Text(
                      'Мої замовлення:',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 18),
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
        Icon(icon, color: color ?? Colors.white),
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
