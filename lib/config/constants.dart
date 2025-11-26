import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConstants {

  static String get baseUrl{
    // Diferenciamos entre las diferentes plataformas
    if(kIsWeb){
      return 'http://localhost:8080/api';
    
    // Si no es web, diferenciamos entre iOS y Android
    } else if(Platform.isIOS){
      return 'http://localhost:8080/api';
    } else if(Platform.isAndroid){
      return 'http://10.0.2.2:8080/api';
    } else {
      return 'http://localhost:8080/api';
    }
  }

  // Endpoint estático para obtener productos
  static const String productsEndpoint = '/productos';
  static const String categoriesEndpoint = '/categorias';
  static const String carritoEndpoint = '/carrito';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  
}
