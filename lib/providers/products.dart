import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'product_model.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _items = [];
  List<Product> get items {
    return [..._items];
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
          productDescription: data['shortDescription'],
          imageUrl: data['imageUrl'],
          isHoney: data['isHoney'],
          litersLeft: data['litersLeft'],
        );
      }).toList();
      _items = productList;

      notifyListeners();
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
          productDescription: (productSnapshot.data()
                  as Map<String, dynamic>)['shortDescription'] ??
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
        'shortDescription': product.productDescription,
        'isHoney': product.isHoney,
      });
      Product newProduct = Product(
        id: docRef.id,
        title: product.title,
        price: product.price,
        imageUrl: imageUrl,
        litersLeft: product.litersLeft,
        productDescription: product.productDescription,
        isHoney: product.isHoney,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateProduct(String prodId, Product product,
      {File? pickedImage, String? currentImageUrl}) async {
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
        imageUrl = currentImageUrl!;
      }
      await FirebaseFirestore.instance
          .collection('products')
          .doc(prodId)
          .update({
        'title': product.title,
        'price': product.price,
        'imageUrl': imageUrl,
        'litersLeft': product.litersLeft,
        'shortDescription': product.productDescription,
        'isHoney': product.isHoney,
      });

      int index = _items.indexWhere((item) => item.id == prodId);
      if (index != -1) {
        if (_items[index].id == product.id) {
          _items[index] = product;
        }
      } else {
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
    } catch (error) {
      print('Сталася помилка при видаленні продукту: $error');
    }
  }
}
