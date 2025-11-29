import 'product.dart'; // Importamos para reutilizar la lógica de imagen/nombre

class OrderItem {
  final int id;
  final int quantity;
  final double price;
  final Product product;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.price,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['idDetallePedido'] ?? 0,
      quantity: json['cantidad'] ?? 0,
      price: json['precioUnitario'] ?? 0.0,
      // Reutilizamos el factory de Product que ya creaste
      product: Product.fromJson(json['producto']),
    );
  }
}

class Order {
  final int id;
  final double total;
  final String status;
  final DateTime date;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.total,
    required this.status,
    required this.date,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['idPedido'],
      total: json['montoTotal'] ?? 0.0,
      // Accedemos al objeto anidado 'estadoPedido' -> 'nombreEstado'
      status: json['estadoPedido'] != null 
          ? json['estadoPedido']['nombreEstado'] 
          : 'Desconocido',
      date: DateTime.parse(json['fechaPedido']),
      // Mapeamos la lista de detalles
      items: (json['detalles'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }
}