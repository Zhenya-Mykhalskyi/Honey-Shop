import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/cart.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/separator.dart';
import 'package:honey/widgets/title_appbar.dart';
import 'package:honey/widgets/custom_button.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _formkey = GlobalKey<FormState>();
  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _postOfficeNumberController = TextEditingController();
  final _commentController = TextEditingController();

  bool _isLoading = false;

  final List<String> _deliveries = ['Укрпошта', 'Нова пошта'];
  String? _selectedDelivery;

  void _submitForm() {
    if (_formkey.currentState!.validate()) {
      final Map<String, dynamic> orderData = {
        'lastName': _lastNameController.text,
        'firstName': _firstNameController.text,
        'phoneNumber': '+380${_phoneNumberController.text}',
        'address': _addressController.text,
        'patronymic': _patronymicController.text,
        'postOfficeNumber': _postOfficeNumberController.text,
        'comment': _commentController.text,
      };
      saveOrderToFirestore(orderData);
      _resetProductsdata();
    }
  }

  Future<void> saveOrderToFirestore(Map<String, dynamic> orderData) async {
    final popContext = Navigator.of(context);
    final scaffoldContext = ScaffoldMessenger.of(context);
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text('Немає з\'єднання з Інтернетом'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      final CollectionReference ordersCollection =
          FirebaseFirestore.instance.collection('orders');
      await ordersCollection.add(orderData);
      popContext.pop();
      popContext.pop();
    } catch (e) {
      print('Error saving order: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetProductsdata() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    // final productsProvider =
    //     Provider.of<ProductsProvider>(context, listen: false);
    cartProvider.clear();
    // productsProvider.resetLitersForAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return Scaffold(
      appBar: const TitleAppBar(title: 'Оформлення замовлення'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const Text(
                      'Для здійснення покупки, будь ласка, заповніть форму на цій сторінці, і ми звʼяжемось з Вами в найкоротші терміни :)',
                      style: TextStyle(fontSize: 16),
                    ),
                    const MySeparator(),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/img/appbar_title_left.png'),
                        const Text(
                          'Особиста інформація',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Image.asset('assets/img/appbar_title_right.png'),
                      ],
                    ),
                    Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          CustomTextField(
                              hintText: 'Прізвище',
                              keyboardType: TextInputType.name,
                              maxLength: 20,
                              controller: _lastNameController,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length >= 20) {
                                  return 'Введіть коректне прізвище';
                                }
                                return null;
                              }),
                          CustomTextField(
                              hintText: 'Імʼя',
                              keyboardType: TextInputType.name,
                              maxLength: 25,
                              controller: _firstNameController,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length >= 25) {
                                  return 'Введіть коректне імʼя';
                                }
                                return null;
                              }),
                          CustomTextField(
                              hintText: 'По батькові',
                              keyboardType: TextInputType.name,
                              maxLength: 20,
                              controller: _patronymicController,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length >= 20) {
                                  return 'По батькові введено невірно';
                                }
                                return null;
                              }),
                          CustomTextField(
                            hintText: 'Номер телефону',
                            prefix: const Text('+380 '),
                            keyboardType: TextInputType.phone,
                            maxLength: 12,
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
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/img/appbar_title_left.png'),
                              const Text(
                                'Інформація доставки',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              Image.asset('assets/img/appbar_title_right.png'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                              hintText: 'Місто / населений пункт',
                              keyboardType: TextInputType.name,
                              maxLength: 30,
                              controller: _addressController,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length >= 30) {
                                  return 'Населений пункт введено невірно';
                                }
                                return null;
                              }),
                          const SizedBox(height: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 5),
                                child: Text(
                                  'Спосіб доставки',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 169, 169, 169),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: DropdownButtonFormField<String>(
                                  focusColor: AppColors.primaryColor,
                                  dropdownColor:
                                      const Color.fromARGB(255, 64, 64, 64),
                                  value: _selectedDelivery,
                                  items: _deliveries.map((delivery) {
                                    return DropdownMenuItem<String>(
                                      value: delivery,
                                      child: Text(delivery),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedDelivery = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Виберіть спосіб доставки';
                                    }
                                    return null;
                                  },
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.all(8),
                                    counterText: '',
                                    border: InputBorder.none,
                                    prefixStyle: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              CustomTextField(
                                  hintText: _selectedDelivery == 'Нова пошта'
                                      ? 'Номер відділення'
                                      : 'Поштовий індекс та адреса відділення',
                                  maxLength: 65,
                                  maxLines:
                                      _selectedDelivery == 'Нова пошта' ? 1 : 2,
                                  controller: _postOfficeNumberController,
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.length >= 40) {
                                      return 'Введіть номер поштового відділення або адресу з індексом';
                                    }
                                    return null;
                                  }),
                              CustomTextField(
                                  hintText:
                                      'Коментар до замовленя (100 символів)',
                                  maxLength: 100,
                                  maxLines: 4,
                                  controller: _commentController,
                                  validator: (value) {
                                    if (value!.length >= 100) {
                                      return 'Коментар не повинен перевищувати 100 символів';
                                    }
                                    return null;
                                  }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const MySeparator(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Загальна сума',
                          style: TextStyle(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 22),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white.withOpacity(0.1)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            child: Text(
                              '₴ ${cartProvider.totalAmountOfCart.toString()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const MySeparator(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: CustomButton(
                          action: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  backgroundColor:
                                      const Color.fromARGB(255, 27, 27, 27),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(height: 15),
                                        const Text(
                                          'Підтвердити замовлення?',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'MA',
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 15),
                                        ButtonBar(
                                          alignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.of(context).pop();
                                                _submitForm();
                                              },
                                              child: const Text(
                                                'Так',
                                                style: TextStyle(
                                                  fontFamily: 'MA',
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text(
                                                'Повернутися',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'MA'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          text: 'Підтвердити замовлення'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Widget? prefix;
  final TextInputType? keyboardType;
  final int maxLength;
  final int? maxLines;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefix,
    this.keyboardType,
    required this.maxLength,
    this.maxLines,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              hintText,
              style: const TextStyle(
                color: Color.fromARGB(255, 169, 169, 169),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextFormField(
              validator: validator,
              cursorColor: AppColors.primaryColor,
              maxLines: maxLines ?? 1,
              controller: controller,
              maxLength: maxLength,
              keyboardType: keyboardType,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(8),
                counterText: '',
                border: InputBorder.none,
                prefix: prefix,
                prefixStyle: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
