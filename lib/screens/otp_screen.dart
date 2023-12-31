// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pinput/pinput.dart';

import 'package:honey/providers/theme_provider.dart';
import 'package:honey/widgets/custom_divider.dart';
import 'package:honey/widgets/title_appbar.dart';
import 'code_not_received_screen.dart';
import 'package:honey/main.dart';
import 'auth_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String name;
  final AuthMode _authMode;
  const OTPScreen(this.phone, this.name, this._authMode, {super.key});
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String? _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();

  final defaultPinTheme = PinTheme(
    width: 56,
    height: 56,
    textStyle: const TextStyle(
        fontSize: 20,
        color: AppColors.primaryColor,
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.primaryColor),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  @override
  void initState() {
    _verifyPhone();
    super.initState();
  }

  void _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+380${widget.phone}',
      codeSent: _onCodeSent,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 120),
    );
  }

  void _onCodeSent(String? verificationID, int? resendToken) {
    setState(() {
      _verificationCode = verificationID;
    });
  }

  void _onVerificationAndPinCompleted(String pin,
      {PhoneAuthCredential? credential}) async {
    try {
      credential ??= PhoneAuthProvider.credential(
        verificationId: _verificationCode!,
        smsCode: pin,
      );

      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      String uid = authResult.user!.uid;
      _handleVerificationSuccess(widget.name, widget.phone, uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Код введено невірно. Повторіть спробу.'),
      ));
    }
  }

  void _onPinCompleted(String pin) {
    _onVerificationAndPinCompleted(pin);
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) {
    _onVerificationAndPinCompleted('', credential: credential);
  }

  void _handleVerificationSuccess(String name, String phone, String uid) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      if (widget._authMode == AuthMode.signup) {
        try {
          await usersCollection.doc(uid).set({
            'phoneNumber': '+380$phone',
            'name': name,
          });
        } catch (error) {
          print('Error saving user data: $error');
        }
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
        (route) => false,
      );
    } catch (error) {
      print('Error saving user data: $error');
    }
  }

  void _onVerificationFailed(FirebaseAuthException e) {
    print(e.message);
  }

  void _onCodeAutoRetrievalTimeout(String verificationID) {
    setState(() {
      _verificationCode = verificationID;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: const TitleAppBar(title: 'Верифікація номера'),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  const MyDivider(),
                  const SizedBox(height: 20),
                  const Text(
                    'Введіть код надісланий на номер:',
                    style: TextStyle(fontSize: 19),
                  ),
                  Text(
                    '+380 ${widget.phone}',
                    style: const TextStyle(fontSize: 20),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Pinput(
                      length: 6,
                      defaultPinTheme: defaultPinTheme,
                      controller: _pinPutController,
                      pinAnimationType: PinAnimationType.fade,
                      onCompleted: _onPinCompleted,
                    ),
                  ),
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
                    padding: const EdgeInsets.only(top: 30),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const CodeNotReceivedScreen()));
                      },
                      child: const Text(
                        'Не приходить код?',
                        style: TextStyle(color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
