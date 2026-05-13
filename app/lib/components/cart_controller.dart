import 'package:flutter/material.dart';

class CartItem {
  CartItem({required this.product, this.quantity = 1});

  final Map<String, dynamic> product;
  int quantity;

  double get subtotal => CartController._price(product) * quantity;
}

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  void add(Map<String, dynamic> product) {
    final id = _id(product);
    final index = _items.indexWhere((item) => _id(item.product) == id);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void decrease(Map<String, dynamic> product) {
    final id = _id(product);
    final index = _items.indexWhere((item) => _id(item.product) == id);
    if (index < 0) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity -= 1;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void remove(Map<String, dynamic> product) {
    final id = _id(product);
    _items.removeWhere((item) => _id(item.product) == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  static int _id(Map<String, dynamic> product) {
    final value = product['id'];
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _price(Map<String, dynamic> product) {
    final value = product['preco'] ?? product['price'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
