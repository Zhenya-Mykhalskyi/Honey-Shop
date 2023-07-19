import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:honey/widgets/app_colors.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.black),
                backgroundColor: MaterialStateProperty.all(
                  AppColors.primaryColor,
                ),
              ),
              onPressed: () => _logout(context),
              child: const Text('Вийти з акаунту'),
            ),
          ],
        ),
      ),
    );
  }
}
