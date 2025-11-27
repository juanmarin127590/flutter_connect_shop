import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  bool _isLoading = false;

  // Getters
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final api = ApiService();
    // Llamamos al servicio (se asume que api.login devuelve String? o Future<String?>)
    final tokenRecibido = await api.login(email, password);

    if (tokenRecibido != null) {
      _token = tokenRecibido; // Asignar el token directamente
      // Aquí podrías guardar el token en Shared Preferences para persistencia
      print("Token JWT recibido: $_token"); 
      _isLoading = false;
      notifyListeners();
      return true; // Login exitoso
    }
    _isLoading = false;
    notifyListeners();
    return false; // Login fallido
  }



  void logout() {
    _token = null;
    notifyListeners();
  }
}