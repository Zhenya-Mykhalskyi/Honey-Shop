import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:honey/screens/user_profile_screen.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/my_divider.dart';
import 'package:honey/widgets/title_appbar.dart';
import 'admin_profile_edit_screen.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String? adminName;
  String? adminEmail;
  String? adminPhoneNumber;
  String? adminImageUrl;
  Key _profileImageKey = UniqueKey();

  @override
  initState() {
    _fetchAdminData();
    super.initState();
  }

  Future<void> _fetchAdminData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc('data')
            .get();

        if (userDoc.exists) {
          setState(() {
            adminName = userDoc.data()?['adminName'] ?? '';
            adminEmail = userDoc.data()?['adminEmail'] ?? '';
            adminPhoneNumber = userDoc.data()?['adminPhoneNumber'] ?? '';
            adminImageUrl = userDoc.data()?['adminImageUrl'];
            _profileImageKey = UniqueKey();
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
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
    return Scaffold(
      appBar: const TitleAppBar(title: 'Інформація про нас'),
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
                          flex: 1,
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
                                child: adminImageUrl == null
                                    ? const Icon(
                                        Icons.person_rounded,
                                        color: Colors.white,
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
                                          imageUrl: adminImageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 10),
                                    child: Text(
                                      'Контакти',
                                      style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18),
                                    ),
                                  ),
                                  ProfileInfoCardSingleRow(
                                    icon: Icons.person_2_outlined,
                                    text: adminName.toString(),
                                  ),
                                  const SizedBox(height: 9),
                                  ProfileInfoCardSingleRow(
                                    icon: Icons.email_outlined,
                                    text: adminEmail.toString(),
                                  ),
                                  const SizedBox(height: 9),
                                  ProfileInfoCardSingleRow(
                                    icon: Icons.phone_outlined,
                                    text: adminPhoneNumber.toString(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Column(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: [
                        //     IconButton(
                        //       onPressed: () {
                        //         Navigator.of(context).push(MaterialPageRoute(
                        //           builder: (context) =>
                        //               const AdminProfileEditScreen(),
                        //         ));
                        //       },
                        //       icon: const Icon(
                        //         Icons.edit,
                        //         color: Color.fromARGB(255, 217, 217, 217),
                        //         size: 22,
                        //       ),
                        //     ),
                        //   ],
                        // )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Точки продажу',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    ),
                    ElevatedButton(
                      onPressed: () => _logout(context),
                      child: const Text('Вийти з акаунту'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
