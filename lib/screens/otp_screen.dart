import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import 'package:honey/main.dart';
import 'auth_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String name;
  final AuthMode _authMode;
  const OTPScreen(this.phone, this.name, this._authMode, {super.key});
  @override
  _OTPScreenState createState() => _OTPScreenState();
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
        color: Color.fromRGBO(30, 60, 87, 1),
        fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
      borderRadius: BorderRadius.circular(20),
    ),
  );

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }

  void _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+380${widget.phone}',
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 120),
    );
  }

  void _onVerificationCompleted(PhoneAuthCredential credential) async {
    UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    String uid = authResult.user!.uid; // Отримуємо UID з FirebaseAuth
    _handleVerificationSuccess(widget.name, widget.phone, uid);
  }

  void _onVerificationFailed(FirebaseAuthException e) {
    print(e.message);
  }

  void _onCodeSent(String? verificationID, int? resendToken) {
    setState(() {
      _verificationCode = verificationID;
    });
  }

  void _onCodeAutoRetrievalTimeout(String verificationID) {
    setState(() {
      _verificationCode = verificationID;
    });
  }

  void _handleVerificationSuccess(String name, String phone, String uid) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      if (widget._authMode == AuthMode.Signup) {
        print('authmode == signup');
        try {
          await usersCollection.doc(uid).set({
            'phoneNumber': '+380$phone',
            'name': name,
          });

          print('User data saved successfully!');
        } catch (error) {
          print('Error saving user data: $error');
        }
      }
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
        (route) => false, //видалити всі маршрути крім цільового
      );
    } catch (error) {
      print('Error saving user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: const Text('OTP верифікація'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'Верифікуйте +380 ${widget.phone}',
                style: const TextStyle(
                    fontWeight: FontWeight.normal, fontSize: 26),
              ),
            ),
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
          )
        ],
      ),
    );
  }

  void _onPinCompleted(String pin) async {
    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: _verificationCode!, smsCode: pin);
      UserCredential authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      String uid = authResult.user!.uid;
      _handleVerificationSuccess(widget.name, widget.phone, uid);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
