import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/providers/theme_provider.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/widgets/custom_text_field.dart';
import 'package:honey/widgets/edit_form_image.dart';
import 'package:honey/widgets/custom_divider.dart';
import 'package:honey/widgets/theme_switcher.dart';

class AdminProfileEditScreen extends StatefulWidget {
  const AdminProfileEditScreen({
    super.key,
  });

  @override
  State<AdminProfileEditScreen> createState() => _AdminProfileEditScreenState();
}

class _AdminProfileEditScreenState extends State<AdminProfileEditScreen> {
  final GlobalKey<FormState> _infoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _salesPointsFormKey = GlobalKey<FormState>();

  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPhoneNumberController = TextEditingController();
  final _aboutStoreTextController = TextEditingController();
  final List<TextEditingController> _salesPointsCityControllers = [];
  final List<TextEditingController> _salesPointsAddressControllers = [];

  String? _currentProfileImage;
  File? _pickedImage;
  bool _isLoading = false;
  final List<Map<String, String>> _salesPoints = [];

  @override
  void initState() {
    _fetchAdminDataFromFirestore();
    super.initState();
  }

  Future<void> _fetchAdminDataFromFirestore() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final docSnapshot = await FirebaseFirestore.instance
          .collection('admin')
          .doc('data')
          .get();

      final data = docSnapshot.data();
      if (data != null) {
        _adminNameController.text = data['adminName'] ?? '';
        _adminEmailController.text = data['adminEmail'] ?? '';
        _adminPhoneNumberController.text =
            data['adminPhoneNumber'].substring(4) ?? '';
        _currentProfileImage = data['adminImageUrl'] ?? '';
        _aboutStoreTextController.text = data['aboutStoreText'] ?? '';

        final salesPoints = data['salesPoints'] as List<dynamic>?;

        if (salesPoints != null) {
          _initializeSalesPoints(salesPoints);
        }
      }
    } catch (e) {
      print('Error fetching admin data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeSalesPoints(List<dynamic> salesPoints) {
    final List<Map<String, String>> initializedSalesPoints = [];

    for (var point in salesPoints) {
      final String city = point['city'] ?? '';
      final String address = point['address'] ?? '';

      initializedSalesPoints.add({
        'city': city,
        'address': address,
      });

      final cityController = TextEditingController(text: city);
      final addressController = TextEditingController(text: address);

      _salesPointsCityControllers.add(cityController);
      _salesPointsAddressControllers.add(addressController);
    }

    setState(() {
      _salesPoints.clear();
      _salesPoints.addAll(initializedSalesPoints);
    });
  }

  Future<void> _submitForm() async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    final navContext = Navigator.of(context);
    final hasInternetConnection =
        await CheckConnectivityUtil.checkInternetConnectivity(context);
    if (!hasInternetConnection) {
      return;
    }

    if (_infoFormKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
        });

        await _saveAdminDataToFirestore();
        await _saveSalesPointsToFirestore();

        scaffoldContext.showSnackBar(
          const SnackBar(content: Text('Дані успішно збережені')),
        );

        navContext.pop();
      } catch (e) {
        print('Error saving admin data: $e');
        scaffoldContext.showSnackBar(
          const SnackBar(content: Text('Не вдалося зберегти дані')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAdminDataToFirestore() async {
    final adminData = {
      'adminName': _adminNameController.text,
      'adminEmail': _adminEmailController.text,
      'adminPhoneNumber': '+380${_adminPhoneNumberController.text}',
      'adminImageUrl': _currentProfileImage,
      'aboutStoreText': _aboutStoreTextController.text,
    };

    final adminDocRef =
        FirebaseFirestore.instance.collection('admin').doc('data');
    await adminDocRef.set(adminData);

    if (_pickedImage != null) {
      await _uploadProfileImageToStorageAndFirestore(_pickedImage!);
    }
  }

  Future<void> _saveSalesPointsToFirestore() async {
    final DocumentReference adminDocRef =
        FirebaseFirestore.instance.collection('admin').doc('data');

    final List<Map<String, String>> formattedSalesPoints = [];
    for (int i = 0; i < _salesPoints.length; i++) {
      final String city = _salesPointsCityControllers[i].text;
      final String address = _salesPointsAddressControllers[i].text;
      formattedSalesPoints.add({
        'city': city.isEmpty ? _salesPoints[i]['city'] ?? '' : city,
        'address': address.isEmpty ? _salesPoints[i]['address'] ?? '' : address,
      });
    }
    await adminDocRef.update({'salesPoints': formattedSalesPoints});
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

      final adminData = {
        'adminImageUrl': imageUrl,
      };

      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('admin');
      await usersCollection.doc('data').set(adminData, SetOptions(merge: true));
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void _handleImagePicked(File? image) {
    setState(() {
      _pickedImage = image;
    });
  }

  void _addSalesPoint() {
    final cityController = TextEditingController();
    final addressController = TextEditingController();

    setState(() {
      _salesPointsCityControllers.add(cityController);
      _salesPointsAddressControllers.add(addressController);
      _salesPoints.add({
        'city': cityController.text,
        'address': addressController.text,
      });
    });
  }

  void _removeSalesPoint(int index) {
    setState(() {
      _salesPoints.removeAt(index);
      _salesPointsCityControllers.removeAt(index);
      _salesPointsAddressControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Редагування профіля',
          style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: Theme.of(context).primaryColor),
        ),
        actions: const [ThemeSwitcher()],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Form(
                                key: _infoFormKey,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        EditFormImage(
                                            onImagePicked: _handleImagePicked,
                                            currentProfileImage:
                                                _currentProfileImage),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              CustomTextField(
                                                hintText: 'Імʼя',
                                                maxLength: 20,
                                                maxLines: 1,
                                                textSize: 17,
                                                controller:
                                                    _adminNameController,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Введіть імʼя';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              CustomTextField(
                                                keyboardType:
                                                    TextInputType.phone,
                                                prefix: const Text('+380 '),
                                                hintText: 'Номер телефону',
                                                maxLength: 9,
                                                textSize: 17,
                                                controller:
                                                    _adminPhoneNumberController,
                                                validator: (value) {
                                                  final regExp = RegExp(
                                                      r'^\+380[0-9]{9}$');
                                                  if (value == null ||
                                                      value.isEmpty ||
                                                      !regExp.hasMatch(
                                                          '+380$value')) {
                                                    return 'Невірний номер телефону!';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    CustomTextField(
                                      hintText: 'Електронна адреса',
                                      maxLength: 35,
                                      maxLines: 1,
                                      textSize: 17,
                                      controller: _adminEmailController,
                                      validator: (value) {
                                        final emailRegExp = RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                        if (value!.isEmpty ||
                                            !emailRegExp.hasMatch(value)) {
                                          return 'Невірно введений email';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomTextField(
                                      hintText: 'Опис магазину',
                                      maxLength: 350,
                                      maxLines: 9,
                                      textSize: 17,
                                      showCounterText: true,
                                      controller: _aboutStoreTextController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Введіть опис магазину';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 25, bottom: 5),
                                child: Text(
                                  'Точки продажу:',
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                ),
                              ),
                              Form(
                                key: _salesPointsFormKey,
                                child: Column(
                                  children: [
                                    for (int i = 0;
                                        i < _salesPoints.length;
                                        i++)
                                      Column(
                                        children: [
                                          CustomTextField(
                                            hintText: 'Населений пункт',
                                            maxLength: 20,
                                            maxLines: 1,
                                            textSize: 17,
                                            controller:
                                                _salesPointsCityControllers[i],
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Введіть населений пункт';
                                              }
                                              return null;
                                            },
                                          ),
                                          CustomTextField(
                                            hintText: 'Адреса',
                                            maxLength: 40,
                                            maxLines: 1,
                                            textSize: 17,
                                            controller:
                                                _salesPointsAddressControllers[
                                                    i],
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Введіть адресу';
                                              }
                                              return null;
                                            },
                                          ),
                                          if (i > 0)
                                            TextButton(
                                              onPressed: () =>
                                                  _removeSalesPoint(i),
                                              child: Text('Видалити точку',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .errorColor
                                                          .withOpacity(0.7))),
                                            ),
                                          const MyDivider(),
                                        ],
                                      ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: _addSalesPoint,
                                          child: const Text(
                                            'Додати точку',
                                            style: TextStyle(
                                              color: AppColors.whiteColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  CustomButton(action: _submitForm, text: 'Зберегти дані')
                ],
              ),
            ),
    );
  }
}
