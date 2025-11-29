import '../../models/user.dart';

/// Interfaz (contrato) para operaciones relacionadas con usuarios
/// Define las operaciones CRUD y de gestión de usuarios
abstract class UserRepository {
  /// Registra un nuevo usuario en el sistema
  /// Retorna el User creado si es exitoso
  /// Lanza excepciones específicas si falla (email duplicado, validación, etc.)
  Future<User> register({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    required String telefono,
  });

  /// Obtiene los datos del usuario actual autenticado
  /// Requiere un token válido
  Future<User> getCurrentUser(String token);

  /// Actualiza los datos del usuario
  /// Retorna el User actualizado
  Future<User> updateUser({
    required String token,
    required int userId,
    required Map<String, dynamic> updates,
  });

  /// Obtiene un usuario por su ID
  Future<User> getUserById(int id);

  /// Verifica si un email ya está registrado
  Future<bool> emailExists(String email);
}
