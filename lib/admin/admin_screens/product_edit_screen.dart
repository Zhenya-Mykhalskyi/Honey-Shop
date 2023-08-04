import 'dart:io';
import 'package:flutter/material.dart';

import 'package:honey/widgets/custom_text_field.dart';
import 'package:honey/widgets/edit_form_image.dart';
import 'package:honey/widgets/title_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:honey/services/check_internet_connection.dart';
import 'package:honey/providers/product_model.dart';
import 'package:honey/providers/products.dart';
import 'package:honey/widgets/app_colors.dart';
import 'package:honey/widgets/custom_button.dart';
import 'package:honey/widgets/custom_confirm_dialog.dart';
import 'discount_screen.dart';

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
  String? _imageUrl;
  File? _pickedImage;

  bool _isLoading = false;
  String? _currentImageUrl;
  bool _isHoney = false;
  Product? _fetchedProduct;

  final _editedProduct = Product(
    id: '',
    title: '',
    price: 0,
    productDescription: '',
    imageUrl: '',
    isHoney: false,
    litersLeft: 0,
  );

  @override
  void initState() {
    fetchProductDataAndSetValues();
    super.initState();
  }

  Future<void> fetchProductDataAndSetValues() async {
    try {
      setState(() {
        _isLoading = true;
      });
      ProductsProvider productProvider =
          Provider.of<ProductsProvider>(context, listen: false);
      Product? product =
          await productProvider.getProductByIdFromFirestore(widget.productId);
      if (product != null) {
        _fetchedProduct = product;
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
    } catch (error) {
      print('Error: $error');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> submitProductForm(BuildContext context) async {
    ProductsProvider productProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    final popContext = Navigator.of(context);
    final scaffoldContext = ScaffoldMessenger.of(context);

    final isValid = _formkey.currentState?.validate();
    if (!isValid!) {
      return;
    }

    final hasInternetConnection =
        await CheckConnectivityUtil.checkInternetConnectivity(context);
    if (!hasInternetConnection) {
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
            pickedImage: _pickedImage, currentImageUrl: _currentImageUrl);
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

  void _handleImagePicked(File? image) {
    setState(() {
      _pickedImage = image;
    });
  }

  Future<void> deleteProductAndStorageImage(
      BuildContext context, productId, String imageUrl) async {
    final popContext = Navigator.of(context);
    ProductsProvider productProvider =
        Provider.of<ProductsProvider>(context, listen: false);
    final hasInternetConnection =
        await CheckConnectivityUtil.checkInternetConnectivity(context);

    if (!hasInternetConnection) {
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
      appBar: TitleAppBar(
        title: widget.isAddProduct ? 'Додання товару' : 'Редагування товару',
        showIconButton: widget.isAddProduct ? false : true,
        icon: Icons.delete,
        action: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ConfirmationDialog(
                title: 'Впевнені, що хочете видалити товар?',
                confirmButtonText: 'Так',
                cancelButtonText: 'Скасувати',
                onConfirm: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  deleteProductAndStorageImage(
                      context, widget.productId, _currentImageUrl!);
                },
              );
            },
          );
        },
      ),
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
                              EditFormImage(
                                onImagePicked: _handleImagePicked,
                                currentProfileImage: _currentImageUrl,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  children: [
                                    CustomTextField(
                                      hintText: 'Назва товару',
                                      maxLength: 30,
                                      maxLines: 1,
                                      textSize: 17,
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
                                      textSize: 17,
                                      controller: _priceController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Будь ласка, введіть ціну за товар';
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
                                      _isHoney = value ?? false;
                                    });
                                  },
                                ),
                              ),
                              const Flexible(
                                child: Text(
                                  'Поставте галочку, якщо товар являється медом*',
                                  style: TextStyle(fontSize: 17),
                                ),
                              ),
                            ],
                          ),
                          CustomTextField(
                            hintText: 'Кількість літрів',
                            maxLength: 6,
                            maxLines: 1,
                            textSize: 17,
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
                            textSize: 17,
                            controller: _descriptionController,
                            showCounterText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Будь ласка, введіть опис товару';
                              }
                              return null;
                            },
                          ),
                          if (!widget.isAddProduct)
                            TextButton(
                                onPressed: () {
                                  if (_formkey.currentState!.validate()) {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => DiscountScreen(
                                        product: _fetchedProduct!,
                                      ),
                                    ));
                                  }
                                },
                                child: const Text(
                                  'Застосувати акцію',
                                  style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline,
                                      fontSize: 16),
                                ))
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

 // Future<void> addProduct(BuildContext context) async {
  //   final popContext = Navigator.of(context);
  //   final scaffoldContext = ScaffoldMessenger.of(context);
  //   final isValid = _formkey.currentState
  //       ?.validate();
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
  //       ?.validate(); 
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
