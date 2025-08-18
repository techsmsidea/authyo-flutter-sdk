part of '../authyo_plugin.dart';

/// Represents an Plugin Initialization Error
/// Mostly faced when user has not initialized the [AuthyoService] before calling [sendOtp] or [verifyOtp]
class AuthyoInitializationError extends AuthyoError {
  AuthyoInitializationError(super.message, {super.code});

  @override
  String toString() {
    return 'AuthyoInitializationError: $message';
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'AuthyoInitializationError',
    'message': message,
    'code': code,
  };
}

/// Represents a 400 BadRequest error.
class BadRequestError extends AuthyoError {
  BadRequestError(super.message, {super.code});

  @override
  Map<String, dynamic> toJson() => {
    'type': 'BadRequestError',
    'message': message,
    'code': code,
  };
}

/// Represents a 401 Unauthorized error.
class UnauthorizedError extends AuthyoError {
  UnauthorizedError(super.message, {super.code});
  @override
  Map<String, dynamic> toJson() => {
    'type': 'UnauthorizedError',
    'message': message,
    'code': code,
  };
}

/// Represents a 403 Forbidden error.
class ForbiddenError extends AuthyoError {
  ForbiddenError(super.message, {super.code});
  @override
  Map<String, dynamic> toJson() => {
    'type': 'ForbiddenError',
    'message': message,
    'code': code,
  };
}

/// Represents a 404 NotFound error.
class NotFoundError extends AuthyoError {
  NotFoundError(super.message, {super.code});
  @override
  Map<String, dynamic> toJson() => {
    'type': 'NotFoundError',
    'message': message,
    'code': code,
  };
}

/// Represents a 429 TooManyRequest error.
class TooManyRequestsError extends AuthyoError {
  TooManyRequestsError(super.message, {super.code});
  @override
  Map<String, dynamic> toJson() => {
    'type': 'TooManyRequestsError',
    'message': message,
    'code': code,
  };
}

/// Represents a 500 InternalServerError.
class InternalServerError extends AuthyoError {
  InternalServerError(super.message, {super.code});
  @override
  Map<String, dynamic> toJson() => {
    'type': 'InternalServerError',
    'message': message,
    'code': code,
  };
}

/// Represents a 503 ServiceUnavailable error.
class ServiceUnavailableError extends AuthyoError {
  ServiceUnavailableError(super.message, {super.code});
  @override
  Map<String, dynamic> toJson() => {
    'type': 'ServiceUnavailableError',
    'message': message,
    'code': code,
  };
}

/// Represents an Unknown error.
class UnknownError extends AuthyoError {
  UnknownError(super.message, {super.code});
  @override
  Map<String, dynamic> toJson() => {
    'type': 'UnknownError',
    'message': message,
    'code': code,
  };
}

/// Represents a TimeoutError
class TimeoutError extends AuthyoError {
  TimeoutError(super.message, {super.code});
  @override
  Map<String, dynamic> toJson() => {
    'type': 'TimeoutError',
    'message': message,
    'code': code,
  };
}

AuthyoError handleHttpError(int? statusCode, String message) {
  switch (statusCode) {
    case 400:
      return BadRequestError(message, code: statusCode);
    case 401:
      return UnauthorizedError(message, code: statusCode);
    case 403:
      return ForbiddenError(message, code: statusCode);
    case 404:
      return NotFoundError(message, code: statusCode);
    case 429:
      return TooManyRequestsError(message, code: statusCode);
    case 500:
      return InternalServerError(message, code: statusCode);
    case 503:
      return ServiceUnavailableError(message, code: statusCode);
    default:
      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return BadRequestError(message, code: statusCode);
      } else if (statusCode != null && statusCode >= 500) {
        return InternalServerError(message, code: statusCode);
      }
      return UnknownError(message, code: statusCode);
  }
}
