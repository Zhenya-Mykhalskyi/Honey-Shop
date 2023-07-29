import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:honey/screens/orders_screen.dart';
import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/widgets/edit_profile_image.dart';

class AdminProfileEditScreen extends StatefulWidget {
  const AdminProfileEditScreen({
    super.key,
  });

  @override
  State<AdminProfileEditScreen> createState() => _AdminProfileEditScreenState();
}

class _AdminProfileEditScreenState extends State<AdminProfileEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _adminNameController = TextEditingController();
  final _adminEmailController = TextEditingController();
  final _adminPhoneNumberController = TextEditingController();
  String? _currentProfileImage;
  bool _isLoading = false;

  @override
  void initState() {
    _fetchAdminData();
    super.initState();
  }

  Future<void> _fetchAdminData() async {
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
        setState(() {
          _adminNameController.text = data['adminName'] ?? '';
          _adminEmailController.text = data['adminEmail'] ?? '';
          _adminPhoneNumberController.text =
              data['adminPhoneNumber'].substring(4) ?? '';
          _currentProfileImage = data['adminImageUrl'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching admin data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAdminData() async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    final navContext = Navigator.of(context);
    final hasInternetConnection =
        await CheckConnectivityUtil.checkInternetConnectivity(context);
    if (!hasInternetConnection) {
      return;
    }

    if (_formKey.currentState!.validate()) {
      final adminData = {
        'adminName': _adminNameController.text,
        'adminEmail': _adminEmailController.text,
        'adminPhoneNumber': '+380${_adminPhoneNumberController.text}',
      };

      try {
        setState(() {
          _isLoading = true;
        });
        await FirebaseFirestore.instance
            .collection('admin')
            .doc('data')
            .set(adminData);

        if (_pickedImage != null) {
          await _uploadProfileImageToStorageAndFirestore(_pickedImage!);
        }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редагування профіля'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            EditProfileImage(
                                onImagePicked: _handleImagePicked,
                                currentProfileImage: _currentProfileImage),
                            Expanded(
                              child: Column(
                                children: [
                                  CustomTextField(
                                    hintText: 'Імʼя',
                                    maxLength: 20,
                                    maxLines: 1,
                                    controller: _adminNameController,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Введіть імʼя';
                                      }
                                      return null;
                                    },
                                  ),
                                  CustomTextField(
                                    keyboardType: TextInputType.phone,
                                    prefix: const Text('+380 '),
                                    hintText: 'Номер телефону',
                                    maxLength: 12,
                                    controller: _adminPhoneNumberController,
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
                                ],
                              ),
                            ),
                          ],
                        ),
                        CustomTextField(
                          hintText: 'Електронна адреса',
                          maxLength: 35,
                          maxLines: 1,
                          controller: _adminEmailController,
                          validator: (value) {
                            final emailRegExp =
                                RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (value!.isEmpty ||
                                !emailRegExp.hasMatch(value)) {
                              return 'Невірно введений email';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  CustomButton(action: _saveAdminData, text: 'Зберегти')
                ],
              ),
            ),
    );
  }
}
