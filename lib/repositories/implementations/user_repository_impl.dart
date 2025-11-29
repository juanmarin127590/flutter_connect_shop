import 'dart:async';
import 'dart:io';
import '../../core/exceptions.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../interfaces/user_repository.dart';

/// Implementación concreta del repositorio de usuarios
/// Maneja todas las operaciones relacionadas con usuarios
/// Transforma errores HTTP en excepciones específicas de negocio
class UserRepositoryImpl implements UserRepository {
  final ApiService _apiService;

  UserRepositoryImpl(this._apiService);

  @override
  Future<User> register({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    required String telefono,
  }) async {
    try {
      // Validaciones básicas antes de enviar al backend
      _validateEmail(email);
      _validatePassword(password);
      _validateRequiredField(nombre, 'nombre');
      _validateRequiredField(apellidos, 'apellidos');
      _validateRequiredField(telefono, 'teléfono');

      // Llamar al servicio de API
      final success = await _apiService.registerUser(
        nombre,
        apellidos,
        email,
        password,
        telefono,
      );

      if (success) {
        // Si el registro fue exitoso, creamos el objeto User
        // Nota: El backend no devuelve el usuario creado, así que lo construimos
        return User(
          nombre: nombre,
          apellidos: apellidos,
          email: email,
          telefono: telefono,
          rol: 'CLIENTE',
          activo: true,
        );
      } else {
        // Si retorna false, probablemente el email ya existe
        throw ValidationException.emailAlreadyExists();
      }
    } on SocketException {
      throw NetworkException.noInternet();
    } on TimeoutException {
      throw NetworkException.timeout();
    } on ValidationException {
      // Re-lanzar excepciones de validación
      rethrow;
    } catch (e) {
      // Si es un error desconocido, lo envolvemos
      if (e.toString().contains('409') || e.toString().contains('Conflict')) {
        throw ValidationException.emailAlreadyExists();
      }
      throw NetworkException(
        'Error al registrar usuario: ${e.toString()}',
        originalError: e,
      );
    }
  }

  @override
  Future<User> getCurrentUser(String token) async {
    try {
      // TODO: Implementar cuando el backend tenga un endpoint /api/usuarios/me
      throw UnimplementedError('getCurrentUser aún no implementado en el backend');
    } catch (e) {
      throw NetworkException(
        'Error al obtener datos del usuario',
        originalError: e,
      );
    }
  }

  @override
  Future<User> updateUser({
    required String token,
    required int userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      // TODO: Implementar cuando sea necesario
      throw UnimplementedError('updateUser aún no implementado');
    } catch (e) {
      throw NetworkException(
        'Error al actualizar usuario',
        originalError: e,
      );
    }
  }

  @override
  Future<User> getUserById(int id) async {
    try {
      // TODO: Implementar cuando sea necesario
      throw UnimplementedError('getUserById aún no implementado');
    } catch (e) {
      throw NetworkException(
        'Error al obtener usuario',
        originalError: e,
      );
    }
  }

  @override
  Future<bool> emailExists(String email) async {
    try {
      // TODO: Implementar si el backend proporciona un endpoint para verificar
      throw UnimplementedError('emailExists aún no implementado');
    } catch (e) {
      return false;
    }
  }

  // Métodos privados de validación
  void _validateEmail(String email) {
    if (email.isEmpty) {
      throw ValidationException.requiredField('correo electrónico');
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      throw ValidationException.emailInvalid();
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      throw ValidationException.requiredField('contraseña');
    }
    if (password.length < 6) {
      throw ValidationException.passwordTooShort();
    }
  }

  void _validateRequiredField(String value, String fieldName) {
    if (value.isEmpty) {
      throw ValidationException.requiredField(fieldName);
    }
  }
}
