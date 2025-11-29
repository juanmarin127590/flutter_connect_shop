/// Excepciones personalizadas para un manejo de errores más robusto
/// Estas excepciones permiten identificar y manejar errores específicos en toda la aplicación

/// Excepción base para todas las excepciones personalizadas de la app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Excepciones de red y conexión
class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.originalError});

  factory NetworkException.noInternet() {
    return NetworkException(
      'No hay conexión a internet. Verifica tu red e intenta nuevamente.',
      code: 'NO_INTERNET',
    );
  }

  factory NetworkException.timeout() {
    return NetworkException(
      'La solicitud tardó demasiado. Verifica tu conexión.',
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.serverUnreachable() {
    return NetworkException(
      'No se puede conectar al servidor. Intenta más tarde.',
      code: 'SERVER_UNREACHABLE',
    );
  }
}

/// Excepciones de autenticación
class AuthException extends AppException {
  AuthException(super.message, {super.code, super.originalError});

  factory AuthException.invalidCredentials() {
    return AuthException(
      'Correo o contraseña incorrectos. Verifica tus datos.',
      code: 'INVALID_CREDENTIALS',
    );
  }

  factory AuthException.userNotFound() {
    return AuthException(
      'No existe una cuenta con ese correo electrónico.',
      code: 'USER_NOT_FOUND',
    );
  }

  factory AuthException.tokenExpired() {
    return AuthException(
      'Tu sesión ha expirado. Por favor inicia sesión nuevamente.',
      code: 'TOKEN_EXPIRED',
    );
  }

  factory AuthException.unauthorized() {
    return AuthException(
      'No tienes autorización para realizar esta acción.',
      code: 'UNAUTHORIZED',
    );
  }
}

/// Excepciones de validación de datos
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  ValidationException(
    super.message, {
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  factory ValidationException.emailInvalid() {
    return ValidationException(
      'El formato del correo electrónico no es válido.',
      code: 'EMAIL_INVALID',
    );
  }

  factory ValidationException.passwordTooShort() {
    return ValidationException(
      'La contraseña debe tener al menos 6 caracteres.',
      code: 'PASSWORD_TOO_SHORT',
    );
  }

  factory ValidationException.requiredField(String fieldName) {
    return ValidationException(
      'El campo $fieldName es obligatorio.',
      code: 'REQUIRED_FIELD',
    );
  }

  factory ValidationException.emailAlreadyExists() {
    return ValidationException(
      'Este correo electrónico ya está registrado. Intenta iniciar sesión.',
      code: 'EMAIL_EXISTS',
    );
  }
}

/// Excepciones del servidor (errores HTTP)
class ServerException extends AppException {
  final int? statusCode;

  ServerException(
    super.message, {
    this.statusCode,
    super.code,
    super.originalError,
  });

  factory ServerException.badRequest([String? message]) {
    return ServerException(
      message ?? 'La solicitud no es válida. Verifica los datos enviados.',
      statusCode: 400,
      code: 'BAD_REQUEST',
    );
  }

  factory ServerException.notFound([String? message]) {
    return ServerException(
      message ?? 'El recurso solicitado no fue encontrado.',
      statusCode: 404,
      code: 'NOT_FOUND',
    );
  }

  factory ServerException.internalError() {
    return ServerException(
      'Error interno del servidor. Intenta más tarde.',
      statusCode: 500,
      code: 'INTERNAL_ERROR',
    );
  }

  factory ServerException.conflict([String? message]) {
    return ServerException(
      message ?? 'Conflicto con los datos existentes.',
      statusCode: 409,
      code: 'CONFLICT',
    );
  }

  factory ServerException.fromStatusCode(int statusCode, [String? message]) {
    switch (statusCode) {
      case 400:
        return ServerException.badRequest(message);
      case 404:
        return ServerException.notFound(message);
      case 409:
        return ServerException.conflict(message);
      case 500:
      case 502:
      case 503:
        return ServerException.internalError();
      default:
        return ServerException(
          message ?? 'Error del servidor (código: $statusCode)',
          statusCode: statusCode,
          code: 'SERVER_ERROR',
        );
    }
  }
}

/// Excepciones de datos (parsing, formato incorrecto, etc.)
class DataException extends AppException {
  DataException(super.message, {super.code, super.originalError});

  factory DataException.invalidFormat() {
    return DataException(
      'Los datos recibidos tienen un formato incorrecto.',
      code: 'INVALID_FORMAT',
    );
  }

  factory DataException.parsingError() {
    return DataException(
      'Error al procesar los datos recibidos.',
      code: 'PARSING_ERROR',
    );
  }

  factory DataException.emptyResponse() {
    return DataException(
      'No se recibieron datos del servidor.',
      code: 'EMPTY_RESPONSE',
    );
  }
}

/// Excepciones de negocio (reglas de la aplicación)
class BusinessException extends AppException {
  BusinessException(super.message, {super.code, super.originalError});

  factory BusinessException.insufficientStock() {
    return BusinessException(
      'No hay suficiente stock disponible para este producto.',
      code: 'INSUFFICIENT_STOCK',
    );
  }

  factory BusinessException.emptyCart() {
    return BusinessException(
      'El carrito está vacío. Agrega productos antes de continuar.',
      code: 'EMPTY_CART',
    );
  }

  factory BusinessException.orderNotFound() {
    return BusinessException(
      'No se encontró el pedido solicitado.',
      code: 'ORDER_NOT_FOUND',
    );
  }
}

/// Excepción genérica para casos no específicos
class UnknownException extends AppException {
  UnknownException([String? message])
      : super(
          message ?? 'Ocurrió un error inesperado. Intenta nuevamente.',
          code: 'UNKNOWN_ERROR',
        );
}
