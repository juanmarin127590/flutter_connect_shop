import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  bool _isLoading = false;

  // Getters
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  bool get isLoading => _isLoading;

  // Constructor: Intenta cargar el token apenas se crea el Provider
  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return;

    final extractedToken = prefs.getString('userData');
    _token = extractedToken;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final api = ApiService();
    // Llamamos al servicio
    final tokenRecibido = await api.login(email, password);

    if (tokenRecibido != null) {
      _token = tokenRecibido; // Asignar el token directamente
      _isLoading = false;

      // Si recibimos un token, lo guardamos
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userData', _token!);

      notifyListeners();
      return true; // Login exitoso
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    notifyListeners();
    // BORRAR DEL DISCO
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }
  
}
