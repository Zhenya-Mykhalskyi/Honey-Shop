import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:honey/providers/product_model.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];
  List<Product> get items {
    return [..._items];
  }

  double _totalCost = 0;
  double get totalCost => _totalCost;

  void addHalfLiter(Product product) {
    product.liters = (product.liters) + 0.5;
    print('${product.title}  ${product.liters}');
    notifyListeners();
  }

  void subtractHalfLiter(Product product) {
    if (product.liters >= 0.5) {
      product.liters = (product.liters) - 0.5;
      print('${product.title}  ${product.liters}');
      notifyListeners();
    }
  }

  void resetLiters(Product? product) {
    product?.liters = 0;
    notifyListeners();
  }

  double getProductCost(Product product) {
    return product.liters * 2 * product.price;
  }

  Product? getProductById(String productId) {
    return items.firstWhere((product) => product.id == productId,
        orElse: () => throw Exception('Product not found'));
  }

  Future<List<Product>> getProductList() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      List<Product> productList = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          id: data['id'],
          title: data['title'],
          price: data['price'],
          shortDescription: data['shortDescription'],
          longDescription: data['longDescription'],
          imageUrl: data['imageUrl'],
          isHoney: data['isHoney'],
          litersLeft: data['litersLeft'],
        );
      }).toList();
      _items = productList;

      notifyListeners();
      print('Кількість продуктів в _items: ${items.length}');
    } catch (e) {
      print(e);
    }
    return _items;
  }

  Future<Product?> getProductByIdFromFirestore(String productId) async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (productSnapshot.exists) {
        return Product(
          id: productId,
          title: (productSnapshot.data() as Map<String, dynamic>)['title'],
          price: double.parse(
              (productSnapshot.data() as Map<String, dynamic>)['price']
                  .toStringAsFixed(2)),
          imageUrl:
              (productSnapshot.data() as Map<String, dynamic>)['imageUrl'] ??
                  '',
          litersLeft:
              (productSnapshot.data() as Map<String, dynamic>)['litersLeft'],
          shortDescription: (productSnapshot.data()
                  as Map<String, dynamic>)['shortDescription'] ??
              '',
          longDescription: (productSnapshot.data()
                  as Map<String, dynamic>)['longDescription'] ??
              '',
          isHoney: (productSnapshot.data() as Map<String, dynamic>)['isHoney'],
        );
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> addProduct(Product product, File pickedImage) async {
    try {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('products').doc();
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child('${docRef.id.toString()}.jpg');
      final imageBytes = await pickedImage.readAsBytes();
      await ref.putData(imageBytes);
      String imageUrl = await ref.getDownloadURL();

      await docRef.set({
        'id': docRef.id,
        'title': product.title,
        'price': product.price,
        'imageUrl': imageUrl,
        'litersLeft': product.litersLeft,
        'shortDescription': product.shortDescription,
        'longDescription': product.longDescription,
        'isHoney': product.isHoney,
      });
      Product newProduct = Product(
        id: docRef.id,
        title: product.title,
        price: product.price,
        imageUrl: imageUrl,
        litersLeft: product.litersLeft,
        shortDescription: product.shortDescription,
        longDescription: product.longDescription,
        isHoney: product.isHoney,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateProduct(String prodId, Product product,
      {File? pickedImage, String? currentImgage}) async {
    try {
      String imageUrl;
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('product_images')
          .child('$prodId.jpg');
      if (pickedImage != null) {
        final imageBytes = await pickedImage.readAsBytes();
        await ref.putData(imageBytes);
        imageUrl = await ref.getDownloadURL();
      } else {
        imageUrl = currentImgage!;
      }
      await FirebaseFirestore.instance
          .collection('products')
          .doc(prodId)
          .update({
        'title': product.title,
        'price': product.price,
        'imageUrl': imageUrl,
        'litersLeft': product.litersLeft,
        'shortDescription': product.shortDescription,
        'longDescription': product.longDescription,
        'isHoney': product.isHoney,
      });

      product.title = product.title;
      product.price = product.price;
      product.imageUrl = imageUrl;
      product.litersLeft = product.litersLeft;
      product.shortDescription = product.shortDescription;
      product.longDescription = product.longDescription;
      product.isHoney = product.isHoney;

      int index = _items.indexWhere((item) => item.id == prodId);
      if (index != -1) {
        if (_items[index].id == product.id) {
          _items[index] = product;
        }
      } else {
        // Продукт не знайдено у списку, додати його
        _items.add(product);
      }
      await getProductList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteProduct(String productId, String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
        await storageRef.delete();
      }
      final productRef =
          FirebaseFirestore.instance.collection('products').doc(productId);
      await productRef.delete();
      _items.removeWhere((product) => product.id == productId);
      notifyListeners();
      print('Продукт успішно видалений.');
    } catch (error) {
      print('Сталася помилка при видаленні продукту: $error');
    }
  }
}
