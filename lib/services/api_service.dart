import 'dart:convert';
import 'package:flutter_connect_shop/config/constants.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {

  // Obtener lista de productos desde una API
  Future<List<Product>> getProducts() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.productsEndpoint}');

   try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decodificamos el JSON (que será una lista [...])
        final List<dynamic> data = jsonDecode(response.body);
        
        // Convertimos cada item de la lista JSON a un objeto Product
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar productos: ${response.statusCode}');
      }
    } catch (e) {
      // Manejo de errores de conexión (servidor apagado, sin internet, etc.)
      print("Error HTTP: $e");
      rethrow; 
    }
  }
  
  // Método para Login 
  Future<String?> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Éxito: El servidor devuelve un JSON con el token
        // Según tu DTO Java, el campo se llama "accessToken"
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['accessToken']; 
      } else {
        // Error: Credenciales inválidas (401) o error del servidor
        print('Error Login: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error de conexión en Login: $e');
      return null;
    }
  }

  // Método para crear un pedido (Requiere Token)
  Future<bool> createOrder(String token, Map<String, dynamic> orderData) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/pedidos');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Token JWT en el header
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Error creando pedido: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error conexión pedido: $e');
      return false;
    }
  }

}

