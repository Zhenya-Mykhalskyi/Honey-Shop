import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      // Navigator.pop(context);
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
                    const Color.fromARGB(255, 255, 179, 0)),
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
