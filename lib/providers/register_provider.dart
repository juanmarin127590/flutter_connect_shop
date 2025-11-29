import 'package:flutter/material.dart';
import '../core/exceptions.dart';
import '../models/user.dart';
import '../repositories/interfaces/user_repository.dart';

/// Provider encargado de gestionar el registro de nuevos usuarios
/// Separa la lógica de registro del AuthProvider (que se usa solo para login)
class RegisterProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  bool _isLoading = false;
  String? _errorMessage;
  User? _registeredUser;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get registeredUser => _registeredUser;

  // Constructor: Recibe el repositorio por inyección de dependencias
  RegisterProvider(this._userRepository);

  /// Registra un nuevo usuario en el sistema
  /// Devuelve true si el registro fue exitoso, false en caso contrario
  /// 
  /// Este método:
  /// 1. Valida que los datos sean correctos (delegado al repositorio)
  /// 2. Llama al UserRepository para crear el usuario
  /// 3. Gestiona el estado de carga
  /// 4. Captura y expone errores específicos
  Future<bool> register({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    required String telefono,
  }) async {
    // Limpiar errores previos y usuario registrado
    _errorMessage = null;
    _registeredUser = null;
    
    // Indicar que estamos procesando
    _isLoading = true;
    notifyListeners();

    try {
      // Llamar al repositorio para registrar el usuario
      // El repositorio maneja las validaciones y transformación de errores
      final user = await _userRepository.register(
        nombre: nombre,
        apellidos: apellidos,
        email: email,
        password: password,
        telefono: telefono,
      );

      _registeredUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ValidationException catch (e) {
      // Errores de validación (email inválido, contraseña corta, email duplicado, etc.)
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on NetworkException catch (e) {
      // Errores de red (sin internet, timeout, servidor no disponible)
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // Cualquier otro error inesperado
      _errorMessage = 'Error inesperado al registrar. Intenta nuevamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Limpia el mensaje de error y el usuario registrado
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpia todos los datos del provider
  void clear() {
    _errorMessage = null;
    _registeredUser = null;
    _isLoading = false;
    notifyListeners();
  }
}
