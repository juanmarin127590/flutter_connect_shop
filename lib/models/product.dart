class Product {
  final int id;
  final String sku;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final int? stock;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.stock,
  });

  // Factory Constructor adaptado a tu Entidad Java "Producto"
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // 1. Mapeo exacto con 'idProducto' de Java
      id: json['idProducto'] ?? 0,

      // 2. SKU (código único)
      sku: json['sku'] ?? '',

      // 3. Mapeo exacto con 'nombreProducto' de Java
      name: json['nombreProducto'] ?? 'Sin nombre',

      // 4. Mapeo exacto con 'descripcionLarga' de Java
      description: json['descripcionLarga'] ?? '',

      // 5. Mapeo exacto con 'precio'. Convertimos a double
      price: (json['precio'] != null)
          ? double.tryParse(json['precio'].toString()) ?? 0.0
          : 0.0,

      // 6. Mapeo exacto con 'imagenUrl' de Java
      imageUrl: json['imagenUrl'] ?? 'assets/images/logo.png',

      // 7. Extracción inteligente de Categoría
      category: json['categoria'] != null
          ? (json['categoria']['nombreCategoria'] ?? 'General')
          : 'General',

      // 8. Stock disponible (cantidadStock en el backend)
      stock: json['cantidadStock'],
    );
  }

  // Método opcional para enviar datos al servidor
  Map<String, dynamic> toJson() {
    return {
      'idProducto': id,
      'sku': sku,
      'nombreProducto': name,
      'descripcionLarga': description,
      'precio': price,
      'cantidadStock': stock,
      'imagenUrl': imageUrl,
    };
  }
}

final List<Product> loadedProducts = [
  Product(
    id: 1,
    sku: "LAPTOP-PRO-001",
    name: "Laptop Profesional",
    price: 1999,
    imageUrl: "assets/images/laptop-7334774_1920.jpg",
    description: "Laptop de alta gama para profesionales",
    category: "Electrónica",
  ),
  Product(
    id: 2,
    sku: "TECLADO-MEC-002",
    name: "Teclado Mecánico",
    price: 120,
    imageUrl: "assets/images/keyboard-7386244_1920.jpg",
    description: "Teclado mecánico para gaming",
    category: "Electrónica",
  ),
  Product(
    id: 3,
    sku: "AURI-INAL-003",
    name: "Auriculares Inalámbricos",
    price: 75,
    imageUrl: "assets/images/beats-3273952_1920.jpg",
    description: "Auriculares con cancelación de ruido",
    category: "Electrónica",
  ),

  Product(
    id: 4,
    sku: "MONITOR-ULTRA-004",
    name: "Monitor UltraWide",
    price: 490,
    imageUrl: "assets/images/Monitor UltraWide-2557299_1920.jpg",
    description: "Monitor ultrawide para productividad",
    category: "Electrónica",
  ),

  Product(
    id: 5,
    sku: "MOUSE-ERG-005",
    name: "Mouse Ergonómico",
    price: 60,
    imageUrl: "assets/images/Mouse-2341642_1920.jpg",
    description: "Mouse ergonómico inalámbrico",
    category: "Electrónica",
  ),
  Product(
    id: 6,
    sku: "SILLA-GAMER-006",
    name: "Silla Gamer",
    price: 300,
    imageUrl: "assets/images/chair gamer-7862491.jpg",
    description: "Silla ergonómica para gaming",
    category: "Muebles",
  ),

  Product(
    id: 7,
    sku: "WEBCAM-HD-007",
    name: "Webcam HD",
    price: 85,
    imageUrl: "assets/images/web-cam-796227_1920.jpg",
    description: "Webcam 1080p para videoconferencias",
    category: "Electrónica",
  ),
  Product(
    id: 8,
    sku: "IMPRESORA-MULTI-008",
    name: "Impresora Multifunción",
    price: 245,
    imageUrl: "assets/images/printer-1516578_1920.jpg",
    description: "Impresora multifunción a color",
    category: "Electrónica",
  ),

  Product(
    id: 9,
    sku: "LIBRO-CLASSIC-009",
    name: "Books Clásicos",
    price: 29.99,
    imageUrl: "assets/images/photo-1544947950-fa07a98d237f.jpeg",
    description: "Impresora multifunción a color",
    category: "Libros",
  ),

  Product(
    id: 10,
    sku: "PANTALON-CAS-010",
    name: "Pantalon Casual",
    price: 25.99,
    imageUrl: "assets/images/photo-1594633312681-425c7b97ccd1.jpeg",
    description:
        "pantalon casual para uso diario, hecho de algodón cómodo y duradero.",
    category: "Moda",
  ),
  Product(
    id: 11,
    sku: "SILLA-MINIMAL-011",
    name: "Silla minimalista",
    price: 89.67,
    imageUrl: "assets/images/photo-1586023492125-27b2c045efd7.jpeg",
    description:
        "Silla de diseño minimalista para oficina sala de estar o cualquier espacio que necesite un toque moderno y elegante.",
    category: "Muebles",
  ),
  Product(
    id: 12,
    sku: "JUEGO-OLLAS-012",
    name: "Juego de ollas de cerámica",
    price: 120.50,
    imageUrl: "assets/images/photo-1556909114-f6e7ad7d3136.jpeg",
    description: "Impresora multifunción a color",
    category: "Hogar",
  ),
];
