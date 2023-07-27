import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

import 'package:honey/providers/product_model.dart';
import 'package:honey/providers/products.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/custom_button.dart';

class ProductEditScreen extends StatefulWidget {
  final String productId;
  final bool isAddProduct;
  const ProductEditScreen(
      {Key? key, required this.productId, required this.isAddProduct})
      : super(key: key);

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formkey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _litersLeftController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _imageUrl; //для загрузки на firestore
  File? _pickedImage;
  bool _isLoading = false;
  String? _currentImageUrl;
  bool _isHoney = false;

  final _editedProduct = Product(
    id: '',
    title: '',
    price: 0,
    productDescription: '',
    imageUrl: '',
    isHoney: false,
    litersLeft: 0,
    liters: 0,
  );

  @override
  void initState() {
    fetchProductDataAndSetValues();
    super.initState();
  }

  Future<void> submitProductForm(BuildContext context) async {
    ProductsProvider productProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    final popContext = Navigator.of(context);
    final scaffoldContext = ScaffoldMessenger.of(context);
    final connectivityResult = await Connectivity().checkConnectivity();
    final isValid = _formkey.currentState?.validate();
    if (!isValid!) {
      return;
    }

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
      _editedProduct.title = _titleController.text;
      _editedProduct.price = double.parse(_priceController.text);
      _editedProduct.litersLeft = int.parse(_litersLeftController.text);
      _editedProduct.productDescription = _descriptionController.text;
      _editedProduct.isHoney = _isHoney;
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .get();
      if (productSnapshot.exists) {
        await productProvider.updateProduct(widget.productId, _editedProduct,
            pickedImage: _pickedImage, currentImgage: _currentImageUrl);
        popContext.pop();
      } else {
        if (_pickedImage != null) {
          await productProvider.addProduct(_editedProduct, _pickedImage!);
        } else {
          scaffoldContext.showSnackBar(
            const SnackBar(
              content: Text('Додайте картинку'),
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
        popContext.pop();
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchProductDataAndSetValues() async {
    try {
      setState(() {
        _isLoading = true;
      });
      ProductsProvider productProvider =
          Provider.of<ProductsProvider>(context, listen: false);
      await productProvider
          .getProductByIdFromFirestore(widget.productId)
          .then((product) {
        if (product != null) {
          _priceController.text = product.price.toString();
          _titleController.text = product.title;
          _litersLeftController.text = product.litersLeft.toString();
          _descriptionController.text = product.productDescription;
          _isHoney = product.isHoney;
          _imageUrl = product.imageUrl;
          setState(() {
            _currentImageUrl = _imageUrl;
            _isHoney;
          });
        }
      });
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> pickProductImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
    return null;
  }

  Future<void> deleteProductAndStorageImgage(
      BuildContext context, productId, String imageUrl) async {
    ProductsProvider productProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    final scaffoldContext = ScaffoldMessenger.of(context);
    final popContext = Navigator.of(context);
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
    setState(() {
      _isLoading = true;
    });
    await productProvider.deleteProduct(widget.productId, _currentImageUrl!);
    setState(() {
      _isLoading = false;
    });
    popContext.pop();
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
                          'Впевнені, що хочете видалити товар?',
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
                                deleteProductAndStorageImgage(context,
                                    widget.productId, _currentImageUrl!);
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
          },
        )
      ]),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ))
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
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                child: widget.isAddProduct
                                    ? _pickedImage == null
                                        ? InkWell(
                                            onTap: pickProductImage,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(25.0),
                                              child: Image.asset(
                                                  'assets/img/add_photo.png'),
                                            ),
                                          )
                                        : InkWell(
                                            onTap: pickProductImage,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                _pickedImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                    // редагуємо
                                    : _pickedImage != null
                                        ? InkWell(
                                            onTap: pickProductImage,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                _pickedImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : InkWell(
                                            onTap: pickProductImage,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                _currentImageUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      hintText: 'Назва товару',
                                      maxLength: 30,
                                      maxLines: 1,
                                      controller: _titleController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Будь ласка, введіть назву товару';
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
                          Row(
                            children: [
                              Transform.scale(
                                scale: 1.5,
                                child: Checkbox(
                                  fillColor: MaterialStateProperty.all<Color>(
                                    AppColors.primaryColor,
                                  ),
                                  checkColor: Colors.black,
                                  activeColor: AppColors.primaryColor,
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
                              ),
                            ],
                          ),
                          CustomTextField(
                            hintText: 'Кількість літрів',
                            maxLength: 6,
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
                            hintText: 'Опис товару (розділяйте абзацами)',
                            maxLength: 1000,
                            maxLines: 14,
                            controller: _descriptionController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Будь ласка, введіть опис товару';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                      action: () {
                        submitProductForm(context);
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

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.maxLength,
    required this.maxLines,
    required this.controller,
    required this.validator,
  });

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
              border: Border.all(
                color: AppColors.primaryColor,
              ),
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
                  counterStyle:
                      TextStyle(color: Color.fromARGB(255, 173, 173, 173))),
            ),
          ),
        ],
      ),
    );
  }
}

 // Future<void> addProduct(BuildContext context) async {
  //   final popContext = Navigator.of(context);
  //   final scaffoldContext = ScaffoldMessenger.of(context);
  //   final isValid = _formkey.currentState
  //       ?.validate(); //викликає всі валідатори та вертає значення true, якщо всі валідатори return null (всі дані пройшли провірку)
  //   if (!isValid! || _pickedImage == null) {
  //     return; // пририває виконання функії, код нище не буде виконуватись
  //   }
  //   final connectivityResult = await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.none) {
  //     // Немає з'єднання з Інтернетом
  //     scaffoldContext.showSnackBar(
  //       const SnackBar(
  //         content: Text('Немає з\'єднання з Інтернетом'),
  //         duration: Duration(seconds: 3), // Тривалість показу SnackBar
  //       ),
  //     );
  //     return; // Перериваємо виконання функції
  //   }

  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     String newTitle = _titleController.text;
  //     double newPrice = double.parse(_priceController.text);
  //     int newLitersLeft = int.parse(_litersLeftController.text);
  //     String newShortDescription = _shortDescriptionController.text;
  //     String newLongDescription = _longDescriptionController.text;
  //     bool newIsHoney = _isHoney;
  //     if (_pickedImage != null) {
  //       //якщо фото вибране
  //       Reference ref = FirebaseStorage.instance
  //           .ref()
  //           .child('product_images')
  //           .child('${newTitle.toLowerCase().replaceAll(' ', '_')}.jpg');
  //       final imageBytes = await _pickedImage!.readAsBytes();
  //       await ref.putData(imageBytes);
  //       _imageUrl = await ref.getDownloadURL();
  //     }

  //     await FirebaseFirestore.instance
  //         .collection('products')
  //         .doc(newTitle.toLowerCase().replaceAll(' ', '_')) //  назва як ID
  //         .set({
  //       'title': newTitle,
  //       'price': newPrice,
  //       'imageUrl': _imageUrl,
  //       'litersLeft': newLitersLeft,
  //       'shortDescription': newShortDescription,
  //       'longDescription': newLongDescription,
  //       'isHoney': newIsHoney,
  //     });
  //   } catch (e) {
  //     print(e);
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     popContext.pop();
  //   }
  // }


// Future<void> updateProductData(BuildContext context) async {
  //   final popContext = Navigator.of(context);
  //   final scaffoldContext = ScaffoldMessenger.of(context);
  //   final connectivityResult = await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.none) {
  //     // Немає з'єднання з Інтернетом
  //     scaffoldContext.showSnackBar(
  //       const SnackBar(
  //         content: Text('Немає з\'єднання з Інтернетом'),
  //         duration: Duration(seconds: 3),
  //       ),
  //     );
  //     return;
  //   }
  //   final isValid = _formkey.currentState
  //       ?.validate(); //викликає всі валідатори та вертає значення true, якщо всі валідатори return null (всі дані пройшли провірку)
  //   if (!isValid! || _currentImageUrl == null) {
  //     return;
  //   }
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     String newTitle = _titleController.text;
  //     double newPrice = double.parse(_priceController.text);
  //     int newLitersLeft = int.parse(_litersLeftController.text);
  //     String newShortDescription = _shortDescriptionController.text;
  //     String newLongDescription = _longDescriptionController.text;
  //     bool newIsHoney = _isHoney;
  //     if (_pickedImage != null) {
  //       Reference ref = FirebaseStorage.instance
  //           .ref()
  //           .child('product_images')
  //           .child('${widget.productId}.jpg');
  //       final imageBytes = await _pickedImage!.readAsBytes();
  //       await ref.putData(imageBytes);
  //       _imageUrl = await ref.getDownloadURL();
  //     } else {
  //       _imageUrl = _currentImageUrl;
  //     }
  //     await FirebaseFirestore.instance
  //         .collection('products')
  //         .doc(widget.productId)
  //         .update({
  //       'title': newTitle,
  //       'price': newPrice,
  //       'imageUrl': _imageUrl,
  //       'litersLeft': newLitersLeft,
  //       'shortDescription': newShortDescription,
  //       'longDescription': newLongDescription,
  //       'isHoney': newIsHoney,
  //     });
  //   } catch (e) {
  //     print(e);
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     popContext.pop();
  //   }
  // }
