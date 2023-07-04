import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:honey/widgets/custom_button.dart';

class ProductEditScreen extends StatefulWidget {
  final String productId;
  final bool isAdd;
  const ProductEditScreen(
      {Key? key, required this.productId, required this.isAdd})
      : super(key: key);

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formkey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _litersLeftController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _longDescriptionController = TextEditingController();
  String? _imageUrl; //для загрузки на firestore
  File? _pikedImage; //
  bool _isLoading = false;
  String? _currentImageUrl;
  bool _isHoney = false;

  @override
  void initState() {
    super.initState();
    getProductData();
  }

  Future<void> getProductData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (productSnapshot.exists) {
        String title =
            (productSnapshot.data() as Map<String, dynamic>)['title'];
        dynamic price =
            (productSnapshot.data() as Map<String, dynamic>)['price']
                .toStringAsFixed(2);
        String imageUrl =
            (productSnapshot.data() as Map<String, dynamic>)['imageUrl'] ?? '';
        dynamic litersLeft =
            (productSnapshot.data() as Map<String, dynamic>)['litersLeft'];
        String shortDescription = (productSnapshot.data()
                as Map<String, dynamic>)['shortDescription'] ??
            '';
        String longDescription = (productSnapshot.data()
                as Map<String, dynamic>)['longDescription'] ??
            '';
        bool isHoney =
            (productSnapshot.data() as Map<String, dynamic>)['isHoney'];
        print(isHoney);

        _priceController.text = price.toString();
        _titleController.text = title;
        _litersLeftController.text = litersLeft.toString();
        _shortDescriptionController.text = shortDescription;
        _longDescriptionController.text = longDescription;

        setState(() {
          _currentImageUrl = imageUrl;
          _isHoney = isHoney;
        });
      } else {
        !widget.isAdd ? print('Product snapshot does not exist') : null;
      }
    } catch (e) {
      // print('Error: $e');
      // Handle errors
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> addProduct(BuildContext context) async {
    final popContext = Navigator.of(context);
    final scaffoldContext = ScaffoldMessenger.of(context);
    final isValid = _formkey.currentState
        ?.validate(); //викликає всі валідатори та вертає значення true, якщо всі валідатори return null (всі дані пройшли провірку)
    if (!isValid! || _pikedImage == null) {
      return; // пририває виконання функії, код нище не буде виконуватись
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Немає з'єднання з Інтернетом
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text('Немає з\'єднання з Інтернетом'),
          duration: Duration(seconds: 3), // Тривалість показу SnackBar
        ),
      );
      return; // Перериваємо виконання функції
    }

    try {
      setState(() {
        _isLoading = true;
      });
      String newTitle = _titleController.text;
      double newPrice = double.parse(_priceController.text);
      int newLitersLeft = int.parse(_litersLeftController.text);
      String newShortDescription = _shortDescriptionController.text;
      String newLongDescription = _longDescriptionController.text;
      bool newIsHoney = _isHoney;
      if (_pikedImage != null) {
        //якщо фото вибране
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child('${newTitle.toLowerCase().replaceAll(' ', '_')}.jpg');
        final imageBytes = await _pikedImage!.readAsBytes();
        await ref.putData(imageBytes);
        _imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(newTitle.toLowerCase().replaceAll(' ', '_')) //  назва як ID
          .set({
        'title': newTitle,
        'price': newPrice,
        'imageUrl': _imageUrl,
        'litersLeft': newLitersLeft,
        'shortDescription': newShortDescription,
        'longDescription': newLongDescription,
        'isHoney': newIsHoney,
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
      popContext.pop();
    }
  }

  Future<String?> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pikedImage = File(pickedFile.path);
      });
    }
    return null;
  }

  Future<void> updateProductData(BuildContext context) async {
    final popContext = Navigator.of(context);
    final scaffoldContext = ScaffoldMessenger.of(context);
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Немає з'єднання з Інтернетом
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text('Немає з\'єднання з Інтернетом'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    final isValid = _formkey.currentState
        ?.validate(); //викликає всі валідатори та вертає значення true, якщо всі валідатори return null (всі дані пройшли провірку)
    if (!isValid! || _currentImageUrl == null) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });
      String newTitle = _titleController.text;
      double newPrice = double.parse(_priceController.text);
      int newLitersLeft = int.parse(_litersLeftController.text);
      String newShortDescription = _shortDescriptionController.text;
      String newLongDescription = _longDescriptionController.text;
      bool newIsHoney = _isHoney;
      if (_pikedImage != null) {
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('product_images')
            .child('${widget.productId}.jpg');
        final imageBytes = await _pikedImage!.readAsBytes();
        await ref.putData(imageBytes);
        _imageUrl = await ref.getDownloadURL();
      } else {
        _imageUrl = _currentImageUrl;
      }
      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
        'title': newTitle,
        'price': newPrice,
        'imageUrl': _imageUrl,
        'litersLeft': newLitersLeft,
        'shortDescription': newShortDescription,
        'longDescription': newLongDescription,
        'isHoney': newIsHoney,
      });
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
      popContext.pop();
    }
  }

  Future<void> deleteProduct(
      BuildContext context, productId, String imageUrl) async {
    final scaffoldContext = ScaffoldMessenger.of(context);
    final popContext = Navigator.of(context);
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Немає з'єднання з Інтернетом
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
      if (imageUrl.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }
      final productRef =
          FirebaseFirestore.instance.collection('products').doc(productId);
      await productRef.delete();

      print('Продукт успішно видалений.');
    } catch (error) {
      print('Сталася помилка при видаленні продукту: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
      popContext.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, actions: [
        IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: const Color.fromARGB(255, 27, 27, 27),
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
                            'Ви впевнені, що хочете видалити товар?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'MA',
                            ),
                          ),
                          const SizedBox(height: 15),
                          ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  deleteProduct(context, widget.productId,
                                      _currentImageUrl!);
                                },
                                child: const Text(
                                  'Так',
                                  style: TextStyle(
                                      color: Colors.red, fontFamily: 'MA'),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  'Скасувати',
                                  style: TextStyle(
                                      color: Colors.white, fontFamily: 'MA'),
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
            })
      ]),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 255, 179, 0)))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          Row(
                            children: [
                              Container(
                                  width: 150,
                                  height: 150,
                                  margin:
                                      const EdgeInsets.only(top: 8, right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 255, 179, 0)),
                                  ),
                                  child: widget
                                          .isAdd // додаємо чи редагуємо товар?
                                      ? _pikedImage == null
                                          ? InkWell(
                                              onTap: pickAndUploadImage,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(25.0),
                                                child: Image.asset(
                                                    'assets/img/add_photo.png'),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: pickAndUploadImage,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                  _pikedImage!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                      // редагуємо
                                      : _pikedImage != null
                                          ? InkWell(
                                              onTap: pickAndUploadImage,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                  _pikedImage!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )
                                          : InkWell(
                                              onTap: pickAndUploadImage,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  _currentImageUrl!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            )),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      hintText: 'Назва товару',
                                      maxLength: 40,
                                      maxLines: 1,
                                      controller: _titleController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Будь ласка, введіть назву товару';
                                        }
                                        if (value.toString().length >= 40) {
                                          return 'Повинна бути коротшою 40 символів';
                                        }
                                        return null;
                                      },
                                    ),
                                    CustomTextField(
                                      hintText: 'Ціна за 0.5 л',
                                      maxLength: 7,
                                      maxLines: 1,
                                      controller: _priceController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Будь ласка, введіть ціну за товар';
                                        }
                                        if (value.isEmpty) {
                                          return 'Ціна товару не може бути порожньою';
                                        }
                                        if (double.tryParse(value) == null) {
                                          return 'Повинна бути числом';
                                        }
                                        double price = double.parse(value);
                                        if (price <= 0) {
                                          return '>= 0)';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          //Перевірка чи товар являється медом
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.5,
                                child: Checkbox(
                                  fillColor: MaterialStateProperty.all<Color>(
                                    const Color.fromARGB(255, 255, 179, 0),
                                  ),
                                  checkColor: Colors.black,
                                  activeColor:
                                      const Color.fromARGB(255, 255, 179, 0),
                                  value: _isHoney,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _isHoney = value ??
                                          false; //Якщо value не є null, то воно присвоюється змінній _isHoney. Якщо value є null, то присвоюється значення false.
                                    });
                                  },
                                ),
                              ),
                              const Flexible(
                                child: Text(
                                    'Поставте галочку, якщо товар являється медом*'),
                              )
                            ],
                          ),
                          CustomTextField(
                            hintText: 'Кількість літрів',
                            maxLength: 10,
                            maxLines: 1,
                            controller: _litersLeftController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Будь ласка, введіть кількість літрів';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Повинна бути цілим числом';
                              }
                              int liters = int.parse(value);
                              if (liters <= 0) {
                                return '>= 0';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            hintText: 'Короткий опис',
                            maxLength: 200, //порахувати скільки символів*
                            maxLines: 4,
                            controller: _shortDescriptionController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Будь ласка, введіть короткий опис товару';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            hintText: 'Розгорнутий опис',
                            maxLength: 1000, //порахувати скільки символів*
                            maxLines: 6,
                            controller: _longDescriptionController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Будь ласка, введіть розгорнутий опис товару';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                      action: () {
                        widget.isAdd
                            ? addProduct(context)
                            : updateProductData(context);
                      },
                      text: 'Зберегти',
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
  final int maxLength;
  final int maxLines;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextField(
      {super.key,
      required this.hintText,
      required this.maxLength,
      required this.maxLines,
      required this.controller,
      required this.validator});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
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
              border: Border.all(color: const Color.fromARGB(255, 255, 179, 0)),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TextFormField(
              maxLines: maxLines,
              controller: controller,
              maxLength: maxLength,
              validator: validator,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(8),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
