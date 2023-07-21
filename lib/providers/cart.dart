import 'package:flutter/foundation.dart';

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

  void addItemToCart({
    required String productId,
    required double price,
    required String title,
    required String imageUrl,
    required double liters,
  }) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingCartItem) => CartItemModel(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              liters: existingCartItem.liters + 0.5,
              imageUrl: existingCartItem.imageUrl));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItemModel(
              id: productId,
              title: title,
              price: price,
              liters: 0.5,
              imageUrl: imageUrl));
    }
    print(
        'Ціна продукта: ${_items.values.toList()[0].price} * Кількість літрів: ${_items.values.toList()[0].liters} = ${_items.values.toList()[0].price * _items.values.toList()[0].liters}');
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
    print(
        'Ціна продукта: ${_items.values.toList()[0].price} * Кількість літрів: ${_items.values.toList()[0].liters} = ${_items.values.toList()[0].price * _items.values.toList()[0].liters}');
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
