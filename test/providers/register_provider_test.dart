import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_connect_shop/providers/register_provider.dart';
import 'package:flutter_connect_shop/core/exceptions.dart';
import 'package:flutter_connect_shop/models/user.dart';
import 'package:flutter_connect_shop/repositories/interfaces/user_repository.dart';

/// Mock del UserRepository para testing
class MockUserRepository implements UserRepository {
  bool shouldFailRegistration = false;
  bool shouldThrowValidationError = false;
  bool shouldThrowNetworkError = false;
  List<String> registeredEmails = [];

  @override
  Future<User> register({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    required String telefono,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simular latencia

    if (shouldThrowNetworkError) {
      throw NetworkException.noInternet();
    }

    if (shouldThrowValidationError) {
      throw ValidationException.emailInvalid();
    }

    if (registeredEmails.contains(email)) {
      throw ValidationException.emailAlreadyExists();
    }

    if (shouldFailRegistration) {
      throw Exception('Error desconocido');
    }

    // Registro exitoso
    registeredEmails.add(email);
    return User(
      id: 1,
      nombre: nombre,
      apellidos: apellidos,
      email: email,
      telefono: telefono,
      rol: 'CLIENTE',
      activo: true,
    );
  }

  @override
  Future<User> getCurrentUser(String token) async {
    throw UnimplementedError();
  }

  @override
  Future<User> updateUser({
    required String token,
    required int userId,
    required Map<String, dynamic> updates,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<User> getUserById(int id) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> emailExists(String email) async {
    return registeredEmails.contains(email);
  }
}

void main() {
  group('RegisterProvider Tests', () {
    late RegisterProvider registerProvider;
    late MockUserRepository mockRepository;

    setUp(() {
      mockRepository = MockUserRepository();
      registerProvider = RegisterProvider(mockRepository);
    });

    test('Estado inicial debe estar limpio', () {
      expect(registerProvider.isLoading, false);
      expect(registerProvider.errorMessage, null);
      expect(registerProvider.registeredUser, null);
    });

    test('Registro exitoso debe crear usuario y actualizar estado', () async {
      // Arrange
      const nombre = 'Juan';
      const apellidos = 'Pérez';
      const email = 'juan@example.com';
      const password = 'password123';
      const telefono = '1234567890';

      // Act
      final result = await registerProvider.register(
        nombre: nombre,
        apellidos: apellidos,
        email: email,
        password: password,
        telefono: telefono,
      );

      // Assert
      expect(result, true);
      expect(registerProvider.registeredUser, isNotNull);
      expect(registerProvider.registeredUser!.nombre, nombre);
      expect(registerProvider.registeredUser!.email, email);
      expect(registerProvider.errorMessage, null);
      expect(registerProvider.isLoading, false);
    });

    test('Registro con email duplicado debe fallar con mensaje apropiado', () async {
      // Arrange
      mockRepository.registeredEmails.add('existing@example.com');

      // Act
      final result = await registerProvider.register(
        nombre: 'Test',
        apellidos: 'User',
        email: 'existing@example.com',
        password: 'password123',
        telefono: '1234567890',
      );

      // Assert
      expect(result, false);
      expect(registerProvider.registeredUser, null);
      expect(registerProvider.errorMessage, isNotNull);
      expect(registerProvider.errorMessage, contains('ya está registrado'));
      expect(registerProvider.isLoading, false);
    });

    test('Error de validación debe establecer mensaje apropiado', () async {
      // Arrange
      mockRepository.shouldThrowValidationError = true;

      // Act
      final result = await registerProvider.register(
        nombre: 'Test',
        apellidos: 'User',
        email: 'invalid-email',
        password: 'password123',
        telefono: '1234567890',
      );

      // Assert
      expect(result, false);
      expect(registerProvider.registeredUser, null);
      expect(registerProvider.errorMessage, isNotNull);
      expect(registerProvider.errorMessage, contains('correo'));
      expect(registerProvider.isLoading, false);
    });

    test('Error de red debe establecer mensaje apropiado', () async {
      // Arrange
      mockRepository.shouldThrowNetworkError = true;

      // Act
      final result = await registerProvider.register(
        nombre: 'Test',
        apellidos: 'User',
        email: 'test@example.com',
        password: 'password123',
        telefono: '1234567890',
      );

      // Assert
      expect(result, false);
      expect(registerProvider.registeredUser, null);
      expect(registerProvider.errorMessage, isNotNull);
      expect(registerProvider.errorMessage, contains('conexión'));
      expect(registerProvider.isLoading, false);
    });

    test('clearError debe limpiar el mensaje de error', () async {
      // Arrange
      mockRepository.shouldFailRegistration = true;
      await registerProvider.register(
        nombre: 'Test',
        apellidos: 'User',
        email: 'test@example.com',
        password: 'password123',
        telefono: '1234567890',
      );
      expect(registerProvider.errorMessage, isNotNull);

      // Act
      registerProvider.clearError();

      // Assert
      expect(registerProvider.errorMessage, null);
    });

    test('clear debe limpiar todo el estado', () async {
      // Arrange
      await registerProvider.register(
        nombre: 'Test',
        apellidos: 'User',
        email: 'test@example.com',
        password: 'password123',
        telefono: '1234567890',
      );
      expect(registerProvider.registeredUser, isNotNull);

      // Act
      registerProvider.clear();

      // Assert
      expect(registerProvider.registeredUser, null);
      expect(registerProvider.errorMessage, null);
      expect(registerProvider.isLoading, false);
    });

    test('isLoading debe ser true durante el registro', () async {
      // Arrange
      bool wasLoadingDuringRegistration = false;

      registerProvider.addListener(() {
        if (registerProvider.isLoading) {
          wasLoadingDuringRegistration = true;
        }
      });

      // Act
      await registerProvider.register(
        nombre: 'Test',
        apellidos: 'User',
        email: 'test@example.com',
        password: 'password123',
        telefono: '1234567890',
      );

      // Assert
      expect(wasLoadingDuringRegistration, true);
      expect(registerProvider.isLoading, false);
    });

    test('Múltiples registros exitosos deben funcionar correctamente', () async {
      // Act & Assert
      final result1 = await registerProvider.register(
        nombre: 'User1',
        apellidos: 'Test1',
        email: 'user1@example.com',
        password: 'password123',
        telefono: '1111111111',
      );
      expect(result1, true);

      final result2 = await registerProvider.register(
        nombre: 'User2',
        apellidos: 'Test2',
        email: 'user2@example.com',
        password: 'password123',
        telefono: '2222222222',
      );
      expect(result2, true);
      expect(registerProvider.registeredUser!.email, 'user2@example.com');
    });
  });
}
