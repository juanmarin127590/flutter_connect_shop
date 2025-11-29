import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_connect_shop/providers/auth_provider.dart';
import 'package:flutter_connect_shop/core/exceptions.dart';
import 'package:flutter_connect_shop/repositories/interfaces/auth_repository.dart';

/// Mock del AuthRepository para testing
class MockAuthRepository implements AuthRepository {
  bool shouldFailLogin = false;
  bool shouldThrowNetworkError = false;
  String? storedToken;

  @override
  Future<String> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simular latencia

    if (shouldThrowNetworkError) {
      throw NetworkException.noInternet();
    }

    if (shouldFailLogin) {
      throw AuthException.invalidCredentials();
    }

    // Login exitoso
    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    storedToken = token;
    return token;
  }

  @override
  Future<void> logout() async {
    storedToken = null;
  }

  @override
  Future<String?> getStoredToken() async {
    return storedToken;
  }

  @override
  Future<void> saveToken(String token) async {
    storedToken = token;
  }

  @override
  Future<void> deleteToken() async {
    storedToken = null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return storedToken != null;
  }
}

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockAuthRepository mockRepository;

    setUp(() {
      // Se ejecuta antes de cada test
      mockRepository = MockAuthRepository();
      authProvider = AuthProvider(mockRepository);
    });

    test('Estado inicial debe ser no autenticado', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, null);
      expect(authProvider.isLoading, false);
    });

    test('Login exitoso debe actualizar el estado correctamente', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      // Act
      final result = await authProvider.login(email, password);

      // Assert
      expect(result, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.token, isNotNull);
      expect(authProvider.errorMessage, null);
      expect(authProvider.isLoading, false);
    });

    test('Login fallido debe establecer mensaje de error', () async {
      // Arrange
      mockRepository.shouldFailLogin = true;
      const email = 'wrong@example.com';
      const password = 'wrongpass';

      // Act
      final result = await authProvider.login(email, password);

      // Assert
      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, null);
      expect(authProvider.errorMessage, isNotNull);
      expect(authProvider.errorMessage, contains('incorrectos'));
      expect(authProvider.isLoading, false);
    });

    test('Error de red debe establecer mensaje de error apropiado', () async {
      // Arrange
      mockRepository.shouldThrowNetworkError = true;
      const email = 'test@example.com';
      const password = 'password123';

      // Act
      final result = await authProvider.login(email, password);

      // Assert
      expect(result, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, isNotNull);
      expect(authProvider.errorMessage, contains('conexión'));
      expect(authProvider.isLoading, false);
    });

    test('Logout debe limpiar el estado', () async {
      // Arrange - Primero hacer login
      await authProvider.login('test@example.com', 'password123');
      expect(authProvider.isAuthenticated, true);

      // Act
      await authProvider.logout();

      // Assert
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.token, null);
      expect(authProvider.errorMessage, null);
    });

    test('tryAutoLogin debe cargar token si existe', () async {
      // Arrange
      mockRepository.storedToken = 'existing_token';
      final newProvider = AuthProvider(mockRepository);
      
      // Esperar a que termine el constructor (tryAutoLogin)
      await Future.delayed(const Duration(milliseconds: 150));

      // Assert
      expect(newProvider.isAuthenticated, true);
      expect(newProvider.token, 'existing_token');
    });

    test('clearError debe limpiar el mensaje de error', () async {
      // Arrange
      mockRepository.shouldFailLogin = true;
      await authProvider.login('wrong@example.com', 'wrongpass');
      expect(authProvider.errorMessage, isNotNull);

      // Act
      authProvider.clearError();

      // Assert
      expect(authProvider.errorMessage, null);
    });

    test('isLoading debe ser true durante el login', () async {
      // Arrange
      bool wasLoadingDuringLogin = false;

      // Escuchar cambios
      authProvider.addListener(() {
        if (authProvider.isLoading) {
          wasLoadingDuringLogin = true;
        }
      });

      // Act
      await authProvider.login('test@example.com', 'password123');

      // Assert
      expect(wasLoadingDuringLogin, true);
      expect(authProvider.isLoading, false); // Debe terminar en false
    });
  });
}
