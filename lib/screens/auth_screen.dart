import 'package:flutter/material.dart';
// import 'package:phone_number/phone_number.dart';

import '../services/otp.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

// Future<bool> isValidPhoneNumber(String phoneNumber) async {
//     final phoneNumberUtil = PhoneNumberUtil();
//     final PhoneNumber number = await phoneNumberUtil.parse(phoneNumber);
//     return phoneNumberUtil.isValidNumber(number);
//   }

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Honey')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 60),
              child: const Center(
                child: Text(
                  'Введіть свій номер телефону',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 40, right: 10, left: 10),
              child: TextField(
                decoration: const InputDecoration(
                    hintText: '  Phone number',
                    hintStyle: TextStyle(color: Colors.white),
                    prefix: Text('+380')),
                maxLength: 10,
                keyboardType: TextInputType.number,
                controller: _controller,
              ),
            )
          ]),
          Container(
            margin: const EdgeInsets.all(10),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // String phoneNumber = '+380${_controller.text}';
                // bool? isValid = await isValidPhoneNumber(phoneNumber);
                // if (isValid) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => OTPScreen(_controller.text),
                ));
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text('Невірний номер телефону'),
                //     ),
                //   );
                // }
              },
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
