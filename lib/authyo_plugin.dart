/// The AuthyoPlugin to make your app's password-less authentications smooth and easy
/// Use [AuthyoService] to initialize your API client, set clientId and clientSecret,
/// and perform [sendOtp] and [verifyOtp] calls.
/// Response is returned as [AuthyoResult] class.

library;

import 'dart:async';
import 'dart:convert';

import 'package:authyo_plugin/component/verification_dialog.dart';
import 'package:authyo_plugin/constants/endpoints.dart';
import 'package:authyo_plugin/design/authyo_design_style.dart';
import 'package:authyo_plugin/design/authyo_style_factory.dart';
import 'package:authyo_plugin/design/styles/authyo_style.dart';
import 'package:authyo_plugin/design/authyo_theme.dart';
import 'package:authyo_plugin/models/verify_otp_input_params.dart';
import 'package:authyo_plugin/models/widget_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/base_response_model.dart';
import 'models/send_otp_input_params.dart';

export 'component/verification_dialog.dart'
    show PhoneVerificationDialog, AuthyoVerificationDialog;
export 'design/authyo_design_style.dart';
export 'design/authyo_theme.dart';
export 'design/styles/authyo_style.dart' show AuthyoStyle;
export 'models/base_response_model.dart';
export 'models/widget_config.dart';

part 'services/api_service.dart';

part 'services/config_service.dart';

part 'social/social_login_service.dart';

part 'handlers/authyo_error.dart';

part 'handlers/errors.dart';

part 'models/authyo_result.dart';

/// Enum representing the available OTP delivery channels in Authyo.
enum AuthwayEnum {
  /// Send OTP via WhatsApp
  whatsapp('WHATSAPP'),

  /// Send OTP via Email
  email('Email'),

  /// Send OTP via SMS
  sms('SMS'),

  /// Send OTP via Voice Call
  voiceCall('VoiceCall');

  /// The string identifier for each auth way (used internally).
  final String authWay;

  const AuthwayEnum(this.authWay);
}

/// Singleton service to interact with Authyo APIs for sending and verifying OTPs.
class AuthyoService {
  /// The single instance of [AuthyoService].
  static final AuthyoService instance = AuthyoService._internal();
  _ApiService? _apiService;
  _ConfigService? _configService;
  _SocialLoginService? _socialService;
  bool _showDefaultDialog = true;

  AuthyoDesignStyle? _localStyle;
  AuthyoTheme? _localTheme;
  AuthyoSocialLoginHandler? _socialHandler;

  AuthyoService._internal();

  /// For tests: lets a fake subclass stand in for the network service
  /// (pass it as `PhoneVerificationDialog(service: ...)`).
  @protected
  @visibleForTesting
  AuthyoService.forTesting();

  /// Initializes the plugin with your [clientId] and [clientSecret].
  ///
  /// You can optionally set [connectTimeout], [receiveTimeout], and whether to
  /// use the built-in verification dialog with [showVerificationDialog].
  ///
  /// The dialog's look is resolved in this order — later wins:
  ///
  /// 1. built-in defaults (Flat, Authyo blue)
  /// 2. the design style + customization configured on your Authyo dashboard
  ///    (fetched in the background and cached on device)
  /// 3. [designStyle] / [theme] passed here
  ///
  /// [onSocialLogin] lets you run social sign-in with your own native SDKs
  /// instead of the system browser; see [AuthyoSocialLoginHandler].
  ///
  /// [baseUrl] points the SDK at another Authyo server (staging / local),
  /// e.g. `http://10.0.2.2:5000` from the Android emulator. Defaults to
  /// `https://authyo.io`.
  ///
  /// Call this method before making any [sendOtp] or [verifyOtp] requests.
  void init({
    String? clientId,
    String? clientSecret,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool? showVerificationDialog,
    AuthyoDesignStyle? designStyle,
    AuthyoTheme? theme,
    AuthyoSocialLoginHandler? onSocialLogin,
    bool prefetchConfig = true,
    String? baseUrl,
  }) {
    if (clientId == null || clientSecret == null) {
      throw AuthyoInitializationError('''
Oops! Looks like you forgot to pass clientId or clientSecret to AuthyoService.init().
These are required to authenticate with Authyo.

🔐 Grab your credentials here:
https://app.authyo.io/account/welcome?ref=HARSCE2BE4&utm_source=partner&utm_medium=referral&utm_campaign=partner-program
''');
    }

    final api = _ApiService(
      clientId: clientId,
      clientSecret: clientSecret,
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
      baseUrl: baseUrl,
    );
    _apiService = api;
    _configService = _ConfigService(api, clientId: clientId);
    _socialService = _SocialLoginService(api);

    _showDefaultDialog = showVerificationDialog ?? true;
    _localStyle = designStyle;
    _localTheme = theme;
    _socialHandler = onSocialLogin;

    if (prefetchConfig) {
      // Warm the cache so the first dialog already has the dashboard look.
      unawaited(loadConfig().catchError((_) => AuthyoWidgetConfig.empty));
    }
  }

  /// Clears the current [clientId] and [clientSecret].
  void clearToken() {
    _apiService?.clearToken();
  }

  _ApiService get _api {
    final api = _apiService;
    if (api == null) {
      throw AuthyoInitializationError(
        'AuthyoService has not been initialized, please initialize and try again',
      );
    }
    return api;
  }

  // ---------------------------------------------------------------------------
  // Configuration & design
  // ---------------------------------------------------------------------------

  /// Loads the dialog configuration (design style, customization, enabled
  /// channels, social logins) from your Authyo dashboard.
  ///
  /// Uses the on-device cache when available and refreshes in the background;
  /// pass [forceRefresh] to hit the network first. Never throws — on failure
  /// the cached or empty config is returned.
  Future<AuthyoWidgetConfig> loadConfig({bool forceRefresh = false}) {
    _api; // ensure initialised
    return _configService!.load(forceRefresh: forceRefresh);
  }

  /// The configuration currently in memory, if any.
  AuthyoWidgetConfig? get currentConfig => _configService?.current;

  /// Forgets the cached remote configuration.
  Future<void> clearConfigCache() async => _configService?.clear();

  /// Enables / disables the built-in verification dialog for subsequent
  /// [sendOtp] calls (same as the `showVerificationDialog` argument of [init]).
  void setShowVerificationDialog(bool show) => _showDefaultDialog = show;

  /// Changes the design style used for subsequent dialogs (overrides the
  /// dashboard setting). Pass null to follow the dashboard again.
  void setDesignStyle(AuthyoDesignStyle? style) => _localStyle = style;

  /// Changes the local theme override used for subsequent dialogs.
  void setTheme(AuthyoTheme? theme) => _localTheme = theme;

  /// The design style that will be used for the next dialog.
  AuthyoDesignStyle get effectiveDesignStyle =>
      _localStyle ?? currentConfig?.designStyle ?? AuthyoDesignStyle.flat;

  /// The fully merged theme that will be used for the next dialog:
  /// built-in defaults ← style palette ← dashboard colours ← local overrides.
  AuthyoTheme get effectiveTheme => themeFor(effectiveDesignStyle);

  /// Same as [effectiveTheme] but for an explicit [style].
  AuthyoTheme themeFor(AuthyoDesignStyle style, {AuthyoTheme? extra}) {
    final primary =
        _localTheme?.buttonColor ??
        currentConfig?.theme.buttonColor ??
        AuthyoTheme.defaults.buttonColor;
    return AuthyoTheme.defaults
        .merge(AuthyoTheme.stylePalette(style, primary: primary))
        .merge(currentConfig?.theme)
        .merge(_localTheme)
        .merge(extra);
  }

  /// Builds the renderer for the current style + theme.
  AuthyoStyle buildStyle({AuthyoDesignStyle? style, AuthyoTheme? theme}) {
    final s = style ?? effectiveDesignStyle;
    return AuthyoStyleFactory.create(s, themeFor(s, extra: theme));
  }

  /// Shows the built-in verification dialog for an OTP that has already been
  /// sent ([sendResult] must be the successful result of [sendOtp] /
  /// [requestOtp]).
  ///
  /// Waits for the remote config (cached → instant, otherwise a short fetch)
  /// so the dialog opens with the dashboard's design.
  Future<void> showVerificationDialog(
    BuildContext context, {
    required AuthyoResult sendResult,
    required String to,
    void Function(AuthyoResult authyoResult)? onVerificationComplete,
    AuthyoDesignStyle? designStyle,
    AuthyoTheme? theme,
    int? otpLength,
  }) async {
    final config = await loadConfig().timeout(
      const Duration(seconds: 4),
      onTimeout: () => currentConfig ?? AuthyoWidgetConfig.empty,
    );
    if (!context.mounted) return;

    final style = buildStyle(style: designStyle, theme: theme);
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Authyo verification',
      barrierColor: style.barrierColor,
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(
            begin: 0.96,
            end: 1.0,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
      pageBuilder: (_, __, ___) => PhoneVerificationDialog(
        authyoRes: sendResult,
        to: to,
        onVerificationComplete: onVerificationComplete,
        style: style,
        config: config,
        otpLength: otpLength ?? config.otpLength,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OTP
  // ---------------------------------------------------------------------------

  /// Sends an OTP without any UI. This is what [sendOtp] and the dialog's
  /// "resend" use under the hood.
  ///
  /// Validates [to] for the given [authWay] (email address for
  /// [AuthwayEnum.email], international phone number for the others; when
  /// [authWay] is null the server picks the channel by its priority).
  Future<AuthyoResult> requestOtp({
    required String to,
    int? expiry,
    int? otpLength,
    AuthwayEnum? authWay,
  }) async {
    final api = _api;
    if (to.trim().isEmpty) {
      return AuthyoResult.failure(
        InternalServerError("Enter valid Phone or Email address."),
      );
    }

    if (authWay == AuthwayEnum.email && !_isValidEmail(to)) {
      return AuthyoResult.failure(
        InternalServerError("Please check the Email address!"),
      );
    }
    if (authWay != null &&
        authWay != AuthwayEnum.email &&
        !_isValidPhoneNumber(to.startsWith('+') ? to : '+$to')) {
      return AuthyoResult.failure(
        InternalServerError("Please check the Phone Number!"),
      );
    }

    final params = AuthyoOTPRequestParams(
      authway: authWay?.authWay ?? "",
      expiry: expiry,
      otplength: otpLength,
      to: to,
    );
    final response = await api.post(
      AuthyoEndpoints.sendOtpEndpoint,
      body: params.toJson(),
    );

    final sent = response.data?.results?.any((r) => r.success == true) ?? false;
    if (response.success == true && sent) {
      return AuthyoResult.success(response);
    }
    final fallback = authWay == null
        ? 'Oops, Issue in sending OTP. Please check the entered details.'
        : 'Error in sending OTP. Please check the entered details.';
    return AuthyoResult.failure(
      InternalServerError(
        response.error ??
            response.data?.results
                ?.map((r) => r.message)
                .whereType<String>()
                .firstOrNull ??
            fallback,
      ),
    );
  }

  /// SEND OTP REQUEST
  /// Triggers a [sendOtp] request to Authyo Servers using your [clientId] and [clientSecret].
  /// [to] param requires a [phoneNumber] or [emailAddress]
  /// This request optionally accepts [expiry] (in seconds), [otpLength] (By Default 6), [authWay] (sms,whatsapp etc..).
  /// Returns an [AuthyoResult] containing either the an [AuthyoResponseModel] or an [ApiError].
  /// [authWay] an optional argument to specify the platform to send OTP such as SMS, Whatsapp, Voice call.
  /// [onVerificationComplete] callback function to check whether OTP validation is successful or not. It should be ONLY used when plugin's default OTP verification dialog is used.
  /// [designStyle] / [theme] override the dialog look for this call only.
  Future<AuthyoResult> sendOtp({
    required BuildContext ctx,
    required String to,
    bool resendOTP = false,
    int? expiry,
    int? otpLength,
    AuthwayEnum? authWay,
    void Function(AuthyoResult authyoResult)? onVerificationComplete,
    AuthyoDesignStyle? designStyle,
    AuthyoTheme? theme,
  }) async {
    final messenger = ScaffoldMessenger.maybeOf(ctx);
    _api; // throws AuthyoInitializationError if not initialised

    final result = await requestOtp(
      to: to,
      expiry: expiry,
      otpLength: otpLength,
      authWay: authWay,
    );

    if (result.error != null) {
      if (authWay == AuthwayEnum.email &&
          result.error!.message.contains('Email address')) {
        messenger?.showSnackBar(
          const SnackBar(content: Text('Please check the Email address!')),
        );
      }
      return result;
    }

    if (_showDefaultDialog && !resendOTP && ctx.mounted) {
      unawaited(
        showVerificationDialog(
          ctx,
          sendResult: result,
          to: to,
          onVerificationComplete: onVerificationComplete,
          designStyle: designStyle,
          theme: theme,
          otpLength: otpLength,
        ),
      );
    }
    return result;
  }

  /// VERIFY OTP
  /// Triggers a [verifyOtp] request to Authyo Servers using your [clientId] and [clientSecret].
  /// [maskId] param requires a valid maskId received from [sendOtp] response, in case of success.
  /// [otp] param requires the OTP you have received via your desired [authWay]
  /// Returns an [AuthyoResult] containing either the an [AuthyoResponseModel] or an [ApiError].
  Future<AuthyoResult> verifyOtp({
    required String maskId,
    required String otp,
  }) async {
    final api = _api;
    VerifyOTPParams verifyOTPParams = VerifyOTPParams(maskId: maskId, otp: otp);
    AuthyoResponseModel response = await api.get(
      AuthyoEndpoints.verifyOtpEndpoint,
      queryParameters: verifyOTPParams.toJson(),
    );
    if (response.success == true) {
      return AuthyoResult.success(response);
    }
    return AuthyoResult.failure(
      InternalServerError(
        response.error ?? "Something went wrong while processing your request",
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Social login
  // ---------------------------------------------------------------------------

  /// Runs a social login for one of the providers enabled on your dashboard
  /// (see [AuthyoWidgetConfig.socialLogins]).
  ///
  /// Opens the provider in the system browser and returns once the Authyo
  /// callback redirects back to the app (`authyo://oauth/callback`). On
  /// success `result.data.token` holds the session JWT. If an
  /// `onSocialLogin` handler was given to [init], it is used instead of the
  /// browser.
  Future<AuthyoResult> socialLogin(AuthyoSocialLogin login) {
    _api;
    return _socialService!.login(login, handler: _socialHandler);
  }

  /// Parses an OAuth callback URI (`authyo://oauth/callback?...`) into an
  /// [AuthyoResult]. Useful inside a custom [AuthyoSocialLoginHandler].
  static AuthyoResult parseSocialCallback(
    String callbackUri,
    AuthyoSocialLogin login,
  ) => _SocialLoginService.parseCallback(callbackUri, login);

  // ---------------------------------------------------------------------------

  /// Validates whether the given phone number is in international format.
  bool _isValidPhoneNumber(String phoneNumber) {
    final RegExp regex = RegExp(r'^\+[1-9]\d{9,15}$');
    return regex.hasMatch(phoneNumber);
  }

  /// Validates if the given string is a valid email address.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }
}
