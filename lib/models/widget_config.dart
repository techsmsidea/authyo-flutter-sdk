import '../design/authyo_design_style.dart';
import '../design/authyo_theme.dart';

/// Social identity providers that Authyo can be configured with from the
/// dashboard (Application → Social Media Login).
enum AuthyoSocialProvider {
  google('Google'),
  microsoft('Microsoft'),
  github('Github'),
  linkedin('LinkedIn'),
  apple('Apple'),
  unknown('Unknown');

  /// Provider name as the backend spells it (`Common.SocialMedia` enum).
  final String apiName;
  const AuthyoSocialProvider(this.apiName);

  static AuthyoSocialProvider fromName(String? name) {
    final n = (name ?? '').trim().toLowerCase();
    for (final p in values) {
      if (p.apiName.toLowerCase() == n || p.name == n) return p;
    }
    return unknown;
  }

  String get label {
    switch (this) {
      case google:
        return 'Google';
      case microsoft:
        return 'Microsoft';
      case github:
        return 'GitHub';
      case linkedin:
        return 'LinkedIn';
      case apple:
        return 'Apple';
      case unknown:
        return 'Sign in';
    }
  }
}

/// One social login button as configured on the dashboard.
class AuthyoSocialLogin {
  const AuthyoSocialLogin({
    required this.provider,
    required this.id,
    this.iconUrl,
  });

  /// Which identity provider.
  final AuthyoSocialProvider provider;

  /// `socialMediaLoginId` on the backend — sent to `/authlogin` to build the
  /// provider authorization URL.
  final String id;

  /// Optional icon override served by the backend.
  final String? iconUrl;

  String get label => 'Continue with ${provider.label}';

  factory AuthyoSocialLogin.fromJson(Map<String, dynamic> json) =>
      AuthyoSocialLogin(
        provider: AuthyoSocialProvider.fromName(
          (json['provider'] ?? json['name'])?.toString(),
        ),
        id: (json['id'] ?? json['socialMediaLoginId'] ?? '').toString(),
        iconUrl: json['iconUrl']?.toString(),
      );

  /// Parses the legacy `"Google,123"` / `"GoogleOneTap,5*clientId"` entries
  /// the web CDN endpoint mixes into its `results` array. Returns null for
  /// plain auth-method entries such as `"Sms"`.
  static AuthyoSocialLogin? fromLegacyEntry(String entry) {
    final comma = entry.indexOf(',');
    if (comma <= 0) return null;
    final name = entry.substring(0, comma);
    var id = entry.substring(comma + 1);
    final star = id.indexOf('*');
    if (star >= 0) id = id.substring(0, star);
    final provider = AuthyoSocialProvider.fromName(name);
    // GoogleOneTap is a browser-only flow.
    if (provider == AuthyoSocialProvider.unknown) return null;
    return AuthyoSocialLogin(provider: provider, id: id);
  }

  Map<String, dynamic> toJson() => {
    'provider': provider.apiName,
    'id': id,
    if (iconUrl != null) 'iconUrl': iconUrl,
  };
}

/// Remote configuration for the built-in dialog, as returned by
/// `GET /api/v1/authyoclient/mobileconfig`.
///
/// The parser is lenient: it also understands the shape returned by the web
/// CDN endpoint (`results` + `appCustomizationModel`) and the bare
/// `AppCustomizationModel` returned by `/user/getappcustomization`, so the
/// SDK keeps working whichever endpoint the backend exposes.
class AuthyoWidgetConfig {
  const AuthyoWidgetConfig({
    this.designStyle,
    this.theme = const AuthyoTheme(),
    this.authMethods = const [],
    this.socialLogins = const [],
    this.otpLength,
    this.raw,
  });

  /// Design style chosen on the dashboard, or null when the backend does not
  /// send one (older server) — the SDK then uses its local default.
  final AuthyoDesignStyle? designStyle;

  /// Colours / texts / layout from the dashboard customization.
  final AuthyoTheme theme;

  /// Enabled OTP channels, e.g. `["Sms", "Whatsapp", "Email"]`.
  final List<String> authMethods;

  /// Enabled social login buttons.
  final List<AuthyoSocialLogin> socialLogins;

  /// OTP length configured for the application.
  final int? otpLength;

  /// The raw JSON this config was parsed from (kept for caching).
  final Map<String, dynamic>? raw;

  static const AuthyoWidgetConfig empty = AuthyoWidgetConfig();

  factory AuthyoWidgetConfig.fromJson(Map<String, dynamic> json) {
    // Unwrap the API envelope if present.
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    Map<String, dynamic>? customization;
    for (final key in ['customization', 'appCustomizationModel']) {
      if (data[key] is Map) {
        customization = Map<String, dynamic>.from(data[key] as Map);
        break;
      }
    }
    // Bare AppCustomizationModel (getappcustomization).
    customization ??= data.containsKey('buttonColor') ? data : null;

    final methods = <String>[];
    final socials = <AuthyoSocialLogin>[];

    final rawMethods = data['authMethods'];
    if (rawMethods is List) {
      methods.addAll(rawMethods.map((e) => e.toString()));
    }
    final rawSocials = data['socialLogins'];
    if (rawSocials is List) {
      for (final s in rawSocials) {
        if (s is Map) {
          socials.add(AuthyoSocialLogin.fromJson(Map<String, dynamic>.from(s)));
        }
      }
    }
    // Legacy CDN shape: results mixes "Sms" and "Google,123".
    final legacy = data['results'];
    if (legacy is List) {
      for (final e in legacy) {
        final s = e.toString();
        final social = AuthyoSocialLogin.fromLegacyEntry(s);
        if (social != null) {
          socials.add(social);
        } else if (!s.contains(',')) {
          methods.add(s);
        }
      }
    }

    final styleRaw = data['designStyle'] ?? customization?['designStyle'];
    final otpRaw = data['otpLength'];

    return AuthyoWidgetConfig(
      designStyle: styleRaw == null
          ? null
          : AuthyoDesignStyle.fromValue(styleRaw),
      theme: AuthyoTheme.fromCustomization(customization),
      authMethods: methods,
      socialLogins: socials,
      otpLength: otpRaw is num ? otpRaw.toInt() : int.tryParse('$otpRaw'),
      raw: json,
    );
  }

  bool get hasSocialLogins => socialLogins.isNotEmpty;
}
