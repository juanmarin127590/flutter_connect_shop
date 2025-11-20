import 'package:flutter_connect_shop/models/product.dart';
import 'package:flutter/material.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class CartProvider extends ChangeNotifier {
  // Estado privado: lista de intems en el carrito
  final List<CartItem> _items = [];

  // Método para agregar un producto al carrito
  List<CartItem> get cartItems => _items;

  // Getter para el total de items (reemplaza a updateCartCount)
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  // Getter para el precio total
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  // Logica de addToCart
  void addToCart(Product product) {
    // Verificar si el producto ya está en el carrito
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    // Notificar a la UI que hubo un cambio
    notifyListeners();
  }

  // Lógica de removeFromCart
  void removeFromCart(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  // Limpiar carrito (útil para finalizar compra)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
