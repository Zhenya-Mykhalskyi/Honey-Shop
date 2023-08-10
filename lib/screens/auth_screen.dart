import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/widgets/custom_text_field.dart';
import 'package:honey/widgets/my_divider.dart';
import 'otp_screen.dart';

enum AuthMode { signup, login }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isFocused = false;
  AuthMode _authMode = AuthMode.signup;

  Future<void> _submitForm() async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    final navContext = Navigator.of(context);
    final hasInternetConnection =
        await CheckConnectivityUtil.checkInternetConnectivity(context);
    if (!hasInternetConnection) {
      return;
    }
    if (!_formKey.currentState!.validate()) {
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text('Номер телефону або імʼя введено невірено'),
        ),
      );
      return;
    }
    final phoneNumber = '+380${_phoneNumberController.text}';
    bool exists = await checkPhoneNumberExists(phoneNumber);
    if (_authMode == AuthMode.login && !exists) {
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text('Такого користувача не існує.  Зареєструйтеся.'),
        ),
      );
      return;
    }
    if (_authMode == AuthMode.signup && exists) {
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text('Такий користувач вже існує.  Увійдіть в акаунт.'),
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    navContext.push(
      MaterialPageRoute(
        builder: (context) => OTPScreen(
            _phoneNumberController.text, _nameController.text, _authMode),
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

  void _switchAuthMode() {
    if (_authMode == AuthMode.login) {
      setState(() {
        _authMode = AuthMode.signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Image.asset('./assets/img/logo.png'),
        ),
        leadingWidth: 85,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.04),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            './assets/img/auth_screen_background.png',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 60, left: 20, right: 20),
                          child: Text(
                            _authMode == AuthMode.signup
                                ? 'Введіть необхідні для реєстрації дані та дочекайтеся коду підтвердження :)'
                                : 'Введіть номер телефону для входу та дочекайтеся коду підтвердження :)',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'MA',
                              fontSize: 20,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const MyDivider(verticalPadding: 0),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Container(
                  margin: const EdgeInsets.only(top: 15, right: 10, left: 10),
                  child: Column(
                    children: [
                      _authMode == AuthMode.signup
                          ? CustomTextField(
                              hintText: 'Ваше імʼя',
                              maxLength: 15,
                              controller: _nameController,
                              validator: (value) {
                                if (value!.isEmpty || value.length < 2) {
                                  return 'Невірно введене імʼя';
                                }
                                return null;
                              },
                            )
                          : Container(),
                      CustomTextField(
                        hintText: 'Ваш номер телефону',
                        prefix: const Text('+380 '),
                        keyboardType: TextInputType.phone,
                        maxLength: 9,
                        textSize: 17,
                        controller: _phoneNumberController,
                        validator: (value) {
                          final regExp = RegExp(r'^\+380[0-9]{9}$');
                          if (value == null ||
                              value.isEmpty ||
                              !regExp.hasMatch('+380$value')) {
                            return 'Невірний номер телефону!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30)
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  const MyDivider(verticalPadding: 0),
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
                        child: Column(
                          children: [
                            CustomButton(
                              action: () {
                                _submitForm();
                              },
                              text: _authMode == AuthMode.signup
                                  ? 'Зареєструватися'
                                  : 'Увійти',
                            ),
                            TextButton(
                              onPressed: _switchAuthMode,
                              child: Text(
                                _authMode == AuthMode.signup
                                    ? 'Уже існує аккаунт? Увійдіть'
                                    : 'Не має акаунту? Зареєструйтеся',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
