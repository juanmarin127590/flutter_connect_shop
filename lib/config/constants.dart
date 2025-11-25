import 'dart:io';

class ApiConstants {

  static String get baseUrl{
    // Diferenciamos entre Android e iOS para localhost
    if(Platform.isAndroid){
      return 'https://10.0.2.2:8080/api';
    } else {
      return 'https://localhost:8080/api';
    }
  }

  // Endpoint estático para obtener productos
  static const String productsEndpoint = '/productos';
  static const String categoriesEndpoint = '/categorias';
  static const String carritoEndpoint = '/carrito';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  
}
