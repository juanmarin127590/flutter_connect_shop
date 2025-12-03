import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../models/product.dart';

/// Pantalla de administración de productos
/// Solo accesible para usuarios con rol ADMINISTRADOR
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  late Future _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future _loadProducts() async {
    return Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateProductDialog(context);
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _productsFuture,
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
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _productsFuture = _loadProducts();
                      });
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else {
            return Consumer<ProductsProvider>(
              builder: (ctx, productsData, _) => RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _productsFuture = _loadProducts();
                  });
                },
                child: productsData.items.isEmpty
                    ? const Center(child: Text('No hay productos disponibles'))
                    : ListView.builder(
                        itemCount: productsData.items.length,
                        itemBuilder: (ctx, i) =>
                            _buildProductItem(productsData.items[i], context),
                      ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProductItem(Product product, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: product.imageUrl.startsWith('http')
              ? NetworkImage(product.imageUrl)
              : const AssetImage('assets/images/logo.png') as ImageProvider,
          backgroundColor: Colors.grey.shade200,
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('\$${product.price.toStringAsFixed(2)}'),
            Text(
              product.category,
              style: TextStyle(color: Colors.orange.shade600, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                _showEditProductDialog(context, product);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, product),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateProductDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función de creación próximamente disponible'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editar producto: ${product.name}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar el producto "${product.name}"?\n\nEsta acción desactivará el producto del catálogo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Función de eliminación próximamente disponible',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
