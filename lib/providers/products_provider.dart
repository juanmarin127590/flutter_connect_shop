import 'package:flutter/material.dart';
import 'package:flutter_connect_shop/models/product.dart';
import 'package:flutter_connect_shop/services/api_service.dart';

class ProductsProvider extends ChangeNotifier {
  // Lista privada de productos
  List<Product> _items = [];
  
  // Estado de carga para mostrar spinners
  bool _isLoading = false;
  
  // Getter para acceder a la lista desde fuera
  List<Product> get items => [..._items];
  
  // Getter para saber si está cargando
  bool get isLoading => _isLoading;

  // Método para obtener datos del Backend
  Future<void> fetchAndSetProducts() async {
    _isLoading = true;
    // Notificamos para que la UI muestre el spinner de carga
    notifyListeners(); 

    try {
      final api = ApiService();
      // Llamamos a tu API real
      _items = await api.getProducts();
    } catch (error) {
      print("Error cargando productos: $error");
      // Aquí podrías manejar errores (mostrar un diálogo, etc.)
    } finally {
      _isLoading = false;
      // Notificamos que ya terminó (para quitar el spinner y mostrar datos)
      notifyListeners(); 
    }
  }
  
  // Método auxiliar para filtrar por categoría (usado en CatalogScreen)
  List<Product> findByCategory(String category) {
    return _items.where((prod) => prod.category == category).toList();
  }
}

