import 'package:flutter/material.dart';
import 'package:flutter_connect_shop/models/product.dart';
import 'package:flutter_connect_shop/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductDarailsScreen extends StatelessWidget {
  // Recibimos producto a mostrar como argumento
  final Product product;

  const ProductDarailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de navegación con el nombre del producto
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del producto
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Hero(
                tag: product.id,
                child: Image.asset(product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            // Nombre del producto
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precio del productojuanjuan
                  Text(
                    "\$${product.price}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Nombre del producto
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Descripción del producto
                  const Text(
                    "Descripción",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      //Boton de agregar al carrito
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            // Lógica para agregar al carrito
            Provider.of<CartProvider>(
              context,
              listen: false,
            ).addToCart(product);

            // feedback al usuario
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} agregado al carrito'),
                duration: const Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'DESHACER',
                  onPressed: () {
                    Provider.of<CartProvider>(
                      context,
                      listen: false,
                    ).removeFromCart(product.id);
                  },
                ),
              ),
            );
          },
          // Estilo del botón
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text("AGREGAR AL CARRITO"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
