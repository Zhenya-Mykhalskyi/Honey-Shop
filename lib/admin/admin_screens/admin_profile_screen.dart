import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/my_divider.dart';
import 'package:honey/widgets/title_appbar.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

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
              // Card(
              //   color: Colors.white.withOpacity(0.1),
              //   elevation: 2,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(9),
              //   ),
              //   child: Container(
              //     padding: const EdgeInsets.all(12),
              //     child: IntrinsicHeight(
              //       child: Row(
              //         children: [
              //           Expanded(
              //             flex: 4,
              //             child: AspectRatio(
              //               aspectRatio: 1,
              //               child: Container(
              //                 decoration: BoxDecoration(
              //                   borderRadius: BorderRadius.circular(8),
              //                   border: Border.all(
              //                     color: Colors.white,
              //                   ),
              //                 ),
              //                 child: ClipRRect(
              //                   borderRadius: BorderRadius.circular(10),
              //                   child: imageUrl == null
              //                       ? const Icon(
              //                           Icons.person_rounded,
              //                           color: Colors.white,
              //                           size: 85,
              //                         )
              //                       : AspectRatio(
              //                           aspectRatio: 1,
              //                           child: CachedNetworkImage(
              //                             key: _profileImageKey,
              //                             placeholder: (context, url) =>
              //                                 const CircularProgressIndicator(
              //                               color: AppColors.primaryColor,
              //                             ),
              //                             imageUrl: imageUrl!,
              //                             fit: BoxFit.cover,
              //                           ),
              //                         ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //           const SizedBox(width: 14),
              //           Expanded(
              //             flex: 7,
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Column(
              //                   children: [
              //                     ProfileInfoCardSingleRow(
              //                       icon: Icons.person_2_outlined,
              //                       text: userName.toString(),
              //                     ),
              //                     const SizedBox(height: 7),
              //                     ProfileInfoCardSingleRow(
              //                       icon: Icons.phone_outlined,
              //                       text: phoneNumber.toString(),
              //                     ),
              //                   ],
              //                 ),
              //                 const ProfileInfoCardSingleRow(
              //                   icon: Icons.star_border_sharp,
              //                   text: 'Мої бонуси:',
              //                   color: AppColors.primaryColor,
              //                   fontWeight: FontWeight.w700,
              //                 ),
              //               ],
              //             ),
              //           ),
              //           Column(
              //             mainAxisAlignment: MainAxisAlignment.start,
              //             children: [
              //               IconButton(
              //                 onPressed: () {
              //                   Navigator.of(context).push(MaterialPageRoute(
              //                     builder: (context) => const OrdersScreen(
              //                       isEditProfile: true,
              //                     ),
              //                   ));
              //                 },
              //                 icon: const Icon(
              //                   Icons.edit,
              //                   color: Color.fromARGB(255, 217, 217, 217),
              //                   size: 22,
              //                 ),
              //               ),
              //             ],
              //           )
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 15),

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
