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

  /// Crear un nuevo producto (ADMIN)
  Future<bool> createProduct(String token, Map<String, dynamic> productData) async {
    print('🔷 PROVIDER - Iniciando creación de producto');
    try {
      final api = ApiService();
      final newProduct = await api.createProduct(token, productData);
      
      print('🔷 PROVIDER - Producto creado: ${newProduct.name}');
      
      // Agregar el producto a la lista local
      _items.insert(0, newProduct);
      notifyListeners();
      
      print('🔷 PROVIDER - Lista actualizada, total productos: ${_items.length}');
      return true;
    } catch (error, stackTrace) {
      print('❌ PROVIDER - Error creando producto: $error');
      print('❌ PROVIDER - Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Actualizar un producto existente (ADMIN)
  Future<bool> updateProduct(String token, int productId, Map<String, dynamic> productData) async {
    try {
      final api = ApiService();
      final updatedProduct = await api.updateProduct(token, productId, productData);
      
      // Actualizar el producto en la lista local
      final index = _items.indexWhere((p) => p.id == productId);
      if (index >= 0) {
        _items[index] = updatedProduct;
        notifyListeners();
      }
      
      return true;
    } catch (error) {
      print("Error actualizando producto: $error");
      rethrow;
    }
  }

  /// Eliminar (desactivar) un producto (ADMIN)
  Future<bool> deleteProduct(String token, int productId) async {
    try {
      final api = ApiService();
      final success = await api.deleteProduct(token, productId);
      
      if (success) {
        // Remover el producto de la lista local
        _items.removeWhere((p) => p.id == productId);
        notifyListeners();
      }
      
      return success;
    } catch (error) {
      print("Error eliminando producto: $error");
      rethrow;
    }
  }

}

