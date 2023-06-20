import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:phone_number/phone_number.dart';

import '../services/otp.dart';
import '../widgets/custom_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Номер телефону або імʼя введено невірено'),
        ),
      );
      return;
    }

    final phoneNumber = '+380${_phonecontroller.text}';
    print(phoneNumber);
    bool exists = await checkPhoneNumberExists(phoneNumber);
    if (exists) {
      print(exists);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Номер телефону вже існує'),
        ),
      );
      return;
    }
    _formKey.currentState!.save();
    print(exists);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            OTPScreen(_phonecontroller.text, _namecontroller.text),
      ),
    );
  }

  Future<bool> checkPhoneNumberExists(String phone) async {
    final CollectionReference userColection =
        FirebaseFirestore.instance.collection('users');
    QuerySnapshot querySnapshot =
        await userColection.where('phoneNumber', isEqualTo: phone).get();
    return querySnapshot.docs.isNotEmpty;
  }

  bool isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Image.asset('./assets/img/logo.png'),
        ),
        leadingWidth: 100,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 40),
              child: Stack(
                children: [
                  Image.asset(
                    './assets/img/auth_screen_background.png',
                    width: 1000,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 60, left: 20, right: 20),
                    child: Text(
                      'Введіть необхідні для реєстрації дані та дочекайтеся коду підтвердження :)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'MA',
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        color: Color.fromARGB(255, 255, 179, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Container(
                margin: const EdgeInsets.only(top: 40, right: 10, left: 10),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 179, 0),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          border: InputBorder
                              .none, // вимкнути ободок всередині текстового поля
                          hintText: 'Ваше імʼя',
                          hintStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.transparent, // прозорий фон
                        ),
                        controller: _namecontroller,
                        validator: (value) {
                          if (value!.isEmpty || value.length < 2) {
                            return 'Невірно введене імʼя';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 179, 0),
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(9.0),
                      ),
                      child: TextFormField(
                        decoration: InputDecoration(
                          prefix: !isFocused ? null : const Text('+380 '),
                          border: InputBorder.none, // вимкнути ободок
                          hintText: 'Номер телефону',
                          hintStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.transparent, // прозорий фон
                        ),
                        onTap: () {
                          setState(() {
                            isFocused = true;
                          });
                        },
                        onEditingComplete: () {
                          setState(() {
                            isFocused = false;
                          });
                        },
                        controller: _phonecontroller,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          final regExp = RegExp(r'^\+380[0-9]{9}$');
                          if (value!.isEmpty ||
                              !regExp.hasMatch('+380$value')) {
                            return 'Невірний номер телефону!';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]),
          CustomButton(action: _submit),
        ],
      ),
    );
  }
}
