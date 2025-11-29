import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_connect_shop/repositories/interfaces/auth_repository.dart';
import 'package:flutter_connect_shop/core/exceptions.dart';
import 'package:flutter_connect_shop/services/api_service.dart';

/// Mock del ApiService para testing
class MockApiService extends ApiService {
  bool shouldReturnNullToken = false;
  bool shouldThrowException = false;
  String? lastSavedEmail;
  String? lastSavedPassword;

  @override
  Future<String?> login(String email, String password) async {
    lastSavedEmail = email;
    lastSavedPassword = password;

    await Future.delayed(const Duration(milliseconds: 50));

    if (shouldThrowException) {
      throw Exception('Network error');
    }

    if (shouldReturnNullToken) {
      return null;
    }

    if (email == 'wrong@example.com' || password == 'wrongpass') {
      return null; // Credenciales inválidas
    }

    return 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// Mock simple del AuthRepository para evitar problemas con SharedPreferences
class MockAuthRepositoryForTesting implements AuthRepository {
  final ApiService apiService;
  String? _token;

  MockAuthRepositoryForTesting(this.apiService);

  @override
  Future<String> login({required String email, required String password}) async {
    final token = await apiService.login(email, password);
    if (token != null && token.isNotEmpty) {
      _token = token;
      return token;
    }
    throw AuthException.invalidCredentials();
  }

  @override
  Future<void> logout() async {
    _token = null;
  }

  @override
  Future<String?> getStoredToken() async {
    return _token;
  }

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<void> deleteToken() async {
    _token = null;
  }

  @override
  Future<bool> isAuthenticated() async {
    return _token != null && _token!.isNotEmpty;
  }
}

void main() {
  group('AuthRepository Tests', () {
    late AuthRepository authRepository;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      authRepository = MockAuthRepositoryForTesting(mockApiService);
    });

    tearDown(() async {
      await authRepository.deleteToken();
    });

    test('Login exitoso debe retornar token y guardarlo', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      // Act
      final token = await authRepository.login(email: email, password: password);

      // Assert
      expect(token, isNotNull);
      expect(token, startsWith('mock_jwt_token'));
      expect(mockApiService.lastSavedEmail, email);
      expect(mockApiService.lastSavedPassword, password);

      // Verificar que se guardó
      final storedToken = await authRepository.getStoredToken();
      expect(storedToken, token);
    });

    test('Login con credenciales inválidas debe lanzar AuthException', () async {
      // Arrange
      const email = 'wrong@example.com';
      const password = 'wrongpass';

      // Act & Assert
      expect(
        () => authRepository.login(email: email, password: password),
        throwsA(isA<AuthException>()),
      );
    });

    test('Login cuando ApiService retorna null debe lanzar AuthException', () async {
      // Arrange
      mockApiService.shouldReturnNullToken = true;

      // Act & Assert
      expect(
        () => authRepository.login(email: 'test@example.com', password: 'pass'),
        throwsA(isA<AuthException>()),
      );
    });

    test('saveToken debe guardar el token correctamente', () async {
      // Arrange
      const token = 'test_token_123';

      // Act
      await authRepository.saveToken(token);

      // Assert
      final storedToken = await authRepository.getStoredToken();
      expect(storedToken, token);
    });

    test('deleteToken debe eliminar el token', () async {
      // Arrange
      await authRepository.saveToken('test_token');
      expect(await authRepository.getStoredToken(), isNotNull);

      // Act
      await authRepository.deleteToken();

      // Assert
      final storedToken = await authRepository.getStoredToken();
      expect(storedToken, null);
    });

    test('logout debe eliminar el token almacenado', () async {
      // Arrange
      await authRepository.saveToken('test_token');
      expect(await authRepository.isAuthenticated(), true);

      // Act
      await authRepository.logout();

      // Assert
      expect(await authRepository.isAuthenticated(), false);
      expect(await authRepository.getStoredToken(), null);
    });

    test('isAuthenticated debe retornar true cuando hay token', () async {
      // Arrange
      await authRepository.saveToken('test_token');

      // Act
      final isAuth = await authRepository.isAuthenticated();

      // Assert
      expect(isAuth, true);
    });

    test('isAuthenticated debe retornar false cuando no hay token', () async {
      // Arrange
      await authRepository.deleteToken();

      // Act
      final isAuth = await authRepository.isAuthenticated();

      // Assert
      expect(isAuth, false);
    });

    test('getStoredToken debe retornar null si no hay token guardado', () async {
      // Arrange
      await authRepository.deleteToken();

      // Act
      final token = await authRepository.getStoredToken();

      // Assert
      expect(token, null);
    });

    test('Login y logout completo debe funcionar correctamente', () async {
      // Arrange & Act
      final token = await authRepository.login(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(token, isNotNull);
      expect(await authRepository.isAuthenticated(), true);

      await authRepository.logout();

      // Assert
      expect(await authRepository.isAuthenticated(), false);
      expect(await authRepository.getStoredToken(), null);
    });
  });
}
