import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/exceptions.dart';
import '../../services/api_service.dart';
import '../interfaces/auth_repository.dart';

/// Implementación concreta del repositorio de autenticación
/// Usa ApiService para comunicarse con el backend
/// Maneja el almacenamiento local del token con SharedPreferences
class AuthRepositoryImpl implements AuthRepository {
  final ApiService _apiService;
  static const String _tokenKey = 'jwt_token';

  AuthRepositoryImpl(this._apiService);

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      // Llamar al servicio de API
      final token = await _apiService.login(email, password);

      if (token != null && token.isNotEmpty) {
        // Guardar el token automáticamente
        await saveToken(token);
        return token;
      } else {
        // Si no hay token, las credenciales son inválidas
        throw AuthException.invalidCredentials();
      }
    } on SocketException {
      // Error de red (sin internet)
      throw NetworkException.noInternet();
    } on TimeoutException {
      // Timeout
      throw NetworkException.timeout();
    } on AuthException {
      // Re-lanzar excepciones de autenticación
      rethrow;
    } catch (e) {
      // Cualquier otro error
      throw NetworkException(
        'Error al intentar iniciar sesión: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await deleteToken();
    } catch (e) {
      // Si hay error al eliminar el token, lo registramos pero no fallamos
      print('Error al eliminar token en logout: $e');
    }
  }

  @override
  Future<String?> getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error al obtener token almacenado: $e');
      return null;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      throw DataException(
        'Error al guardar el token de sesión',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (e) {
      throw DataException(
        'Error al eliminar el token de sesión',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }
}
