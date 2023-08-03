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
            isDiscount: data['isDiscount'] ?? false,
            discountPrice: data['discountPrice'] ?? 0,
            discountPercentage: data['discountPercentage'] ?? 0);
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
          isDiscount:
              (productSnapshot.data() as Map<String, dynamic>)['isDiscount'],
          discountPrice:
              (productSnapshot.data() as Map<String, dynamic>)['discountPrice'],
          discountPercentage: (productSnapshot.data()
              as Map<String, dynamic>)['discountPercentage'],
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
        'isDiscount': product.isDiscount ?? false,
        'discountPrice': product.discountPrice ?? 0,
        'discountPercentage': product.discountPercentage ?? 0,
      });
      Product newProduct = Product(
        id: docRef.id,
        title: product.title,
        price: product.price,
        imageUrl: imageUrl,
        litersLeft: product.litersLeft,
        productDescription: product.productDescription,
        isHoney: product.isHoney,
        isDiscount: product.isDiscount,
        discountPrice: product.discountPrice,
        discountPercentage: product.discountPercentage,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateProduct(
    String prodId,
    Product product, {
    File? pickedImage,
    String? currentImageUrl,
    // bool isDiscount = false,
    // int discountPercentage = 0,
    // double priceWithDiscount = 0.0,
  }) async {
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
        // 'isDiscount': isDiscount,
        // 'discountPrice': priceWithDiscount,
        // 'discountPercentage': discountPercentage,
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

  Future<void> applyDiscount(
      String productId, int discountPercentage, double discountPrice) async {
    try {
      int index = _items.indexWhere((item) => item.id == productId);
      if (index != -1) {
        _items[index].isDiscount = true;
        _items[index].discountPercentage = discountPercentage;
        _items[index].discountPrice = discountPrice;

        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .update({
          'isDiscount': true,
          'discountPrice': discountPrice,
          'discountPercentage': discountPercentage,
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error applying discount: $e');
    }
  }

  Future<void> deleteDiscount(String productId) async {
    try {
      int index = _items.indexWhere((item) => item.id == productId);
      if (index != -1) {
        _items[index].isDiscount = false;
        _items[index].discountPercentage = 0;
        _items[index].discountPrice = 0.0;

        await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .update({
          'isDiscount': false,
          'discountPercentage': 0,
          'discountPrice': 0.0,
        });
        notifyListeners();
      }
    } catch (e) {
      print('Error applying discount: $e');
    }
  }
}
