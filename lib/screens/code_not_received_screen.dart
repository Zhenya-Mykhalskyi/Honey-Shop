import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:honey/main.dart';
import 'package:honey/providers/theme_provider.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/widgets/custom_divider.dart';
import 'package:honey/widgets/title_appbar.dart';

class CodeNotReceivedScreen extends StatefulWidget {
  const CodeNotReceivedScreen({super.key});

  @override
  State<CodeNotReceivedScreen> createState() => _CodeNotReceivedScreenState();
}

class _CodeNotReceivedScreenState extends State<CodeNotReceivedScreen> {
  String? adminEmail;

  @override
  void initState() {
    _getAdminEmail();
    super.initState();
  }

  Future<void> _getAdminEmail() async {
    try {
      final adminDocRef =
          FirebaseFirestore.instance.collection('admin').doc('data');
      final adminSnapshot = await adminDocRef.get();

      if (adminSnapshot.exists) {
        final adminData = adminSnapshot.data();
        setState(() {
          adminEmail = adminData?['adminEmail'];
        });
      }
    } catch (e) {
      print('Error fetching admin data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TitleAppBar(title: 'Не прийшов код?'),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    const MyDivider(),
                    const SizedBox(height: 25),
                    const Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        'Пройшло більше 3 хв, але код не прийшов - напишіть нам на e-mail:',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        adminEmail ?? 'Loading...',
                        style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Image.asset('assets/img/illustration_of_email.png'),
                    const SizedBox(height: 25),
                    const MyDivider(
                      verticalPadding: 0,
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Transform.rotate(
                      angle: pi,
                      child: Image.asset(
                        './assets/img/auth_screen_background.png',
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: CustomButton(
                        action: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MyApp()));
                        },
                        text: 'Повернутися до реєстрації',
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
