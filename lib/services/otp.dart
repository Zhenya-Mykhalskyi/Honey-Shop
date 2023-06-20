import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honey/screens/products_overview_screen.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  final String name;
  OTPScreen(this.phone, this.name);
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

  Future<void> handleVerificationSuccess(String name, String phone) async {
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // QuerySnapshot querySnapshot = await usersCollection
      //     .where('phoneNumber', isEqualTo: '+380$phone')
      //     .get();

      // if (querySnapshot.docs.isNotEmpty) {
      //   final GlobalKey<ScaffoldState> _scaffoldKey =
      //       GlobalKey<ScaffoldState>();
      //   // Користувач з таким номером вже існує
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Користувач з таким номером вже існує')),
      //   );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const ProductScreen()),
        (route) => false, //видалити всі маршрути крім цільового
      );
      try {
        await usersCollection.add({
          'phoneNumber': '+380$phone',
          'name': name,
        });

        print('User data saved successfully!');
      } catch (error) {
        print('Error saving user data: $error');
      }

      print('User data saved successfully!');
    } catch (error) {
      print('Error saving user data: $error');
    }
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+380${widget.phone}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        handleVerificationSuccess(widget.name, widget.phone);
      },
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String? verficationID, int? resendToken) {
        setState(() {
          _verificationCode = verficationID;
        });
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        setState(() {
          _verificationCode = verificationID;
        });
      },
      timeout: const Duration(seconds: 120),
    );
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
              onCompleted: (pin) async {
                try {
                  await FirebaseAuth.instance.signInWithCredential(
                      PhoneAuthProvider.credential(
                          verificationId: _verificationCode!, smsCode: pin));
                  handleVerificationSuccess(widget.name, widget.phone);
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
