/// Interfaz (contrato) para operaciones de autenticación
/// Define QUÉ operaciones debe implementar un repositorio de autenticación
/// sin especificar el CÓMO (eso lo hacen las implementaciones)
abstract class AuthRepository {
  /// Intenta iniciar sesión con email y contraseña
  /// Retorna el token JWT si es exitoso
  /// Lanza excepciones específicas si falla
  Future<String> login({required String email, required String password});

  /// Cierra la sesión del usuario actual
  /// Limpia el token almacenado localmente
  Future<void> logout();

  /// Verifica si hay un token válido almacenado
  /// Retorna el token si existe, null si no
  Future<String?> getStoredToken();

  /// Guarda el token JWT localmente
  Future<void> saveToken(String token);

  /// Elimina el token almacenado
  Future<void> deleteToken();

  /// Verifica si el usuario está autenticado
  /// Retorna true si hay un token válido
  Future<bool> isAuthenticated();

  /// Obtiene los roles almacenados del usuario
  Future<List<String>?> getStoredRoles();

  /// Guarda los roles del usuario localmente
  Future<void> saveRoles(List<String> roles);

  /// Elimina los roles almacenados
  Future<void> deleteRoles();
}
