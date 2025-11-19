import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumimos el provider para acceder a los datos
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Carrito de Compras"),
        backgroundColor: const Color(0xFFF4F6F9),
      ),
      body: Column(
        children: [
          // 1. Lista de Artículos (Expandida para ocupar el espacio disponible)
          Expanded(
            child: cart.cartItems.isEmpty
                ? const Center(
                    child: Text(
                      "No hay artículos en el carrito",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.cartItems.length,
                    itemBuilder: (context, i) {
                      final item = cart.cartItems[i];
                      // CartItemWidget: Componente visual de cada fila
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(item.product.imageUrl),
                              backgroundColor: Colors.transparent,
                            ),
                            title: Text(item.product.name),
                            subtitle: Text(
                              "Total: \$${(item.product.price * item.quantity).toStringAsFixed(2)}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("${item.quantity} x \$${item.product.price}"),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Color.fromARGB(255, 236, 181, 29)),
                                  onPressed: () {
                                    // Llamada a la lógica para eliminar
                                    Provider.of<CartProvider>(context, listen: false)
                                        .removeFromCart(item.product.id);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // 2. Sección de Resumen y Total (Footer)
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  // Chip es un widget visualmente agradable para etiquetas
                  Chip(
                    label: Text(
                      "\$${cart.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  TextButton(
                    onPressed: cart.cartItems.isEmpty 
                        ? null 
                        : () {
                            // Aquí iría la lógica de finalizar compra (Checkout)
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("¡Compra confirmada!"))
                            );
                            cart.clear(); // Limpiamos el carrito
                          },
                    child: const Text("COMPRAR"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
      



