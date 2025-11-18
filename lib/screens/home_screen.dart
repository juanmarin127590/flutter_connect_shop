import 'package:ecommerce_connect_shop/models/product.dart';
import 'package:ecommerce_connect_shop/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar reemplaza a la <nav> del HTML
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6F9), // O el color de tu navbar
        elevation: 1, // Sombra ligera como shadow-sm
        title: Row(
          children: [
            // Logo
            Image.asset('assets/images/logo.png', height: 40),
            const SizedBox(width: 10),
            const Text(
              "Connect Shop",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // Icono del carrito con contador (Badge)
          Consumer<CartProvider>(
            builder: (_, cart, ch) => Stack(
              alignment: Alignment.center,
              children: [
                ch!,
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.itemCount}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  )
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.black54),
              onPressed: () {
                // Aquí navegaremos a la pantalla del carrito más adelante
                print("Ir al carrito");
              },
            ),
          ),
        ],
      ),
      // GridView reemplaza al <div class="row"> con productos
      body: GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: loadedProducts.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columnas
          childAspectRatio: 3 / 4, // Relación de aspecto de la tarjeta
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (ctx, i) => ProductItem(product: loadedProducts[i]),
      ),
    );
  }
}

// Widget separado para cada producto (Equivalente a createProductCard en JS)
class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Container con decoración reemplaza a .card y sus sombras CSS
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Imagen
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Detalles
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "\$${product.price}",
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                // Botón Agregar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // btn-warning
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Llamada a la lógica del Provider
                      Provider.of<CartProvider>(context, listen: false).addToCart(product);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} agregado al carrito!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text("Agregar"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
