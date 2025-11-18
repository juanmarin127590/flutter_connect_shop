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
      // ListView para permitir múltiples secciones desplazables
      body: ListView(
        children: [
          _buildTopSellersSection(),
          _buildCategoriesSection(),
          // GridView para los productos principales
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10.0),
            itemCount: loadedProducts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 columnas
              childAspectRatio: 3 / 4, // Relación de aspecto de la tarjeta
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (ctx, i) => ProductItem(product: loadedProducts[i]),
          ),
        ],
      ),
    );
  }

// Widget para la sección "Los Más Vendidos"
  Widget _buildTopSellersSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Los Más Vendidos en Ropa, Zapatos y Joyería',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // GridView para mostrar los productos en una cuadrícula.
          GridView.builder(
            // Evita que el GridView intente ocupar todo el espacio vertical.
            shrinkWrap: true,
            // Desactiva el scroll del GridView para que el SingleChildScrollView principal controle el scroll.
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 2 columnas
              crossAxisSpacing: 8, // Espacio horizontal
              mainAxisSpacing: 8, // Espacio vertical
              childAspectRatio: 0.75, // Relación de aspecto para las tarjetas
            ),
            itemCount: topSellers.length,
            itemBuilder: (context, index) {
              final item = topSellers[index];
             return ProductItem(
                product: Product(
                  id: index, // O un ID único si lo tienes
                  name: item['name']!,
                  price: double.parse(item['price']!.replaceAll('\$', '')),
                  imageUrl: item['image']!, 
                  description: "Descripción del producto", // Puedes añadir una descripción genérica o dejarla vacía
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget para la sección de categorías
  Widget _buildCategoriesSection() {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _CategoryCard(
            title: 'Relojes favoritos',
            subcategories: [
              {'name': 'Mujeres', 'image': 'assets/images/photo-1544117519-31a4b719223d.jpeg'},
              {'name': 'Hombres', 'image': 'assets/images/photo-1523275335684-37898b6baf30.jpeg'},
              {'name': 'Niñas', 'image': 'assets/images/photo-1594534475808-b18fc33b045e.jpeg'},
              {'name': 'Niños', 'image': 'assets/images/photo-1544117519-31a4b719223d.jpeg'},
            ],
            onTap: () { /* Navegar a la página de catálogo de relojes */ },
          ),
          const SizedBox(height: 16),
          _CategoryCard(
            title: 'Mejora tu PC aquí',
            subcategories: [
              {'name': 'Portátiles', 'image': 'assets/images/laptop-7334774_1920.jpg'},
              {'name': 'Equipo de PC', 'image': 'assets/images/photo-1587831990711-23ca6441447b.jpeg'},
              {'name': 'Discos duros', 'image': 'assets/images/photo-1597872200969-2b65d56bd16b.jpeg'},
              {'name': 'Monitores', 'image': 'assets/images/Monitor UltraWide-2557299_1920.jpg'},
            ],
            onTap: () { /* Navegar a la página de catálogo de PC */ },
          ),
          // Aquí se podrían agregar las otras tarjetas de categoría...
        ],
      ),
    );
  }

}

// Widget separado para cada producto
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

// Widget reutilizable para una tarjeta de categoría
class _CategoryCard extends StatelessWidget {
  final String title;
  final List<Map<String, String>> subcategories;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subcategories,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                final sub = subcategories[index];
                // Determina si la imagen es de la red o un asset local
                final isNetworkImage = sub['image']!.startsWith('http');
                
                return Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: isNetworkImage
                            ? Image.network(sub['image']!, fit: BoxFit.cover)
                            : Image.asset(sub['image']!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(sub['name']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: onTap,
                child: const Text('Descubre más'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizable para una tarjeta de producto
class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product, required String imageUrl, required String name, required String price});
  

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      clipBehavior: Clip.antiAlias, // Recorta el contenido (la imagen) a la forma de la tarjeta
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover, // La imagen cubre todo el espacio disponible
              // Indicador de carga mientras la imagen de red se descarga
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              // Widget a mostrar si hay un error al cargar la imagen
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, color: Colors.grey);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(product.price.toString(), style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Datos de ejemplo (en una aplicación real, esto vendría de una API o base de datos)
final List<Map<String, String>> topSellers = [
  {
    "name": "Crocs Clásicos",
    "price": "\$29.99",
    "image": "assets/images/Monitor UltraWide-2557299_1920.jpg",
  },
  {
    "name": "Camiseta Básica",
    "price": "\$12.99",
    "image": "assets/images/keyboard-7386244_1920.jpg",
  },
  {
    "name": "Conjunto Negro",
    "price": "\$45.99",
    "image": "assets/images/photo-1551028719-00167b16eac5.jpeg",
  },
  {
    "name": "Camiseta Granate",
    "price": "\$18.99",
    "image": "assets/images/printer-1516578_1920.jpg",
  },
];
