/// Modelo que representa un Usuario en la aplicación
/// Este modelo mapea la entidad Usuario del backend
class User {
  final int? id;
  final String nombre;
  final String apellidos;
  final String email;
  final String telefono;
  final String? password; // Solo se usa al registrar, no se recibe del backend
  final String? rol;
  final bool? activo;

  User({
    this.id,
    required this.nombre,
    required this.apellidos,
    required this.email,
    required this.telefono,
    this.password,
    this.rol,
    this.activo,
  });

  /// Constructor factory para crear un User desde JSON (respuesta del backend)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['idUsuario'],
      nombre: json['nombre'] ?? '',
      apellidos: json['apellidos'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      rol: json['rol'] ?? 'CLIENTE',
      activo: json['activo'] ?? true,
    );
  }

  /// Convierte el User a JSON para enviar al backend (registro)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'idUsuario': id,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'telefono': telefono,
      if (password != null) 'password': password,
      if (rol != null) 'rol': rol,
      if (activo != null) 'activo': activo,
    };
  }

  /// Método helper para crear un User para registro
  /// Solo incluye los campos necesarios para crear un nuevo cliente
  Map<String, dynamic> toRegisterJson() {
    return {
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'password': password ?? '',
      'telefono': telefono,
      // El backend asigna automáticamente rol='CLIENTE' y activo=true
    };
  }

  /// Copia el User con algunos campos modificados
  User copyWith({
    int? id,
    String? nombre,
    String? apellidos,
    String? email,
    String? telefono,
    String? password,
    String? rol,
    bool? activo,
  }) {
    return User(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellidos: apellidos ?? this.apellidos,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      password: password ?? this.password,
      rol: rol ?? this.rol,
      activo: activo ?? this.activo,
    );
  }

  /// Devuelve el nombre completo del usuario
  String get nombreCompleto => '$nombre $apellidos';
}
