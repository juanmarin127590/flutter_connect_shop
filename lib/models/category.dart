/// Modelo que representa una Categoría de productos
class Category {
  final int id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['idCategoria'] ?? 0,
      name: json['nombreCategoria'] ?? '',
      description: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategoria': id,
      'nombreCategoria': name,
      'descripcion': description,
    };
  }
}