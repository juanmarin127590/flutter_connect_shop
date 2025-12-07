import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';

/// Pantalla de administración de productos
/// Solo accesible para usuarios con rol ADMINISTRADOR
class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  late Future _productsFuture;
  List<Category> _categories = [];
  bool _loadingCategories = false;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
    _loadCategories();
  }

  Future _loadProducts() async {
    return Provider.of<ProductsProvider>(
      context,
      listen: false,
    ).fetchAndSetProducts();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _loadingCategories = true;
    });

    try {
      final apiService = ApiService();
      final data = await apiService.getCategories();
      setState(() {
        _categories = data.map((json) => Category.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error cargando categorías: $e');
    } finally {
      setState(() {
        _loadingCategories = false;
      });
    }
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _productsFuture = _loadProducts();
              });
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
                onRefresh: () {
                  setState(() {
                    _productsFuture = _loadProducts();
                  });
                  return _productsFuture;
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
            if (product.stock != null)
              Text(
                'Stock: ${product.stock}',
                style: TextStyle(
                  color: (product.stock ?? 0) > 0 ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
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
    _showProductFormDialog(context, isEdit: false);
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    _showProductFormDialog(context, isEdit: true, product: product);
  }

  void _showProductFormDialog(
    BuildContext context, {
    required bool isEdit,
    Product? product,
  }) {
    final formKey = GlobalKey<FormState>();
    
    // Controladores de texto
    final skuController = TextEditingController(text: product?.sku ?? '');
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    final imageUrlController = TextEditingController(text: product?.imageUrl ?? '');
    final stockController = TextEditingController(text: product?.stock?.toString() ?? '0');

    Category? selectedCategory;

    // Buscar la categoría actual del producto si estamos editando
    if (isEdit && product != null) {
      try {
        selectedCategory = _categories.firstWhere(
          (cat) => cat.name == product.category,
        );
      } catch (e) {
        // Si no se encuentra, se quedará en null
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: Text(isEdit ? 'Editar Producto' : 'Crear Nuevo Producto'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SKU (código único del producto)
                  TextFormField(
                    controller: skuController,
                    decoration: const InputDecoration(
                      labelText: 'SKU (Código único) *',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: PROD-001',
                    ),
                    enabled: !isEdit, // SKU no se puede cambiar al editar
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El SKU es obligatorio';
                      }
                      if (value.length < 3) {
                        return 'El SKU debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Nombre del producto
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Producto *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa el nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa la descripción';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Precio
                  TextFormField(
                    controller: priceController,
                    decoration: const InputDecoration(
                      labelText: 'Precio *',
                      border: OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa el precio';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'El precio debe ser mayor a 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Stock
                  TextFormField(
                    controller: stockController,
                    decoration: const InputDecoration(
                      labelText: 'Stock Disponible *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa el stock';
                      }
                      final stock = int.tryParse(value);
                      if (stock == null || stock < 0) {
                        return 'El stock debe ser 0 o mayor';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Categoría
                  if (_loadingCategories)
                    const CircularProgressIndicator()
                  else if (_categories.isEmpty)
                    const Text(
                      'No hay categorías disponibles',
                      style: TextStyle(color: Colors.red),
                    )
                  else
                    DropdownButtonFormField<Category>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoría *',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedCategory = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona una categoría';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 16),

                  // URL de la imagen
                  TextFormField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL de la Imagen',
                      border: OutlineInputBorder(),
                      hintText: 'https://ejemplo.com/imagen.jpg',
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (!value.startsWith('http')) {
                          return 'La URL debe comenzar con http:// o https://';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop();

                  // Preparar datos del producto según el modelo del backend
                  final productData = {
                    'sku': skuController.text.trim(), // ✅ Campo obligatorio
                    'nombreProducto': nameController.text.trim(),
                    'descripcionLarga': descriptionController.text.trim(),
                    'precio': double.parse(priceController.text.trim()),
                    'cantidadStock': int.parse(stockController.text.trim()),
                    'imagenUrl': imageUrlController.text.trim().isEmpty
                        ? null
                        : imageUrlController.text.trim(),
                    'categoria': {
                      'idCategoria': selectedCategory!.id,
                    },
                    'activo': true,
                  };

                  print('📦 Datos del producto a enviar: $productData');

                  // Mostrar indicador de carga
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    final token = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).token;

                    final productsProvider = Provider.of<ProductsProvider>(
                      context,
                      listen: false,
                    );

                    bool success;
                    if (isEdit) {
                      success = await productsProvider.updateProduct(
                        token!,
                        product!.id,
                        productData,
                      );
                    } else {
                      success = await productsProvider.createProduct(
                        token!,
                        productData,
                      );
                    }

                    if (!mounted) return;
                    Navigator.of(context).pop(); // Cerrar loading

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEdit
                                ? '✅ Producto actualizado correctamente'
                                : '✅ Producto creado correctamente',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      setState(() {
                        _productsFuture = _loadProducts();
                      });
                    }
                  } catch (e) {
                    if (!mounted) return;
                    Navigator.of(context).pop(); // Cerrar loading

                    // Analizar el error para dar mensajes más específicos
                    String errorMessage = 'Error desconocido';
                    if (e.toString().contains('SKU')) {
                      errorMessage = 'Ya existe un producto con este SKU';
                    } else if (e.toString().contains('400')) {
                      errorMessage = 'Datos inválidos. Verifica todos los campos';
                    } else if (e.toString().contains('401')) {
                      errorMessage = 'No tienes autorización. Inicia sesión nuevamente';
                    } else if (e.toString().contains('Categoría')) {
                      errorMessage = 'La categoría seleccionada no existe';
                    } else {
                      errorMessage = e.toString();
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('❌ $errorMessage'),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
              ),
              child: Text(isEdit ? 'Actualizar' : 'Crear'),
            ),
          ],
        ),
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

              // Mostrar indicador de carga
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                final token = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).token;

                final productsProvider = Provider.of<ProductsProvider>(
                  context,
                  listen: false,
                );

                final success = await productsProvider.deleteProduct(
                  token!,
                  product.id,
                );

                if (!mounted) return;
                Navigator.of(context).pop(); // Cerrar loading

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Producto eliminado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    _productsFuture = _loadProducts();
                  });
                }
              } catch (e) {
                if (!mounted) return;
                Navigator.of(context).pop(); // Cerrar loading

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error al eliminar: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
