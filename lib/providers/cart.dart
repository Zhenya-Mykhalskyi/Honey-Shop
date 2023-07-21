import 'package:flutter/foundation.dart';
import 'package:honey/providers/product_model.dart';

class CartItemModel {
  final String id;
  final String title;
  final double liters;
  final double price;
  final String imageUrl;

  CartItemModel(
      {required this.id,
      required this.title,
      required this.liters,
      required this.price,
      required this.imageUrl});
}

class CartProvider with ChangeNotifier {
  Map<String, CartItemModel> _items = {};
  Map<String, CartItemModel> get items {
    return {..._items};
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.liters;
    });

    return total;
  }

  double get itemCount {
    double count = 0;
    _items.forEach((key, cartItem) {
      count += cartItem.liters;
    });
    return count;
  }

  double getLitersForProduct(String productId) {
    if (_items.containsKey(productId)) {
      return _items[productId]!.liters;
    } else {
      return 0.0;
    }
  }

  void addItemToCart({required Product product}) {
    if (_items.containsKey(product.id)) {
      _items.update(
          product.id,
          (existingCartItem) => CartItemModel(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              liters: existingCartItem.liters + 0.5,
              imageUrl: existingCartItem.imageUrl));
    } else {
      _items.putIfAbsent(
          product.id,
          () => CartItemModel(
              id: product.id,
              title: product.title,
              price: product.price,
              liters: 0.5,
              imageUrl: product.imageUrl));
    }
    // print(
    //     'Продукт: ${_items.values.toList()[0].title}   Ціна продукта: ${_items.values.toList()[0].price} * Кількість літрів: ${_items.values.toList()[0].liters} = ${_items.values.toList()[0].price * _items.values.toList()[0].liters}');
    notifyListeners();
  }

  void removeItemFromCart(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItemFromCart(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.liters > 0.5) {
      _items.update(
        productId,
        (existingCartItem) => CartItemModel(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          liters: existingCartItem.liters - 0.5,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      _items.remove(productId);
    }
    // print(
    //     'Ціна продукта: ${_items.values.toList()[0].price} * Кількість літрів: ${_items.values.toList()[0].liters} = ${_items.values.toList()[0].price * _items.values.toList()[0].liters}');
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
