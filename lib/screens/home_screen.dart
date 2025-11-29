import 'package:flutter_connect_shop/models/product.dart';
import 'package:flutter_connect_shop/providers/auth_provider.dart';
import 'package:flutter_connect_shop/providers/cart_provider.dart';
import 'package:flutter_connect_shop/providers/products_provider.dart';
import 'package:flutter_connect_shop/screens/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_connect_shop/screens/catalog_screen.dart';
import 'package:flutter_connect_shop/screens/login_screen.dart';
import 'package:flutter_connect_shop/screens/orders_screen.dart';
import 'package:flutter_connect_shop/screens/product_detail_screen.dart';
import 'package:flutter_connect_shop/screens/profile_screen.dart';
import 'package:flutter_connect_shop/screens/register_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback para esperar a que termine el build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(
        context,
        listen: false,
      ).fetchAndSetProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los productos del Provider (ya no de la lista estática dummy)
    final productsData = Provider.of<ProductsProvider>(context);
    final products = productsData.items;
    final isLoading = productsData.isLoading;

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
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
            // Barra de búsqueda expandida
            Expanded(
              child: Padding(
                // Añadimos padding para reducir el ancho de la barra
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  decoration: InputDecoration(
                    isDense: true, // Reduce la altura del TextField
                    hintText: 'Buscar en Connect Shop...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.black54,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 10,
                    ),
                  ),
                  onChanged: (value) {
                    // Lógica de búsqueda aquí : Implementar filtro de productos a futuro
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          // Icono del carrito con contador (Badge)
          Padding(
            padding: const EdgeInsets.only(right: 20.0), // Margen a la derecha
            child: Consumer<CartProvider>(
              builder: (_, cart, ch) => Stack(
                alignment: Alignment.center,
                children: [
                  ch!,
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black54),
                onPressed: () {
                  // Aquí navegaremos a la pantalla del carrito
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Cabecera del menú
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.orange),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 50,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Connect Shop',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                  const SizedBox(height: 4),
                  // Mensaje de bienvenida con el nombre del usuario
                  Consumer<AuthProvider>(
                    builder: (ctx, authProvider, _) {
                      if (authProvider.isAuthenticated && authProvider.userEmail != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '¡Bienvenido,',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              '${authProvider.userEmail!}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        );
                      }
                      return const Text(
                        'Bienvenido, invitado',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Opciones del menú (replicando tu navbar)
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () => Navigator.pop(context), // Cierra el menú
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Catálogo'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CatalogScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Carrito'),
              onTap: () {
                Navigator.pop(context); // Cierra el menú primero
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Mis Pedidos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
            ),
            const Divider(), // Línea divisora
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mi Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Registro'),
              onTap: () {
                // Tarea: Implementar RegisterScreen similar a LoginScreen
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Spinner mientras carga
          : RefreshIndicator(
              // Al refrescar, recargamos los productos del Provider
              onRefresh: () => Provider.of<ProductsProvider>(
                context,
                listen: false,
              ).fetchAndSetProducts(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildTopSellersSection(),
                    _buildCategoriesSection(context),

                    // Título para la sección de la API
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Catálogo General",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Grid de Productos de la API
                    products.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("No se pudieron cargar los productos."),
                          )
                        // GridView para los productos principales
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(10.0),
                            itemCount: products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4, // 4 columnas
                                  childAspectRatio:
                                      3 /
                                      4, // Relación de aspecto de la tarjeta
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            //Pasmaos los productos de la BD al widget ProductItem
                            itemBuilder: (ctx, i) =>
                                ProductItem(product: products[i]),
                          ),
                  ],
                ),
              ),
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
                  // Usamos un ID único para evitar conflictos de Hero tag
                  id: -1 - index,
                  name: item['name']!,
                  price: double.parse(item['price']!.replaceAll('\$', '')),
                  imageUrl: item['image']!,
                  description: item['description'] ?? '',
                  category: item['category'] ?? '',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget para la sección de categorías
  Widget _buildCategoriesSection(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _CategoryCard(
            title: 'Relojes favoritos',
            subcategories: [
              {
                'name': 'Mujeres',
                'image': 'assets/images/photo-1544117519-31a4b719223d.jpeg',
              },
              {
                'name': 'Hombres',
                'image': 'assets/images/photo-1523275335684-37898b6baf30.jpeg',
              },
              {
                'name': 'Niñas',
                'image': 'assets/images/photo-1594534475808-b18fc33b045e.jpeg',
              },
              {
                'name': 'Niños',
                'image': 'assets/images/photo-1544117519-31a4b719223d.jpeg',
              },
            ],
            onTap: () {
              /* Navegar a la página de catálogo de relojes */
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CatalogScreen(categoryFilter: 'Relojes'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _CategoryCard(
            title: 'Mejora tu PC aquí',
            subcategories: [
              {
                'name': 'Portátiles',
                'image': 'assets/images/laptop-7334774_1920.jpg',
              },
              {
                'name': 'Equipo de PC',
                'image': 'assets/images/photo-1587831990711-23ca6441447b.jpeg',
              },
              {
                'name': 'Discos duros',
                'image': 'assets/images/photo-1597872200969-2b65d56bd16b.jpeg',
              },
              {
                'name': 'Monitores',
                'image': 'assets/images/Monitor UltraWide-2557299_1920.jpg',
              },
            ],
            onTap: () {
              /* Navegar a la página de catálogo de PC */
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const CatalogScreen(categoryFilter: 'Electrónica'),
                ),
              );
            },
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
    // LÓGICA DE DETECCIÓN DE IMAGEN
    final isNetworkImage = product.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de detalles del producto
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
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
              child: Hero(
                tag: product.id,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  child: isNetworkImage
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) => Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ), // Fallback si la URL falla
                        )
                      : Image.asset(product.imageUrl, fit: BoxFit.cover),
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
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
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
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).addToCart(product);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.name} agregado al carrito!',
                            ),
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
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
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
                    Text(
                      sub['name']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
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

// Datos de ejemplo (en una aplicación real, esto vendría de una API o base de datos)
final List<Map<String, String>> topSellers = [
  {
    "name": "Crocs Clásicos",
    "price": "\$29.99",
    "image": "assets/images/crocs-clasicos-photo.jpeg",
    "description": "Comodidad y estilo en cada paso",
    "category": "Calzado",
  },
  {
    "name": "Camiseta Básica",
    "price": "\$12.99",
    "image": "assets/images/camiseta-basica-blanca.jpg",
    "description": "Camiseta de algodón suave y transpirable",
    "category": "Ropa",
  },
  {
    "name": "Conjunto Negro",
    "price": "\$45.99",
    "image": "assets/images/photo-1551028719-00167b16eac5.jpeg",
    "description": "Elegante conjunto para cualquier ocasión",
    "category": "Ropa",
  },
  {
    "name": "Camiseta Granate",
    "price": "\$18.99",
    "image": "assets/images/photo-1571945153237-4929e783af4a.jpeg",
    "description": "Camiseta de color granate con ajuste cómodo",
    "category": "Ropa",
  },
];
