class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

final List<Product> loadedProducts = [
  Product(
    id: 1,
    name: "Laptop Profesional",
    price: 1999,
    imageUrl: "assets/images/laptop-7334774_1920.jpg",
    description: "Laptop de alta gama para profesionales",
  ),
  Product(
    id: 2,
    name: "Teclado Mecánico",
    price: 120,
    imageUrl: "assets/images/keyboard-7386244_1920.jpg",
    description: "Teclado mecánico para gaming",
  ),
  Product(
    id: 3,
    name: "Auriculares Inalámbricos",
    price: 75,
    imageUrl: "assets/images/beats-3273952_1920.jpg",
    description: "Auriculares con cancelación de ruido",
  ),

  Product(
    id: 4,
    name: "Monitor UltraWide",
    price: 490,
    imageUrl: "assets/images/Monitor UltraWide-2557299_1920.jpg",
    description: "Monitor ultrawide para productividad",
  ),

  Product(
    id: 5,
    name: "Mouse Ergonómico",
    price: 60,
    imageUrl: "assets/images/Mouse-2341642_1920.jpg",
    description: "Mouse ergonómico inalámbrico",
  ),
  Product(
    id: 6,
    name: "Silla Gamer",
    price: 300,
    imageUrl: "assets/images/chair gamer-7862491.jpg",
    description: "Silla ergonómica para gaming",
  ),

  Product(
    id: 7,
    name: "Webcam HD",
    price: 85,
    imageUrl: "assets/images/web-cam-796227_1920.jpg",
    description: "Webcam 1080p para videoconferencias",
  ),
  Product(
    id: 8,
    name: "Impresora Multifunción",
    price: 245,
    imageUrl: "assets/images/printer-1516578_1920.jpg",
    description: "Impresora multifunción a color",
  ),
];
