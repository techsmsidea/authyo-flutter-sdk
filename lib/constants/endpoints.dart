class AuthyoEndpoints {
  /// Default server. Override per app with `AuthyoService.init(baseUrl: ...)`
  /// (e.g. a staging or local instance).
  static const String defaultBaseUrl = "https://authyo.io";

  /// OTP API (send / verify), relative to the server base URL.
  static const String apiPath = "/api/v1/authyoapi";
  static const String baseUrlEndpoint = "$defaultBaseUrl$apiPath";
  static const String sendOtpEndpoint = "/sendotp";
  static const String verifyOtpEndpoint = "/verifyotp";

  /// Client / widget API (dialog configuration, social login).
  static const String clientPath = "/api/v1/authyoclient";
  static const String clientBaseUrlEndpoint = "$defaultBaseUrl$clientPath";

  /// Returns design style, customization, enabled channels and social logins
  /// for the application identified by the clientId / clientSecret headers.
  static const String mobileConfigPath = "/mobileconfig";
  static const String mobileConfigEndpoint =
      "$clientBaseUrlEndpoint$mobileConfigPath";

  /// Builds the provider authorization URL for a social login.
  static const String authLoginPath = "/authlogin";
  static const String authLoginEndpoint =
      "$clientBaseUrlEndpoint$authLoginPath";

  /// Normalises a user supplied server URL ("https://host[:port]" with or
  /// without a trailing slash) to no trailing slash.
  static String normalizeBaseUrl(String? url) {
    final u = (url ?? '').trim();
    if (u.isEmpty) return defaultBaseUrl;
    return u.replaceAll(RegExp(r'/+$'), '');
  }

  /// Custom URL scheme the OAuth callback redirects to on mobile.
  static const String oauthCallbackScheme = "authyo";
}
