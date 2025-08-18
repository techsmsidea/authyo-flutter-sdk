part of '../authyo_plugin.dart';

/// Base class for all API errors.
///
/// All specific HTTP errors (such as [BadRequestError], [UnauthorizedError], etc.)
/// extend this class.

abstract class AuthyoError {
  /// A human-readable error message.
  final String message;

  /// The HTTP status code, if available.
  final int? code;

  AuthyoError(this.message, {this.code});

  Map<String, dynamic> toJson();
}
