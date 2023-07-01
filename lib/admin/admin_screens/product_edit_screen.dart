import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

  @override
  void initState() {
    super.initState();
    getProductData();
  }

  Future<void> getProductData() async {
    try {
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

        _priceController.text = price.toString();
        _titleController.text = title;
        _litersLeftController.text = litersLeft.toString();
        _shortDescriptionController.text = shortDescription;
        _longDescriptionController.text = longDescription;
        setState(() {
          _currentImageUrl = imageUrl;
        });
      } else {
        !widget.isAdd ? print('Product snapshot does not exist') : null;
      }
    } catch (e) {
      // print('Error: $e');
      // Handle errors
    }
  }

  Future<void> addProduct() async {
    final isValid = _formkey.currentState
        ?.validate(); //викликає всі валідатори та вертає значення true, якщо всі валідатори return null (всі дані пройшли провірку)
    if (!isValid! || _pikedImage == null) {
      return; // пририває виконання функії, код нище не буде виконуватись
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
      });

      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  Future<void> updateProductData() async {
    final isValid = _formkey.currentState
        ?.validate(); //викликає всі валідатори та вертає значення true, якщо всі валідатори return null (всі дані пройшли провірку)
    if (!isValid! || _currentImageUrl == null) {
      return; // пририває виконання функії, код нище не буде виконуватись
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
      });

      Navigator.of(context).pop();
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> deleteProduct(String productId, String imageUrl) async {
    try {
      // Видалення картинки
      if (imageUrl.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }

      // Видалення продукту з Firestore
      final productRef =
          FirebaseFirestore.instance.collection('products').doc(productId);
      await productRef.delete();

      print('Продукт успішно видалений з Firestore і картинка з хранилища.');
    } catch (error) {
      print('Сталася помилка при видаленні продукту: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, actions: [
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            deleteProduct(widget.productId, _currentImageUrl!);
            Navigator.of(context).pop();
          },
        )
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
                                        width: 1, color: Colors.white),
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
                                              child: Image.file(
                                                _pikedImage!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                      // редагуємо
                                      : _currentImageUrl != null
                                          ? InkWell(
                                              onTap: pickAndUploadImage,
                                              child: Image.network(
                                                _currentImageUrl!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : InkWell(
                                              onTap: pickAndUploadImage,
                                              child: const Text('error'),
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
                                      maxLength: 10,
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
                      action: widget.isAdd ? addProduct : updateProductData,
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

// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class Product {
//   String id;
//   String title;
//   double price;
//   String imageUrl;

//   Product({
//     required this.id,
//     required this.title,
//     required this.price,
//     required this.imageUrl,
//   });
// }

// class ProductManagementPage extends StatefulWidget {
//   @override
//   _ProductManagementPageState createState() => _ProductManagementPageState();
// }

// class _ProductManagementPageState extends State<ProductManagementPage> {
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   File? _pickedImage;

//   Future<void> _pickImage(ImageSource source) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: source);

//     if (pickedFile != null) {
//       setState(() {
//         _pickedImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _addProduct() async {
//     try {
//       String title = _titleController.text;
//       double price = double.parse(_priceController.text);

//       if (_pickedImage != null) {
//         // Завантаження зображення до Firebase Storage
//         Reference ref = FirebaseStorage.instance
//             .ref()
//             .child('product_images')
//             .child('${title.toLowerCase().replaceAll(' ', '_')}.jpg');
//         final imageBytes = await _pickedImage!.readAsBytes();
//         await ref.putData(imageBytes);
//         String imageUrl = await ref.getDownloadURL();

//         // Додавання продукту до Firestore
//         await FirebaseFirestore.instance.collection('products').add({
//           'title': title,
//           'price': price,
//           'imageUrl': imageUrl,
//         });
//       }

//       _resetForm();
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _updateProduct(Product product) async {
//     try {
//       String newTitle = _titleController.text;
//       double newPrice = double.parse(_priceController.text);

//       if (_pickedImage != null) {
//         // Завантаження нового зображення до Firebase Storage
//         Reference ref = FirebaseStorage.instance
//             .ref()
//             .child('product_images')
//             .child('${product.id}.jpg');
//         final imageBytes = await _pickedImage!.readAsBytes();
//         await ref.putData(imageBytes);
//         String imageUrl = await ref.getDownloadURL();

//         // Оновлення продукту в Firestore
//         await FirebaseFirestore.instance
//             .collection('products')
//             .doc(product.id)
//             .update({
//           'title': newTitle,
//           'price': newPrice,
//           'imageUrl': imageUrl,
//         });
//       } else {
//         // Оновлення продукту в Firestore без зміни зображення
//         await FirebaseFirestore.instance
//             .collection('products')
//             .doc(product.id)
//             .update({
//           'title': newTitle,
//           'price': newPrice,
//         });
//       }

//       _resetForm();
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<void> _deleteProduct(Product product) async {
//     try {
//       // Видалення зображення з Firebase Storage
//       Reference ref = FirebaseStorage.instance
//           .ref()
//           .child('product_images')
//           .child('${product.id}.jpg');
//       await ref.delete();

//       // Видалення продукту з Firestore
//       await FirebaseFirestore.instance
//           .collection('products')
//           .doc(product.id)
//           .delete();

//       _resetForm();
//     } catch (e) {
//       print(e);
//     }
//   }

//   void _resetForm() {
//     _titleController.text = '';
//     _priceController.text = '';
//     setState(() {
//       _pickedImage = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Product Management'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Add Product',
//               style: TextStyle(
//                 fontSize: 24.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             TextFormField(
//               controller: _titleController,
//               decoration: InputDecoration(labelText: 'Title'),
//             ),
//             TextFormField(
//               controller: _priceController,
//               decoration: InputDecoration(labelText: 'Price'),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16.0),
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                   icon: Icon(Icons.image),
//                   label: Text('Pick Image'),
//                 ),
//                 SizedBox(width: 8.0),
//                 ElevatedButton.icon(
//                   onPressed: _resetForm,
//                   icon: Icon(Icons.refresh),
//                   label: Text('Reset'),
//                 ),
//                 SizedBox(width: 8.0),
//                 ElevatedButton.icon(
//                   onPressed: _addProduct,
//                   icon: Icon(Icons.add),
//                   label: Text('Add Product'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 24.0),
//             Text(
//               'Product List',
//               style: TextStyle(
//                 fontSize: 24.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('products')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.hasError) {
//                     return Text('Error: ${snapshot.error}');
//                   }

//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return Center(child: CircularProgressIndicator());
//                   }

//                   List<Product> products = snapshot.data!.docs.map((doc) {
//                     Map<String, dynamic> data =
//                         doc.data() as Map<String, dynamic>;
//                     return Product(
//                       id: doc.id,
//                       title: data['title'],
//                       price: data['price'],
//                       imageUrl: data['imageUrl'],
//                     );
//                   }).toList();

//                   return ListView.builder(
//                     itemCount: products.length,
//                     itemBuilder: (context, index) {
//                       Product product = products[index];
//                       return ListTile(
//                         leading: Image.network(product.imageUrl),
//                         title: Text(product.title),
//                         subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
//                         trailing: IconButton(
//                           icon: Icon(Icons.edit),
//                           onPressed: () {
//                             _titleController.text = product.title;
//                             _priceController.text = product.price.toString();
//                             showDialog(
//                               context: context,
//                               builder: (context) {
//                                 return AlertDialog(
//                                   title: Text('Edit Product'),
//                                   content: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       TextFormField(
//                                         controller: _titleController,
//                                         decoration:
//                                             InputDecoration(labelText: 'Title'),
//                                       ),
//                                       TextFormField(
//                                         controller: _priceController,
//                                         decoration:
//                                             InputDecoration(labelText: 'Price'),
//                                         keyboardType: TextInputType.number,
//                                       ),
//                                       SizedBox(height: 16.0),
//                                       Row(
//                                         children: [
//                                           ElevatedButton.icon(
//                                             onPressed: () =>
//                                                 _pickImage(ImageSource.gallery),
//                                             icon: Icon(Icons.image),
//                                             label: Text('Pick Image'),
//                                           ),
//                                           SizedBox(width: 8.0),
//                                           ElevatedButton.icon(
//                                             onPressed: () {
//                                               _updateProduct(product);
//                                               Navigator.of(context).pop();
//                                             },
//                                             icon: Icon(Icons.save),
//                                             label: Text('Save'),
//                                           ),
//                                           SizedBox(width: 8.0),
//                                           ElevatedButton.icon(
//                                             onPressed: () {
//                                               _deleteProduct(product);
//                                               Navigator.of(context).pop();
//                                             },
//                                             icon: Icon(Icons.delete),
//                                             label: Text('Delete'),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
