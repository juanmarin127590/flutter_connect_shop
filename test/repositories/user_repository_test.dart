import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_connect_shop/repositories/implementations/user_repository_impl.dart';
import 'package:flutter_connect_shop/core/exceptions.dart';
import 'package:flutter_connect_shop/models/user.dart';
import 'package:flutter_connect_shop/services/api_service.dart';

/// Mock del ApiService para testing del UserRepository
class MockApiServiceForUser extends ApiService {
  bool shouldFailRegistration = false;
  bool shouldThrowException = false;
  List<String> registeredEmails = [];
  Map<String, dynamic>? lastRegistrationData;

  @override
  Future<bool> registerUser(
    String nombre,
    String apellidos,
    String email,
    String password,
    String telefono,
  ) async {
    lastRegistrationData = {
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'password': password,
      'telefono': telefono,
    };

    await Future.delayed(const Duration(milliseconds: 50));

    if (shouldThrowException) {
      throw Exception('Network error');
    }

    if (registeredEmails.contains(email)) {
      return false; // Email duplicado
    }

    if (shouldFailRegistration) {
      return false;
    }

    registeredEmails.add(email);
    return true;
  }
}

void main() {
  group('UserRepositoryImpl Tests', () {
    late UserRepositoryImpl userRepository;
    late MockApiServiceForUser mockApiService;

    setUp(() {
      mockApiService = MockApiServiceForUser();
      userRepository = UserRepositoryImpl(mockApiService);
    });

    test('Registro exitoso debe retornar User', () async {
      // Arrange
      const nombre = 'Juan';
      const apellidos = 'Pérez';
      const email = 'juan@example.com';
      const password = 'password123';
      const telefono = '1234567890';

      // Act
      final user = await userRepository.register(
        nombre: nombre,
        apellidos: apellidos,
        email: email,
        password: password,
        telefono: telefono,
      );

      // Assert
      expect(user, isA<User>());
      expect(user.nombre, nombre);
      expect(user.apellidos, apellidos);
      expect(user.email, email);
      expect(user.telefono, telefono);
      expect(user.roles, ['CLIENTE']);
      expect(user.activo, true);

      // Verificar que se llamó al API con los datos correctos
      expect(mockApiService.lastRegistrationData!['nombre'], nombre);
      expect(mockApiService.lastRegistrationData!['email'], email);
    });

    test('Registro con email duplicado debe lanzar ValidationException', () async {
      // Arrange
      mockApiService.registeredEmails.add('existing@example.com');

      // Act & Assert
      expect(
        () => userRepository.register(
          nombre: 'Test',
          apellidos: 'User',
          email: 'existing@example.com',
          password: 'password123',
          telefono: '1234567890',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Registro con email inválido debe lanzar ValidationException', () async {
      // Act & Assert
      expect(
        () => userRepository.register(
          nombre: 'Test',
          apellidos: 'User',
          email: 'invalid-email', // Sin @ ni dominio
          password: 'password123',
          telefono: '1234567890',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Registro con contraseña corta debe lanzar ValidationException', () async {
      // Act & Assert
      expect(
        () => userRepository.register(
          nombre: 'Test',
          apellidos: 'User',
          email: 'test@example.com',
          password: '12345', // Menos de 6 caracteres
          telefono: '1234567890',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Registro con nombre vacío debe lanzar ValidationException', () async {
      // Act & Assert
      expect(
        () => userRepository.register(
          nombre: '', // Vacío
          apellidos: 'User',
          email: 'test@example.com',
          password: 'password123',
          telefono: '1234567890',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Registro con apellidos vacíos debe lanzar ValidationException', () async {
      // Act & Assert
      expect(
        () => userRepository.register(
          nombre: 'Test',
          apellidos: '', // Vacío
          email: 'test@example.com',
          password: 'password123',
          telefono: '1234567890',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Registro con teléfono vacío debe lanzar ValidationException', () async {
      // Act & Assert
      expect(
        () => userRepository.register(
          nombre: 'Test',
          apellidos: 'User',
          email: 'test@example.com',
          password: 'password123',
          telefono: '', // Vacío
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('Múltiples registros exitosos deben funcionar', () async {
      // Act
      final user1 = await userRepository.register(
        nombre: 'User1',
        apellidos: 'Test1',
        email: 'user1@example.com',
        password: 'password123',
        telefono: '1111111111',
      );

      final user2 = await userRepository.register(
        nombre: 'User2',
        apellidos: 'Test2',
        email: 'user2@example.com',
        password: 'password456',
        telefono: '2222222222',
      );

      // Assert
      expect(user1.email, 'user1@example.com');
      expect(user2.email, 'user2@example.com');
      expect(mockApiService.registeredEmails.length, 2);
    });

    test('Validación de email debe aceptar formatos correctos', () async {
      // Estos emails deben ser válidos
      final validEmails = [
        'test@example.com',
        'user.name@domain.co',
        'first.last@company.org',
      ];

      for (final email in validEmails) {
        final user = await userRepository.register(
          nombre: 'Test',
          apellidos: 'User',
          email: email,
          password: 'password123',
          telefono: '1234567890',
        );
        expect(user.email, email);
      }
    });

    test('Validación de email debe rechazar formatos incorrectos', () async {
      // Estos emails deben ser inválidos
      final invalidEmails = [
        'invalidemail',
        '@example.com',
        'user@',
        'user@domain',
      ];

      for (final email in invalidEmails) {
        expect(
          () => userRepository.register(
            nombre: 'Test',
            apellidos: 'User',
            email: email,
            password: 'password123',
            telefono: '1234567890',
          ),
          throwsA(isA<ValidationException>()),
          reason: 'Email "$email" debería ser inválido',
        );
      }
    });
  });
}
