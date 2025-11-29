import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/order.dart';

class OrdersProvider extends ChangeNotifier {
  List<Order> _orders = [];
  
  List<Order> get orders => [..._orders];

  Future<void> fetchOrders(String token) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/pedidos');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Autenticación requerida
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
      throw e;
    }
  }
}