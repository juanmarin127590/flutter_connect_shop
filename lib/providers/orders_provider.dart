import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/order.dart';
import '../services/api_service.dart';

class OrdersProvider extends ChangeNotifier {
  List<Order> _orders = [];
  
  List<Order> get orders => [..._orders];

  /// Obtener pedidos del usuario autenticado
  Future<void> fetchOrders(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/pedidos');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _orders = data.map((json) => Order.fromJson(json)).toList();
        // Ordenamos del más reciente al más antiguo
        _orders.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching orders: $e");
      rethrow;
    }
  }

  /// Obtener TODOS los pedidos del sistema (ADMIN)
  Future<void> fetchAllOrdersAdmin(String token) async {
    try {
      final apiService = ApiService();
      final List<dynamic> data = await apiService.getAllOrdersAdmin(token);
      
      _orders = data.map((json) => Order.fromJson(json)).toList();
      // Ordenamos del más reciente al más antiguo
      _orders.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      print("Error fetching all orders (admin): $e");
      rethrow;
    }
  }

  /// Actualizar el estado de un pedido (ADMIN)
  Future<bool> updateOrderStatus(String token, int orderId, int statusId) async {
    try {
      final apiService = ApiService();
      final success = await apiService.updateOrderStatus(token, orderId, statusId);
      
      if (success) {
        // Actualizar el estado localmente para reflejar el cambio inmediatamente
        final orderIndex = _orders.indexWhere((o) => o.id == orderId);
        if (orderIndex != -1) {
          // Recargar los pedidos para obtener el estado actualizado
          await fetchAllOrdersAdmin(token);
        }
      }
      
      return success;
    } catch (e) {
      print("Error updating order status: $e");
      rethrow;
    }
  }
}