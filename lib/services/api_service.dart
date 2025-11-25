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
  
  // Método esqueleto para Login (lo implementaremos luego)
  Future<bool> login(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    return response.statusCode == 200;
  }

}

