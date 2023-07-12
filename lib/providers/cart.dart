import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final double liters;
  final double price;

  CartItem(
      {required this.id,
      required this.title,
      required this.liters,
      required this.price});
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.liters;
    });

    return total;
  }

  // int get itemCount {
  //   var count = 0;
  //   _items.forEach((key, cartItem) {
  //     count += cartItem.liters as int;
  //   });
  //   return count;
  // }

  void addItemToCart(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                liters: existingCartItem.liters + 0.5,
              ));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              price: price,
              liters: 0.5));
    }
    notifyListeners();
    print(_items.length);
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      // ! якщо не э частиною корзини.
      return;
    }
    if (_items[productId]!.liters > 0.5) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          liters: existingCartItem.liters - 0.5,
        ),
      );
    } else {
      // к-ть = 1
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
