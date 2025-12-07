import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/orders_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../models/order_status.dart';

/// Pantalla de administración de pedidos
/// Permite ver todos los pedidos del sistema y actualizar sus estados
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  late Future _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _loadOrders();
  }

  Future _loadOrders() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    // ✅ Llamar al método específico de administrador que carga TODOS los pedidos
    return Provider.of<OrdersProvider>(
      context,
      listen: false,
    ).fetchAllOrdersAdmin(token!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _ordersFuture = _loadOrders();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _ordersFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al cargar pedidos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _ordersFuture = _loadOrders();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else {
            return Consumer<OrdersProvider>(
              builder: (ctx, ordersData, _) => RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _ordersFuture = _loadOrders();
                  });
                },
                child: ordersData.orders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No hay pedidos registrados en el sistema',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: ordersData.orders.length,
                        itemBuilder: (ctx, i) =>
                            _buildOrderCard(ordersData.orders[i], context),
                      ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: OrderStatus.getColorByName(order.status),
          foregroundColor: Colors.white,
          child: Text(
            '#${order.id}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          'Pedido #${order.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total: \$${order.total.toStringAsFixed(2)}'),
            Text(
              order.status,
              style: TextStyle(
                color: OrderStatus.getColorByName(order.status),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(order.date),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Productos:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: item.product.imageUrl.startsWith('http')
                          ? NetworkImage(item.product.imageUrl)
                          : const AssetImage('assets/images/logo.png')
                                as ImageProvider,
                      backgroundColor: Colors.grey.shade200,
                    ),
                    title: Text(item.product.name),
                    subtitle: Text(
                      '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                    ),
                    trailing: Text(
                      '\$${(item.quantity * item.price).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(height: 24),
                const Text(
                  'Actualizar Estado:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildStatusButtons(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButtons(Order order) {
    // Obtener estados desde el modelo OrderStatus
    final statuses = OrderStatus.toMapList();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((status) {
        final isSelected = order.status == status['name'];
        return ChoiceChip(
          label: Text(status['name'] as String),
          selected: isSelected,
          onSelected: (selected) {
            if (selected && !isSelected) {
              _updateOrderStatus(
                order.id,
                status['id'] as int,
                status['name'] as String,
              );
            }
          },
          selectedColor: OrderStatus.getColorByName(status['name'] as String),
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }



  Future<void> _updateOrderStatus(
    int orderId,
    int statusId,
    String statusName,
  ) async {
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final ordersProvider = Provider.of<OrdersProvider>(
        context,
        listen: false,
      );

      final success = await ordersProvider.updateOrderStatus(
        token!,
        orderId,
        statusId,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Cerrar loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Estado actualizado a: $statusName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Recargar los pedidos
        setState(() {
          _ordersFuture = _loadOrders();
        });
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Cerrar loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al actualizar estado: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
