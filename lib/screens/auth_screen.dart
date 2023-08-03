import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/custom_button.dart';
import 'otp_screen.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _phonecontroller = TextEditingController();
  final TextEditingController _namecontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isFocused = false;
  AuthMode _authMode = AuthMode.Signup;

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
    final phoneNumber = '+380${_phonecontroller.text}';
    bool exists = await checkPhoneNumberExists(phoneNumber);
    if (_authMode == AuthMode.Login && !exists) {
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text('Такого користувача не існує.  Зареєструйтеся.'),
        ),
      );
      return;
    }
    if (_authMode == AuthMode.Signup && exists) {
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
        builder: (context) =>
            OTPScreen(_phonecontroller.text, _namecontroller.text, _authMode),
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
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
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
                margin: const EdgeInsets.only(top: 40),
                child: Stack(
                  children: [
                    Image.asset(
                      './assets/img/auth_screen_background.png',
                      width: 1000,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 60, left: 20, right: 20),
                      child: Text(
                        _authMode == AuthMode.Signup
                            ? 'Введіть необхідні для реєстрації дані та дочекайтеся коду підтвердження :)'
                            : 'Введіть номер телефону для входу та дочекайтеся коду підтвердження :)',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'MA',
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                          color: AppColors.primaryColor,
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
                        decoration: _authMode == AuthMode.Signup
                            ? BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primaryColor,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(9.0),
                              )
                            : null,
                        child: _authMode == AuthMode.Signup
                            ? TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  counterText: '',
                                  hintText: 'Ваше імʼя',
                                  hintStyle: TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                ),
                                maxLength: 15,
                                controller: _namecontroller,
                                validator: (value) {
                                  if (value!.isEmpty || value.length < 2) {
                                    return 'Невірно введене імʼя';
                                  }
                                  return null;
                                },
                              )
                            : Container(),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                        child: TextFormField(
                          decoration: InputDecoration(
                            prefix: !isFocused ? null : const Text('+380 '),
                            border: InputBorder.none,
                            hintText: 'Номер телефону',
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.transparent,
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
              ),
              const SizedBox(
                height: 30,
              ),
              CustomButton(
                action: () {
                  _submitForm();
                },
                text:
                    _authMode == AuthMode.Signup ? 'Зареєструватися' : 'Увійти',
              ),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(
                  _authMode == AuthMode.Signup
                      ? 'Уже існує аккаунт? Увійдіть'
                      : 'Не має акаунту? Зареєструйтеся',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
