import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';

import 'package:honey/widgets/custom_confirm_dialog.dart';
import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/providers/cart_provider.dart';
import 'package:honey/providers/theme_provider.dart';
import 'package:honey/widgets/custom_divider.dart';
import 'package:honey/widgets/title_appbar.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/widgets/total_amount.dart';
import 'package:honey/widgets/custom_text_field.dart';
import 'package:honey/widgets/edit_form_image.dart';
import 'user_main_screen.dart';
import 'package:honey/main.dart';

class OrderAndEditProfileScreen extends StatefulWidget {
  final Map<String, CartItemModel>? cartData;
  final bool isEditProfile;
  final double? finalAmount;
  final bool? useBonuses;
  final num? bonuses;

  const OrderAndEditProfileScreen({
    super.key,
    this.cartData,
    required this.isEditProfile,
    this.finalAmount,
    this.useBonuses,
    this.bonuses,
  });

  @override
  State<OrderAndEditProfileScreen> createState() =>
      _OrderAndEditProfileScreenState();
}

class _OrderAndEditProfileScreenState extends State<OrderAndEditProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _postOfficeNumberController = TextEditingController();
  final _commentController = TextEditingController();

  final List<String> _deliveries = ['Укрпошта', 'Нова пошта'];
  String? _selectedDelivery;
  String? _currentProfileImage;

  bool _isLoading = false;

  @override
  void initState() {
    _fetchUserDataFromFirestore();
    super.initState();
  }

  Future<void> _fetchUserDataFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      try {
        setState(() {
          _isLoading = true;
        });

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          setState(() {
            _usernameController.text = userData?['name'] ?? '';
            _fullNameController.text = userData?['fullName'] ?? '';
            _phoneNumberController.text =
                userData?['phoneNumber']?.substring(4) ?? '';
            _addressController.text = userData?['address'] ?? '';
            _postOfficeNumberController.text =
                userData?['postOfficeNumber'] ?? '';
            _selectedDelivery = userData?['selectedDelivery'] ?? '';
            _currentProfileImage = userData?['profileImage'];
          });
        } else {
          print('User document does not exist for id: $userId');
        }
      } catch (e) {
        print("Error fetching user data: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    final navigatorContext = Navigator.of(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (_formkey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final hasInternetConnection =
          await CheckConnectivityUtil.checkInternetConnectivity(context);
      if (!hasInternetConnection) {
        return;
      }
      if (user == null) {
        return;
      }

      await _saveUserDataToFirestore();

      if (!widget.isEditProfile) {
        final orderData = _buildOrderData(cartProvider, user);
        await _saveOrderToFirestore(orderData);
        await _saveUserDataToFirestore();
        _resetProductsdata();
        _resetUserBonuses();
      }

      navigatorContext.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) =>
              const UserMainScreen(selectedBottomNavBarIndex: 0),
        ),
        (route) => false,
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _buildOrderData(CartProvider cartProvider, User? user) {
    final DateTime dateTimeNow = DateTime.now();
    final String date =
        '${dateTimeNow.day.toString().padLeft(2, '0')}.${dateTimeNow.month.toString().padLeft(2, '0')}.${dateTimeNow.year}';
    final String time =
        '${dateTimeNow.hour.toString().padLeft(2, '0')}:${dateTimeNow.minute.toString().padLeft(2, '0')}';

    final orderData = {
      'fullName': _fullNameController.text,
      'phoneNumber': '+380${_phoneNumberController.text}',
      'address': _addressController.text,
      'selectedDelivery': _selectedDelivery,
      'postOfficeNumber': _postOfficeNumberController.text,
      'comment': _commentController.text,
      'userId': user!.uid,
      'totalAmount': widget.finalAmount,
      'date': date,
      'time': time,
      'timestamp': dateTimeNow,
      'isFinished': false,
      'isVisibleForAdmin': true,
      'usedBonuses': widget.useBonuses == true ? widget.bonuses : 0,
      'products': widget.cartData?.map((productId, cartItem) {
        return MapEntry(productId, {
          'id': cartItem.id,
          'title': cartItem.title,
          'liters': cartItem.liters,
          'price': cartItem.price,
          'imageUrl': cartItem.imageUrl,
        });
      }),
    };
    return orderData;
  }

  Future<void> _saveOrderToFirestore(Map<String, dynamic> orderData) async {
    try {
      final CollectionReference ordersCollection =
          FirebaseFirestore.instance.collection('orders');
      final DocumentReference newOrderRef =
          await ordersCollection.add(orderData);

      final String orderId = newOrderRef.id;
      orderData['orderId'] = orderId;
      await newOrderRef.update(orderData);
    } catch (e) {
      print('Error saving order: $e');
    }
  }

  Future<void> _saveUserDataToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final userData = {
        'name': _usernameController.text,
        'fullName': _fullNameController.text,
        'deliveryPhoneNumber': '+380${_phoneNumberController.text}',
        'address': _addressController.text,
        'selectedDelivery': _selectedDelivery,
        'postOfficeNumber': _postOfficeNumberController.text,
      };

      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      await usersCollection
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
      if (_pickedImage != null) {
        await _uploadProfileImageToStorageAndFirestore(_pickedImage!);
      }
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  File? _pickedImage;
  void _handleImagePicked(File? image) {
    setState(() {
      _pickedImage = image;
    });
  }

  Future<void> _uploadProfileImageToStorageAndFirestore(File imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profile_images')
          .child('${user.uid}.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;
      final imageUrl = await taskSnapshot.ref.getDownloadURL();

      final userData = {
        'profileImage': imageUrl,
      };

      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');
      await usersCollection
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _resetUserBonuses() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        if (widget.useBonuses == true) {
          await userDoc.update({'bonuses': 0});
        }
      }
    } catch (e) {
      print("Error updating user bonuses: $e");
    }
  }

  void _resetProductsdata() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.clear();
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(
        title: widget.isEditProfile
            ? 'Редагування профіля'
            : 'Оформлення замовлення',
        action: () {
          if (widget.isEditProfile == true) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ConfirmationDialog(
                  title: 'Впевнені, що хочете вийти з акаунту?',
                  confirmButtonText: 'Так',
                  cancelButtonText: 'Повернутися',
                  onConfirm: () async {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const MyApp()),
                        (route) => false);
                    _logout(context);
                  },
                );
              },
            );
          }
        },
        showIconButton: widget.isEditProfile == true ? true : false,
        icon: Icons.logout,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ))
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: 15,
                    top: !widget.isEditProfile ? 15 : 0),
                child: Column(
                  children: [
                    !widget.isEditProfile
                        ? const Text(
                            'Для здійснення покупки, будь ласка, заповніть форму на цій сторінці, і ми звʼяжемось з Вами в найкоротші терміни :)',
                            style: TextStyle(fontSize: 16),
                          )
                        : Container(),
                    !widget.isEditProfile ? const MyDivider() : Container(),
                    const SizedBox(height: 30),
                    !widget.isEditProfile
                        ? const SectionTitle(text: 'Особиста інформація')
                        : Container(),
                    Form(
                      key: _formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.isEditProfile
                              ? Row(
                                  children: [
                                    EditFormImage(
                                      onImagePicked: _handleImagePicked,
                                      currentProfileImage: _currentProfileImage,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: CustomTextField(
                                        hintText: 'Ваше імʼя',
                                        maxLength: 15,
                                        maxLines: 1,
                                        textSize: 17,
                                        controller: _usernameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Будь ласка, введіть Ваше імʼя';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                          widget.isEditProfile
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 30),
                                  child:
                                      SectionTitle(text: 'Інформація доставки'),
                                )
                              : Container(),
                          const SizedBox(height: 15),
                          CustomTextField(
                              hintText: 'Ваше повне імʼя (ПІБ)',
                              keyboardType: TextInputType.name,
                              maxLength: 100,
                              textSize: 17,
                              controller: _fullNameController,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.length >= 100) {
                                  return 'Введіть коректне прізвище, імʼя та по батькові';
                                }
                                return null;
                              }),
                          CustomTextField(
                            hintText: 'Номер телефону для доставки',
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
                          !widget.isEditProfile
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child:
                                      SectionTitle(text: 'Інформація доставки'),
                                )
                              : Container(),
                          const SizedBox(height: 10),
                          CustomTextField(
                              hintText: 'Місто / населений пункт',
                              keyboardType: TextInputType.name,
                              maxLength: 30,
                              textSize: 17,
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
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              'Спосіб доставки',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.6),
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
                              dropdownColor: Theme.of(context).canvasColor,
                              value: _selectedDelivery == ''
                                  ? null
                                  : _selectedDelivery,
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
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(8),
                                counterText: '',
                                border: InputBorder.none,
                                prefixStyle: TextStyle(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.6),
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                              hintText: _selectedDelivery == 'Нова пошта'
                                  ? 'Номер відділення або поштомата'
                                  : 'Поштовий індекс та адреса відділення',
                              maxLength: 50,
                              textSize: 17,
                              maxLines:
                                  _selectedDelivery == 'Нова пошта' ? 1 : 2,
                              controller: _postOfficeNumberController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введіть номер поштового відділення або адресу з індексом';
                                }
                                return null;
                              }),
                          !widget.isEditProfile
                              ? CustomTextField(
                                  hintText:
                                      'Коментар до замовленя (100 символів)',
                                  maxLength: 100,
                                  maxLines: 4,
                                  controller: _commentController,
                                  validator: (value) {
                                    return null;
                                  })
                              : Container(),
                        ],
                      ),
                    ),
                    !widget.isEditProfile
                        ? Column(
                            children: [
                              const SizedBox(height: 20),
                              const MyDivider(),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Загальна сума',
                                    style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22),
                                  ),
                                  TotalAmountOfCart(
                                    totalAmount: widget.finalAmount!,
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              const MyDivider(),
                            ],
                          )
                        : Container(),
                    CustomButton(
                      action: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ConfirmationDialog(
                              title: widget.isEditProfile
                                  ? 'Зберегти зміни?'
                                  : 'Підтвердити замовлення?',
                              confirmButtonText: 'Так',
                              confirmButtonColor:
                                  Theme.of(context).primaryColor,
                              cancelButtonText: 'Повернутися',
                              onConfirm: () async {
                                Navigator.of(context).pop();
                                await _submitForm(context);
                              },
                            );
                          },
                        );
                      },
                      text: widget.isEditProfile
                          ? 'Зберегти зміни'
                          : 'Підтвердити замовлення',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset('assets/img/appbar_title_left.png'),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        Image.asset('assets/img/appbar_title_right.png'),
      ],
    );
  }
}
