import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:honey/providers/product.dart';

class ProductsProvider with ChangeNotifier {
  // String _currentImageUrl = '';

  // String getCurrentImageUrl() {
  //   return _currentImageUrl;
  // }

  List<Product> _items = [];
  List<Product> get items {
    return [..._items];
  }

  Future<List<Product>> getProductList() async {
    //Запускати в didChangeDepend
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('products').get();
      querySnapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        // String id= data['id'];
        String id = data['id'];
        String title = data['title'];
        double price = data['price'];
        int litersLeft = data['litersLeft'];
        String shortDescription = data['shortDescription'];
        String longDescription = data['longDescription'];
        String imageUrl = data['imageUrl'];
        bool isHoney = data['isHoney'];

        if (_items.any((prod) => prod.id == id)) {
          print('Товар вже існує, не дадано в _items');
          print('Кількість продуктів в _items: ${items.length}');
        } else {
          Product product = Product(
            id: id,
            title: title,
            price: price,
            shortDescription: shortDescription,
            longDescription: longDescription,
            imageUrl: imageUrl,
            isHoney: isHoney,
            litersLeft: litersLeft,
          );
          _items.add(product);
          print('Кількість продуктів в _items: ${items.length}');
          items.every((element) {
            print(element.id);
            return true;
          });
          // print(items.every((element) {} element.id));
        }
      });
    } catch (e) {
      print(e);
    }

    return _items;
  }

  Future<Product?> getProductById(String productId) async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (productSnapshot.exists) {
        String title =
            (productSnapshot.data() as Map<String, dynamic>)['title'];
        double price = double.parse(
            (productSnapshot.data() as Map<String, dynamic>)['price']
                .toStringAsFixed(2));
        String imageUrl =
            (productSnapshot.data() as Map<String, dynamic>)['imageUrl'] ?? '';
        int litersLeft =
            (productSnapshot.data() as Map<String, dynamic>)['litersLeft'];
        String shortDescription = (productSnapshot.data()
                as Map<String, dynamic>)['shortDescription'] ??
            '';
        String longDescription = (productSnapshot.data()
                as Map<String, dynamic>)['longDescription'] ??
            '';
        bool isHoney =
            (productSnapshot.data() as Map<String, dynamic>)['isHoney'];

        return Product(
          id: productId,
          title: title,
          price: price,
          imageUrl: imageUrl,
          litersLeft: litersLeft,
          shortDescription: shortDescription,
          longDescription: longDescription,
          isHoney: isHoney,
        );
      } else {
        return null;
      }
    } catch (e) {
      // Handle errors
      return null;
    }
  }

  Future<void> addProduct(Product product, File pickedImage) async {
    try {
      String newTitle = product.title;
      double newPrice = product.price;
      int newLitersLeft = product.litersLeft;
      String newShortDescription = product.shortDescription;
      String newLongDescription = product.longDescription;
      bool newIsHoney = product.isHoney;
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
        'title': newTitle,
        'price': newPrice,
        'imageUrl': imageUrl,
        'litersLeft': newLitersLeft,
        'shortDescription': newShortDescription,
        'longDescription': newLongDescription,
        'isHoney': newIsHoney,
      });

      // Create a new Product object with the same values
      Product newProduct = Product(
        id: docRef.id,
        title: newTitle,
        price: newPrice,
        imageUrl: imageUrl,
        litersLeft: newLitersLeft,
        shortDescription: newShortDescription,
        longDescription: newLongDescription,
        isHoney: newIsHoney,
      );

      // Add the new product to the list
      _items.add(newProduct);
      notifyListeners(); // Notify listeners of the change in the list
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateProduct(String prodId, Product product,
      {File? pickedImage, String? currentImg}) async {
    try {
      String newTitle = product.title;
      double newPrice = product.price;
      int newLitersLeft = product.litersLeft;
      String newShortDescription = product.shortDescription;
      String newLongDescription = product.longDescription;
      bool newIsHoney = product.isHoney;
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
        imageUrl = currentImg!;
      }

      await FirebaseFirestore.instance
          .collection('products')
          .doc(prodId)
          .update({
        'title': newTitle,
        'price': newPrice,
        'imageUrl': imageUrl,
        'litersLeft': newLitersLeft,
        'shortDescription': newShortDescription,
        'longDescription': newLongDescription,
        'isHoney': newIsHoney,
      });

      // Оновити дані в моделі продукту

      product.title = newTitle;
      product.price = newPrice;
      product.imageUrl = imageUrl;
      product.litersLeft = newLitersLeft;
      product.shortDescription = newShortDescription;
      product.longDescription = newLongDescription;
      product.isHoney = newIsHoney;

      int index = _items.indexWhere((item) => item.id == prodId);
      if (index != -1) {
        if (_items[index].id == product.id) {
          _items[index] = product;
        }
      } else {
        // Продукт не знайдено у списку, додати його
        _items.add(product);
      }

      // Оповістити слухачі про зміни в продукті
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
