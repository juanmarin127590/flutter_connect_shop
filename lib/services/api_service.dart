import 'dart:convert';
import 'package:flutter_connect_shop/config/constants.dart';
import 'package:flutter_connect_shop/models/delivery_address.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  // Obtener lista de productos desde una API
  Future<List<Product>> getProducts() async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.productsEndpoint}',
    );

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
        body: jsonEncode({'email': email, 'password': password}),
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
  Future<Map<String, dynamic>> createOrder(String token, Map<String, dynamic> orderData) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/pedidos');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Inyectamos el token Bearer
        },
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("Pedido creado con éxito: ${response.body}");
        return {'success': true, 'message': 'Pedido creado exitosamente'};
      } else {
        print(
          'Error creando pedido: ${response.statusCode} - ${response.body}',
        );
        
        // Extraer mensaje específico del backend
        String errorMessage = 'Error al procesar el pedido';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else if (errorData['error'] != null) {
            errorMessage = errorData['error'];
          }
        } catch (e) {
          errorMessage = 'Error ${response.statusCode}: No se pudo procesar el pedido';
        }
        
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      print('Excepción al crear pedido: $e');
      return {'success': false, 'message': 'Error de conexión. Verifica tu internet e intenta nuevamente.'};
    }
  }

  // REGISTRO DE NUEVO USUARIO
  Future<bool> registerUser(
    String nombre,
    String apellidos,
    String email,
    String password,
    String telefono,
  ) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/usuarios',
    ); // Endpoint /api/usuarios

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'apellidos': apellidos,
          'email': email,
          'password': password,
          'telefono': telefono,
          // El backend debería asignar el rol 'CLIENTE' y 'activo: true' por defecto
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true; // Registro exitoso
      } else {
        print('Error Registro: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Excepción registro: $e');
      return false;
    }
  }

  // Obtener direcciones del usuario
  Future<List<dynamic>> getDirecciones(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/direcciones');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar direcciones');
      }
    } catch (error) {
      throw Exception('Error de conexión: $error');
    }
  }

  // Crear nueva dirección
  Future<Map<String, dynamic>?> crearDireccion(
    String token,
    Direccion direccion,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/direcciones');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(direccion.toJson()),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  // Actualizar dirección
  Future<Map<String, dynamic>?> actualizarDireccion(
    String token,
    int idDireccion,
    Direccion direccion,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/direcciones/$idDireccion');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(direccion.toJson()),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  // Eliminar dirección
  Future<bool> eliminarDireccion(String token, int idDireccion) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/direcciones/$idDireccion');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 204;
    } catch (error) {
      return false;
    }
  }

  /// Crear un nuevo producto (ADMIN)
  Future<Product> createProduct(
    String token,
    Map<String, dynamic> productData,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/productos');

    print('🌐 API - Creando producto en: $url');
    print('📦 API - Datos a enviar: $productData');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );

      print('📡 API - Status Code: ${response.statusCode}');
      print('📡 API - Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ API - Producto creado exitosamente');
        return Product.fromJson(data);
      } else {
        print('❌ API - Error del servidor: ${response.body}');
        throw Exception(
          'Error al crear producto (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('❌ API - Excepción: $e');
      rethrow;
    }
  }

  /// Actualizar un producto existente (ADMIN)
  Future<Product> updateProduct(
    String token,
    int productId,
    Map<String, dynamic> productData,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/productos/$productId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(productData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Error al actualizar producto: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión al actualizar producto: $e');
    }
  }

  /// Eliminar (desactivar) un producto (ADMIN)
  Future<bool> deleteProduct(String token, int productId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/productos/$productId');

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      throw Exception('Error de conexión al eliminar producto: $e');
    }
  }

  /// Obtener todas las categorías disponibles
  Future<List<dynamic>> getCategories() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/categorias');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cargar categorías');
      }
    } catch (e) {
      throw Exception('Error de conexión al cargar categorías: $e');
    }
  }

    /// Obtener TODOS los pedidos del sistema (ADMIN)
    Future<List<dynamic>> getAllOrdersAdmin(String token) async {
      final url = Uri.parse('${ApiConstants.baseUrl}/pedidos/admin/all');
  
      try {
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
  
        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          throw Exception('Error al cargar pedidos: ${response.body}');
        }
      } catch (e) {
        throw Exception('Error de conexión al cargar pedidos: $e');
      }
    }
  
    /// Actualizar el estado de un pedido (ADMIN)
    Future<bool> updateOrderStatus(String token, int orderId, int statusId) async {
      final url = Uri.parse('${ApiConstants.baseUrl}/pedidos/admin/$orderId/estado?idEstado=$statusId');
  
      try {
        final response = await http.put(
          url,
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
  
        if (response.statusCode == 200) {
          return true;
        } else {
          throw Exception('Error al actualizar estado: ${response.body}');
        }
      } catch (e) {
        throw Exception('Error de conexión al actualizar estado: $e');
      }
    }
  

}
