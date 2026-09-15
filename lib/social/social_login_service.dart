part of '../authyo_plugin.dart';

/// Lets the host app run the social login itself (e.g. with the native
/// Google / Microsoft SDKs) instead of the SDK opening the browser.
///
/// Receives the provider config and the authorization URL the Authyo backend
/// built for it, and must return the outcome as an [AuthyoResult].
typedef AuthyoSocialLoginHandler =
    Future<AuthyoResult> Function(AuthyoSocialLogin login, String authUrl);

/// Runs a social login end to end.
///
/// 1. `POST /authlogin { provider, id, returnType: "mobile" }` → `authUrl`
/// 2. Opens `authUrl` in the system browser (ASWebAuthenticationSession on
///    iOS, Custom Tabs on Android).
/// 3. The Authyo OAuth callback redirects to
///    `authyo://oauth/callback?success=..&token=..&email=..`, which is parsed
///    into an [AuthyoResult] carrying the JWT in `result.data.token`.
class _SocialLoginService {
  _SocialLoginService(this._api);

  final _ApiService _api;

  Future<AuthyoResult> login(
    AuthyoSocialLogin social, {
    AuthyoSocialLoginHandler? handler,
  }) async {
    final String authUrl;
    try {
      final json = await _api.postRaw(
        _api.clientUrl(AuthyoEndpoints.authLoginPath),
        body: {
          'provider': social.provider.apiName,
          'id': social.id,
          'returnType': 'mobile',
        },
      );
      authUrl = (json['authUrl'] ?? '').toString();
    } on AuthyoError catch (e) {
      return AuthyoResult.failure(e);
    }
    if (authUrl.isEmpty) {
      return AuthyoResult.failure(
        InternalServerError(
          'Could not start ${social.provider.label} sign-in. '
          'Please check the social login configuration on your Authyo dashboard.',
        ),
      );
    }

    if (handler != null) {
      try {
        return await handler(social, authUrl);
      } catch (e) {
        return AuthyoResult.failure(UnknownError('$e'));
      }
    }

    final String callback;
    try {
      callback = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: AuthyoEndpoints.oauthCallbackScheme,
        options: const FlutterWebAuth2Options(preferEphemeral: true),
      );
    } on PlatformException catch (e) {
      final cancelled = e.code == 'CANCELED' || e.code == 'CANCELLED';
      return AuthyoResult.failure(
        cancelled
            ? UnknownError('Sign-in cancelled', code: 0)
            : UnknownError(e.message ?? 'Sign-in failed'),
      );
    } catch (e) {
      return AuthyoResult.failure(UnknownError('$e'));
    }
    return parseCallback(callback, social);
  }

  /// Converts the callback URI into an [AuthyoResult]. Exposed so a custom
  /// [AuthyoSocialLoginHandler] can reuse the same parsing.
  static AuthyoResult parseCallback(String callback, AuthyoSocialLogin social) {
    final uri = Uri.tryParse(callback);
    if (uri == null) {
      return AuthyoResult.failure(UnknownError('Invalid callback'));
    }
    final q = uri.queryParameters;
    final success = q['success']?.toLowerCase() == 'true' || q['token'] != null;
    if (!success) {
      return AuthyoResult.failure(
        UnauthorizedError(q['message'] ?? q['error'] ?? 'Sign-in failed'),
      );
    }

    Map<String, dynamic> data = {};
    final rawData = q['data'];
    if (rawData != null && rawData.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawData);
        if (decoded is Map) data = Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    final token = q['token'] ?? data['token']?.toString();
    final email = q['email'] ?? data['email']?.toString();

    final model = AuthyoResponseModel(
      success: true,
      status: 'Success',
      message: q['message'] ?? 'verified successfully',
      data: Data(
        tokenType: data['tokenType']?.toString() ?? 'Bearer',
        token: token,
        expiresIn: data['expiresIn'] is num
            ? (data['expiresIn'] as num).toInt()
            : int.tryParse('${data['expiresIn'] ?? ''}'),
        user: User(
          userId: (data['user'] is Map ? data['user']['userId'] : null)
              ?.toString(),
          email: email,
          identity: email,
          channel: social.provider.apiName.toLowerCase(),
        ),
      ),
    );
    return AuthyoResult.success(model);
  }
}
