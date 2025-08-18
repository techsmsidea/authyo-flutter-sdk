part of '../authyo_plugin.dart';

// Abstract PluginError and its subclasses are assumed to be defined as shown earlier.

class _ApiService {
  final Dio _dio;

  _ApiService({
    required String clientId,
    required String clientSecret,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) : _dio = Dio(
         BaseOptions(
           sendTimeout: sendTimeout ?? const Duration(seconds: 30),
           connectTimeout: connectTimeout ?? const Duration(seconds: 30),
           receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
           headers: {},
           baseUrl: AuthyoEndpoints.baseUrlEndpoint,
         ),
       ) {
    setClientData(clientId: clientId, clientSecret: clientSecret);
  }

  // Update token and headers if needed
  void setClientData({required String clientId, required String clientSecret}) {
    _dio.options.headers['clientId'] = clientId;
    _dio.options.headers['clientSecret'] = clientSecret;
  }

  void clearToken() {
    _dio.options.headers.remove('clientId');
    _dio.options.headers.remove('clientSecret');
  }

  // GET request
  Future<AuthyoResponseModel> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      AuthyoResponseModel baseResponse = AuthyoResponseModel.fromJson(
        response.data,
      );
      if (baseResponse.success == true) {
        return baseResponse;
      } else {
        return AuthyoResponseModel.withError({
          "error":
              baseResponse.message ??
              "Something went wrong while processing your request",
          "errorCode": "500",
        });
      }
    } on DioException catch (e) {
      AuthyoError authyoError = _handleDioError(e);
      return AuthyoResponseModel.withError({
        "error": authyoError.message,
        "errorCode": "${authyoError.code}",
      });
    } catch (e) {
      return AuthyoResponseModel.withError({"error": "$e", "errorCode": "500"});
    }
  }

  // POST request
  Future<AuthyoResponseModel> post(
    String url, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await _dio.post(url, data: body);
      AuthyoResponseModel baseResponse = AuthyoResponseModel.fromJson(
        response.data,
      );
      if (baseResponse.success == true) {
        return baseResponse;
      } else {
        return AuthyoResponseModel.withError({
          "error":
              baseResponse.message ??
              "Something went wrong while processing your request",
          "errorCode": "500",
        });
      }
    } on DioException catch (e) {
      AuthyoError authyoError = _handleDioError(e);
      return AuthyoResponseModel.withError({
        "error": authyoError.message,
        "errorCode": "${authyoError.code}",
      });
    } catch (e) {
      return AuthyoResponseModel.withError({"error": "$e", "errorCode": "500"});
    }
  }

  // Centralized error handling
  AuthyoError _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return TimeoutError('Request timed out', code: e.response?.statusCode);
    } else if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response?.statusCode ?? 0;
      if (statusCode >= 500) {
        return InternalServerError(
          'Server error: ${e.message}',
          code: statusCode,
        );
      } else if (statusCode >= 400) {
        return handleHttpError(statusCode, "${e.message}");
      }
    } else if (e.type == DioExceptionType.connectionError) {
      return ServiceUnavailableError(
        'Network Unavailable: There is no internet connection, please check and try again',
      );
    }
    return UnknownError('Unidentified error: ${e.message}');
  }
}
