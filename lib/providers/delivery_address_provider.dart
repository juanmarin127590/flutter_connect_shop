import 'package:flutter/material.dart';
import 'package:flutter_connect_shop/models/delivery_address.dart';
import '../services/api_service.dart';

class DireccionProvider extends ChangeNotifier {
  List<Direccion> _direcciones = [];
  bool _isLoading = false;

  List<Direccion> get direcciones => [..._direcciones];
  bool get isLoading => _isLoading;

  Direccion? get direccionPrincipal {
    try {
      return _direcciones.firstWhere((d) => d.principalEnvio);
    } catch (e) {
      return null;
    }
  }

  bool get tieneDirecciones => _direcciones.isNotEmpty;

  // Cargar direcciones del usuario
  Future<void> fetchDirecciones(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final apiService = ApiService();
      final data = await apiService.getDirecciones(token);
      
      _direcciones = (data)
          .map((item) => Direccion.fromJson(item))
          .toList();
    } catch (error) {
      _direcciones = [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear nueva dirección
  Future<bool> crearDireccion(String token, Direccion direccion) async {
    try {
      final apiService = ApiService();
      final nuevaDireccion = await apiService.crearDireccion(token, direccion);
      
      if (nuevaDireccion != null) {
        _direcciones.add(Direccion.fromJson(nuevaDireccion));
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  // Actualizar dirección existente
  Future<bool> actualizarDireccion(String token, int idDireccion, Direccion direccion) async {
    try {
      final apiService = ApiService();
      final direccionActualizada = await apiService.actualizarDireccion(token, idDireccion, direccion);
      
      if (direccionActualizada != null) {
        final index = _direcciones.indexWhere((d) => d.idDireccion == idDireccion);
        if (index >= 0) {
          _direcciones[index] = Direccion.fromJson(direccionActualizada);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (error) {
      return false;
    }
  }

  // Eliminar dirección
  Future<bool> eliminarDireccion(String token, int idDireccion) async {
    try {
      final apiService = ApiService();
      final exito = await apiService.eliminarDireccion(token, idDireccion);
      
      if (exito) {
        _direcciones.removeWhere((d) => d.idDireccion == idDireccion);
        notifyListeners();
      }
      return exito;
    } catch (error) {
      return false;
    }
  }

  void clear() {
    _direcciones = [];
    notifyListeners();
  }
}