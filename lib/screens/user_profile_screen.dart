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
    super.initState();
    _fetchUserName();
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const MyDivider(),
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
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
              fontSize: 19,
              color: color ?? Colors.white,
              fontWeight: fontWeight),
        ),
      ],
    );
  }
}
