import 'package:flutter/material.dart';
import 'package:flutter_connect_shop/models/product.dart';
import 'package:flutter_connect_shop/providers/products_provider.dart';
import 'package:flutter_connect_shop/screens/product_detail_screen.dart';
import 'package:flutter_connect_shop/widgets/smart_image.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatelessWidget {
  final String? categoryFilter; // Opcional: Si es null, muestra todo

  const CatalogScreen({super.key, this.categoryFilter});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los productos del Provider (ya no de la lista estática dummy)
    final productsData = Provider.of<ProductsProvider>(context);
    final products = productsData.items;
    final isLoading = productsData.isLoading;


    final displayedProducts = categoryFilter == null
        ? products
        : products
              .where((prod) => prod.category == categoryFilter)
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Catálogo de Productos')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => productsData.fetchAndSetProducts(),
              child:
      displayedProducts.isEmpty
          ? Center(
              child: Text(
                "No hay productos en esta categoría.'$categoryFilter'",
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: displayedProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 2 columnas
                childAspectRatio: 3 / 4, // Relación de aspecto de la tarjeta
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (ctx, i) =>
                  _CatalogoItem(product: displayedProducts[i]),
            ),
          ),
    );
  }
}

class _CatalogoItem extends StatelessWidget {
  final Product product;

  const _CatalogoItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Acción al tocar el producto (opcional)
        Navigator.push(
          context,
            MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
        );
      },

      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SmartImage(
                imageUrl: product.imageUrl,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$${product.price}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
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
