# 🏗️ Refactorización Avanzada - Flutter Connect Shop

## 📋 Resumen de Implementaciones

Este documento explica las tres mejoras principales implementadas en el proyecto:

1. ✅ **Repository Pattern**
2. ✅ **Manejo de Errores Robusto**
3. ✅ **Tests Unitarios Completos**

---

## 🎯 1. Repository Pattern

### ¿Qué es el Repository Pattern?

Es un patrón de diseño que **abstrae** la capa de acceso a datos. En lugar de que los Providers llamen directamente a `ApiService`, ahora usan **repositorios** que actúan como intermediarios.

### Estructura Implementada

```
lib/
├── repositories/
│   ├── interfaces/          # Contratos abstractos (QUÉ hacer)
│   │   ├── auth_repository.dart
│   │   └── user_repository.dart
│   └── implementations/     # Implementaciones concretas (CÓMO hacerlo)
│       ├── auth_repository_impl.dart
│       └── user_repository_impl.dart
```

### Ventajas del Repository Pattern

#### ✅ **Separación de Responsabilidades**
- Los **Providers** manejan la lógica de negocio y el estado
- Los **Repositories** manejan el acceso a datos (API, base de datos, cache)
- Los **Services** hacen las llamadas HTTP

#### ✅ **Testabilidad**
- Puedes crear **mocks** de los repositorios fácilmente
- No necesitas un backend real para probar los Providers
- Los tests son más rápidos y confiables

#### ✅ **Flexibilidad**
- Cambiar de API a Firebase: solo modificas la implementación del repositorio
- Agregar caché local: solo extiendes el repositorio existente
- Los Providers NO se enteran del cambio

#### ✅ **Inversión de Dependencias (SOLID)**
- Los Providers dependen de **interfaces** (abstracciones)
- NO dependen de implementaciones concretas
- Facilita cambios futuros sin romper el código

### Ejemplo de Uso

**ANTES (sin Repository):**
```dart
class AuthProvider extends ChangeNotifier {
  Future<bool> login(String email, String password) async {
    final api = ApiService(); // ❌ Dependencia directa
    final token = await api.login(email, password);
    // ...
  }
}
```

**AHORA (con Repository):**
```dart
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository; // ✅ Inyección de dependencias
  
  AuthProvider(this._authRepository);
  
  Future<bool> login(String email, String password) async {
    final token = await _authRepository.login(
      email: email, 
      password: password,
    );
    // ...
  }
}
```

### Interfaces Creadas

#### **AuthRepository** (Autenticación)
```dart
abstract class AuthRepository {
  Future<String> login({required String email, required String password});
  Future<void> logout();
  Future<String?> getStoredToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<bool> isAuthenticated();
}
```

#### **UserRepository** (Usuarios)
```dart
abstract class UserRepository {
  Future<User> register({
    required String nombre,
    required String apellidos,
    required String email,
    required String password,
    required String telefono,
  });
  Future<User> getCurrentUser(String token);
  Future<User> updateUser({...});
  Future<User> getUserById(int id);
  Future<bool> emailExists(String email);
}
```

---

## 🛡️ 2. Manejo de Errores Robusto

### Excepciones Personalizadas

Creamos un sistema de excepciones tipadas en `lib/core/exceptions.dart`:

#### **Jerarquía de Excepciones**

```
AppException (base)
├── NetworkException      → Problemas de red/conexión
├── AuthException         → Errores de autenticación
├── ValidationException   → Datos inválidos
├── ServerException       → Errores HTTP del servidor
├── DataException         → Problemas de formato/parsing
├── BusinessException     → Reglas de negocio
└── UnknownException      → Errores inesperados
```

### Ejemplos de Excepciones

#### **NetworkException** (Errores de Red)
```dart
NetworkException.noInternet()        // Sin conexión
NetworkException.timeout()           // Timeout
NetworkException.serverUnreachable() // Servidor no disponible
```

#### **AuthException** (Autenticación)
```dart
AuthException.invalidCredentials()  // Email/contraseña incorrectos
AuthException.userNotFound()        // Usuario no existe
AuthException.tokenExpired()        // Sesión expirada
AuthException.unauthorized()        // Sin permisos
```

#### **ValidationException** (Validación)
```dart
ValidationException.emailInvalid()      // Email mal formateado
ValidationException.passwordTooShort()  // Contraseña corta
ValidationException.requiredField()     // Campo obligatorio vacío
ValidationException.emailAlreadyExists() // Email duplicado
```

#### **ServerException** (Errores HTTP)
```dart
ServerException.badRequest()       // 400
ServerException.notFound()         // 404
ServerException.conflict()         // 409
ServerException.internalError()    // 500
ServerException.fromStatusCode(statusCode) // Genérico
```

### Flujo de Manejo de Errores

```
ApiService → lanza Exception
    ↓
Repository → captura y transforma a AppException específica
    ↓
Provider → captura AppException y expone mensaje user-friendly
    ↓
Screen → muestra el mensaje al usuario
```

### Ejemplo Completo

**En el Repository:**
```dart
Future<User> register({...}) async {
  try {
    // Validaciones
    _validateEmail(email);
    _validatePassword(password);
    
    // Llamar API
    final success = await _apiService.registerUser(...);
    
    if (success) {
      return User(...);
    } else {
      throw ValidationException.emailAlreadyExists(); // ✅ Excepción específica
    }
  } on SocketException {
    throw NetworkException.noInternet(); // ✅ Transforma error genérico
  } on TimeoutException {
    throw NetworkException.timeout();
  }
}
```

**En el Provider:**
```dart
Future<bool> register({...}) async {
  try {
    final user = await _userRepository.register(...);
    return true;
  } on ValidationException catch (e) {
    _errorMessage = e.message; // ✅ Mensaje específico
    return false;
  } on NetworkException catch (e) {
    _errorMessage = e.message; // ✅ Mensaje de red
    return false;
  } catch (e) {
    _errorMessage = 'Error inesperado'; // ✅ Fallback genérico
    return false;
  }
}
```

**En la Screen:**
```dart
if (!success) {
  // Muestra el error específico del provider
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Error'),
      content: Text(
        registerProvider.errorMessage ?? 'Error desconocido'
      ),
    ),
  );
}
```

---

## 🧪 3. Tests Unitarios Completos

### Archivos de Test Creados

```
test/
├── providers/
│   ├── auth_provider_test.dart      (8 tests)
│   └── register_provider_test.dart  (9 tests)
└── repositories/
    ├── auth_repository_test.dart    (10 tests)
    └── user_repository_test.dart    (10 tests)

Total: 37 tests ✅
```

### Cobertura de Tests

#### **AuthProvider Tests** (8 tests)
- ✅ Estado inicial no autenticado
- ✅ Login exitoso actualiza estado
- ✅ Login fallido establece error
- ✅ Error de red muestra mensaje apropiado
- ✅ Logout limpia el estado
- ✅ Auto-login carga token almacenado
- ✅ clearError limpia mensaje de error
- ✅ isLoading es true durante login

#### **RegisterProvider Tests** (9 tests)
- ✅ Estado inicial limpio
- ✅ Registro exitoso crea usuario
- ✅ Email duplicado falla apropiadamente
- ✅ Error de validación muestra mensaje
- ✅ Error de red muestra mensaje
- ✅ clearError funciona
- ✅ clear limpia todo el estado
- ✅ isLoading es true durante registro
- ✅ Múltiples registros funcionan

#### **AuthRepository Tests** (10 tests)
- ✅ Login exitoso retorna y guarda token
- ✅ Credenciales inválidas lanzan excepción
- ✅ Token null lanza excepción
- ✅ saveToken guarda correctamente
- ✅ deleteToken elimina token
- ✅ logout elimina token
- ✅ isAuthenticated con token retorna true
- ✅ isAuthenticated sin token retorna false
- ✅ getStoredToken sin token retorna null
- ✅ Login-logout completo funciona

#### **UserRepository Tests** (10 tests)
- ✅ Registro exitoso retorna User
- ✅ Email duplicado lanza excepción
- ✅ Email inválido lanza excepción
- ✅ Contraseña corta lanza excepción
- ✅ Campos vacíos lanzan excepción
- ✅ Múltiples registros funcionan
- ✅ Validación acepta emails correctos
- ✅ Validación rechaza emails incorrectos

### Uso de Mocks

Los tests usan **mocks** en lugar de dependencias reales:

```dart
class MockAuthRepository implements AuthRepository {
  bool shouldFailLogin = false;
  String? storedToken;
  
  @override
  Future<String> login({required String email, required String password}) async {
    if (shouldFailLogin) {
      throw AuthException.invalidCredentials();
    }
    return 'mock_token';
  }
  // ...
}
```

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Solo providers
flutter test test/providers/

# Solo repositorios
flutter test test/repositories/

# Un archivo específico
flutter test test/providers/auth_provider_test.dart

# Con cobertura
flutter test --coverage
```

---

## 🔄 Flujo de Datos Completo

```
┌─────────────────────────────────────────────────────────────────┐
│                         PANTALLA (UI)                           │
│  RegisterScreen / LoginScreen                                   │
│  - Muestra formularios                                          │
│  - Muestra errores al usuario                                   │
└────────────────────┬────────────────────────────────────────────┘
                     │ llama método
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                      PROVIDER (Estado)                          │
│  RegisterProvider / AuthProvider                                │
│  - Gestiona estado (isLoading, errorMessage)                    │
│  - Captura excepciones específicas                              │
│  - Notifica cambios a la UI                                     │
└────────────────────┬────────────────────────────────────────────┘
                     │ usa
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                   REPOSITORY (Lógica)                           │
│  UserRepositoryImpl / AuthRepositoryImpl                        │
│  - Valida datos                                                 │
│  - Transforma errores a excepciones específicas                 │
│  - Maneja lógica de negocio                                     │
└────────────────────┬────────────────────────────────────────────┘
                     │ llama
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                     SERVICE (Datos)                             │
│  ApiService                                                     │
│  - Hace llamadas HTTP                                           │
│  - Serializa/deserializa JSON                                   │
│  - Retorna datos crudos                                         │
└────────────────────┬────────────────────────────────────────────┘
                     │ HTTP Request
                     ▼
┌─────────────────────────────────────────────────────────────────┐
│                      BACKEND (API)                              │
│  Spring Boot Server                                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📊 Comparación Antes vs Ahora

| Aspecto | ANTES | AHORA |
|---------|-------|-------|
| **Dependencias** | Provider → ApiService directo | Provider → Repository → ApiService |
| **Errores** | Strings genéricos | Excepciones tipadas específicas |
| **Testabilidad** | Difícil (necesita backend) | Fácil (usa mocks) |
| **Mantenibilidad** | Código acoplado | Código desacoplado |
| **Mensajes de error** | "Error de conexión" genérico | Mensajes específicos por tipo |
| **Tests** | 0 tests | 37 tests unitarios |
| **Validaciones** | Solo en UI | En Repository + UI |
| **Cambiar backend** | Modificar todos los Providers | Solo modificar Repository |

---

## 🎓 Principios SOLID Aplicados

### ✅ **S - Single Responsibility**
- AuthProvider: solo gestiona estado de autenticación
- RegisterProvider: solo gestiona estado de registro
- AuthRepository: solo maneja operaciones de auth
- UserRepository: solo maneja operaciones de usuarios

### ✅ **O - Open/Closed**
- Puedes extender repositorios sin modificarlos
- Nuevas excepciones sin cambiar las existentes

### ✅ **L - Liskov Substitution**
- Cualquier implementación de AuthRepository funciona
- Los mocks sustituyen perfectamente a las implementaciones reales

### ✅ **I - Interface Segregation**
- AuthRepository: solo métodos de autenticación
- UserRepository: solo métodos de usuarios
- No hay métodos innecesarios

### ✅ **D - Dependency Inversion**
- Providers dependen de interfaces (AuthRepository)
- NO dependen de implementaciones (AuthRepositoryImpl)
- Inyección de dependencias en constructores

---

## 🚀 Beneficios para el Futuro

### 1. **Agregar Caché Local**
```dart
class AuthRepositoryWithCache implements AuthRepository {
  final AuthRepository _remoteRepo;
  final CacheService _cache;
  
  Future<String> login(...) async {
    // Intenta caché primero
    final cachedToken = await _cache.getToken();
    if (cachedToken != null) return cachedToken;
    
    // Si no, usa el repo remoto
    return await _remoteRepo.login(...);
  }
}
```

### 2. **Cambiar a Firebase**
```dart
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  
  Future<String> login(...) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return await credential.user!.getIdToken();
  }
}
```

### 3. **Modo Offline**
```dart
class OfflineUserRepository implements UserRepository {
  Future<User> register(...) async {
    // Guardar en base de datos local
    await _localDb.insert(user);
    // Marcar para sincronizar cuando haya internet
    await _syncQueue.add(user);
    return user;
  }
}
```

---

## 📝 Mejores Prácticas Aplicadas

✅ **Inyección de Dependencias** - Los repositorios se pasan a los providers  
✅ **Fail Fast** - Validaciones tempranas en repositories  
✅ **Excepciones Específicas** - Cada tipo de error tiene su excepción  
✅ **Mensajes User-Friendly** - Errores claros para el usuario  
✅ **Tests Aislados** - Cada test es independiente  
✅ **Mocks** - No dependen de servicios externos  
✅ **Documentación** - Comentarios claros en el código  
✅ **Nombres Descriptivos** - Métodos y clases autoexplicativas  

---

## 🎯 Conclusión

La aplicación ahora tiene:

1. ✅ **Arquitectura robusta** con Repository Pattern
2. ✅ **Manejo de errores profesional** con excepciones tipadas
3. ✅ **37 tests unitarios** que validan el comportamiento
4. ✅ **Código mantenible** y fácil de extender
5. ✅ **Separación clara** de responsabilidades
6. ✅ **Preparada para escalar** a nuevas funcionalidades

**La lógica de negocio se mantiene intacta**, solo se reorganizó de forma más profesional siguiendo Clean Architecture y principios SOLID.
