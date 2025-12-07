import 'package:flutter/material.dart';

/// Modelo que representa un estado de pedido
/// Coincide con la tabla estados_pedido de la base de datos
class OrderStatus {
  final int id;
  final String name;
  final int colorValue;

  const OrderStatus({
    required this.id,
    required this.name,
    required this.colorValue,
  });

  /// Obtener el color como objeto Color
  Color get color => Color(colorValue);

  /// Lista de todos los estados
  static const List<OrderStatus> allStatuses = [
    OrderStatus(
      id: 0,
      name: 'Pendiente',
      colorValue: 0xFFFF9800, // Colors.orange.shade400
    ),
    OrderStatus(
      id: 1,
      name: 'Pendiente de Pago',
      colorValue: 0xFFFFB300, // Colors.amber.shade600
    ),
    OrderStatus(
      id: 2,
      name: 'Procesado',
      colorValue: 0xFF66BB6A, // Colors.green.shade500
    ),
    OrderStatus(
      id: 3,
      name: 'Enviado',
      colorValue: 0xFFE53935, // Colors.red.shade600
    ),
    OrderStatus(
      id: 4,
      name: 'Completado',
      colorValue: 0xFF2196F3, // Colors.blue.shade500
    ),
    OrderStatus(
      id: 5,
      name: 'Cancelado',
      colorValue: 0xFF9C27B0, // Colors.purple.shade500
    ),
    OrderStatus(
      id: 6,
      name: 'Devuelto',
      colorValue: 0xFF388E3C, // Colors.green.shade700
    ),
    OrderStatus(
      id: 7,
      name: 'Reembolsado',
      colorValue: 0xFF6D4C41, // Colors.brown.shade500
    ),
    OrderStatus(
      id: 8,
      name: 'Pago Fallido',
      colorValue: 0xFF00897B, // Colors.teal.shade600
    ),
  ];

  /// Obtener un estado por su ID
  static OrderStatus? getById(int id) {
    try {
      return allStatuses.firstWhere((status) => status.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtener un estado por su nombre
  static OrderStatus? getByName(String name) {
    try {
      return allStatuses.firstWhere(
        (status) => status.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtener el color de un estado por su nombre
  static Color getColorByName(String name) {
    final status = getByName(name);
    return status?.color ?? Colors.grey.shade600;
  }

  /// Obtener todos los estados como lista de mapas (útil para widgets)
  static List<Map<String, dynamic>> toMapList() {
    return allStatuses
        .map((status) => {
              'id': status.id,
              'name': status.name,
            })
        .toList();
  }

  @override
  String toString() => 'OrderStatus(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderStatus && other.id == id && other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
