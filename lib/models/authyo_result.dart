part of '../authyo_plugin.dart';

class AuthyoResult {
  final AuthyoResponseModel? result;
  final AuthyoError? error;
  AuthyoResult.success(this.result) : error = null;
  AuthyoResult.failure(this.error) : result = null;
}
