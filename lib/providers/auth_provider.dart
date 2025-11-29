import 'package:flutter/material.dart';
import '../core/exceptions.dart';
import '../repositories/interfaces/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor: Recibe el repositorio por inyección de dependencias
  AuthProvider(this._authRepository) {
    tryAutoLogin();
  }

  /// Intenta hacer auto-login con el token almacenado
  Future<bool> tryAutoLogin() async {
    try {
      final storedToken = await _authRepository.getStoredToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        _token = storedToken;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en auto-login: $e');
      return false;
    }
  }

  /// Inicia sesión con email y contraseña
  /// Maneja errores de forma robusta y los expone a través de errorMessage
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Usar el repositorio en lugar de ApiService directamente
      final token = await _authRepository.login(
        email: email,
        password: password,
      );

      _token = token;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      // Errores de autenticación (credenciales inválidas, etc.)
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on NetworkException catch (e) {
      // Errores de red (sin internet, timeout, etc.)
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Cualquier otro error inesperado
      _errorMessage = 'Error inesperado al iniciar sesión. Intenta nuevamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cierra la sesión del usuario
  Future<void> logout() async {
    try {
      await _authRepository.logout();
      _token = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('Error al cerrar sesión: $e');
      // Aunque haya error, limpiamos el estado local
      _token = null;
      notifyListeners();
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}