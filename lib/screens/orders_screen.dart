import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/orders_provider.dart';
import '../providers/auth_provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future _ordersFuture;

  Future _obtainOrdersFuture() {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    return Provider.of<OrdersProvider>(context, listen: false).fetchOrders(token!);
  }

  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Pedidos")),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (dataSnapshot.error != null) {
            return const Center(child: Text("Ocurrió un error al cargar pedidos"));
          } else {
            return Consumer<OrdersProvider>(
              builder: (ctx, orderData, child) => ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (ctx, i) {
                  final order = orderData.orders[i];
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ExpansionTile( // Permite desplegar para ver detalles
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pedido: ${order.id}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text("Total: \$${order.total.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      subtitle: Text(
                        "${DateFormat('dd/MM/yyyy hh:mm').format(order.date)} - ${order.status}",
                        style: TextStyle(
                            color: order.status == 'Pendiente de Pago' 
                                ? const Color.fromARGB(255, 255, 0, 0) 
                                : Colors.green),
                      ),
                      children: order.items.map((item) => ListTile(
                        leading: CircleAvatar(
                          backgroundImage: item.product.imageUrl.startsWith('http')
                              ? NetworkImage(item.product.imageUrl)
                              : const AssetImage('assets/images/logo.png') as ImageProvider,
                        ),
                        title: Text(item.product.name),
                        trailing: Text("${item.quantity} x \$${item.price}"),
                      )).toList(),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}