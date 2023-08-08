import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:honey/screens/user_profile_screen.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/my_divider.dart';
import 'package:honey/widgets/title_appbar.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String? _adminName;
  String? _adminEmail;
  String? _adminPhoneNumber;
  String? _adminImageUrl;
  String? _aboutStoreText;
  Key _profileImageKey = UniqueKey();
  List<Map<String, String>> _salesPoints = [];
  bool? _isLoading;

  @override
  initState() {
    _fetchAdminData();
    super.initState();
  }

  Future<void> _fetchAdminData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('admin')
            .doc('data')
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();

          setState(() {
            _adminName = data?['adminName'] as String? ?? '';
            _adminEmail = data?['adminEmail'] as String? ?? '';
            _adminPhoneNumber = data?['adminPhoneNumber'] as String? ?? '';
            _adminImageUrl = data?['adminImageUrl'] as String?;
            _aboutStoreText = data?['aboutStoreText'] as String? ?? '';
            _profileImageKey = UniqueKey();

            final salesPointsData = data?['salesPoints'] as List<dynamic>?;

            if (salesPointsData != null) {
              _salesPoints = List<Map<String, String>>.from(
                salesPointsData.map((point) {
                  return {
                    'city': point['city'] as String? ?? '',
                    'address': point['address'] as String? ?? '',
                  };
                }),
              );
            }
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      body: _isLoading!
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            )
          : SingleChildScrollView(
              primary: true,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
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
                                      child: _adminImageUrl == null
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
                                                imageUrl: _adminImageUrl!,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          text: _adminName.toString(),
                                        ),
                                        const SizedBox(height: 9),
                                        ProfileInfoCardSingleRow(
                                          icon: Icons.email_outlined,
                                          text: _adminEmail.toString(),
                                        ),
                                        const SizedBox(height: 9),
                                        ProfileInfoCardSingleRow(
                                          icon: Icons.phone_outlined,
                                          text: _adminPhoneNumber.toString(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'Точки продажу',
                              style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18),
                            ),
                          ),
                          StaggeredGridView.countBuilder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            itemCount: _salesPoints.length,
                            staggeredTileBuilder: (index) =>
                                const StaggeredTile.fit(1),
                            itemBuilder: (context, index) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9)),
                                color: Colors.white.withOpacity(0.1),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _salesPoints[index]['city']
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Text(
                                                _salesPoints[index]['address']
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          Text(
                            _aboutStoreText == ''
                                ? 'Опис магазину'
                                : _aboutStoreText.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          const MyDivider(),
                          const Text('сертифікат'),
                          const MyDivider(),
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
