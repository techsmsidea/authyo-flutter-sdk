import 'package:flutter/material.dart';

import '../colors/app_color.dart';
import 'authyo_design_style.dart';

/// Horizontal alignment of the dialog content (maps to `mainLayout`).
enum AuthyoMainLayout {
  left(1),
  center(2),
  right(3);

  final int value;
  const AuthyoMainLayout(this.value);

  static AuthyoMainLayout fromValue(Object? raw) {
    final v = raw is int ? raw : int.tryParse('$raw');
    return values.firstWhere((e) => e.value == v, orElse: () => center);
  }

  CrossAxisAlignment get crossAxis {
    switch (this) {
      case left:
        return CrossAxisAlignment.start;
      case center:
        return CrossAxisAlignment.center;
      case right:
        return CrossAxisAlignment.end;
    }
  }

  TextAlign get textAlign {
    switch (this) {
      case left:
        return TextAlign.left;
      case center:
        return TextAlign.center;
      case right:
        return TextAlign.right;
    }
  }

  MainAxisAlignment get mainAxis {
    switch (this) {
      case left:
        return MainAxisAlignment.start;
      case center:
        return MainAxisAlignment.center;
      case right:
        return MainAxisAlignment.end;
    }
  }
}

/// Where social login buttons are placed relative to the OTP form
/// (maps to `socialMediaLayout`).
enum AuthyoSocialLayout {
  top(1),
  bottom(2);

  final int value;
  const AuthyoSocialLayout(this.value);

  static AuthyoSocialLayout fromValue(Object? raw) {
    final v = raw is int ? raw : int.tryParse('$raw');
    return values.firstWhere((e) => e.value == v, orElse: () => bottom);
  }
}

/// Button corner style (maps to `buttonStyle`: 1 rectangular, 2 rounded, 3 pill).
enum AuthyoButtonShape {
  rectangular(1, 0),
  rounded(2, 10),
  pill(3, 22);

  final int value;
  final double radius;
  const AuthyoButtonShape(this.value, this.radius);

  static AuthyoButtonShape fromValue(Object? raw) {
    final v = raw is int ? raw : int.tryParse('$raw');
    return values.firstWhere((e) => e.value == v, orElse: () => pill);
  }
}

/// Colour / text / layout tokens for the built-in dialog.
///
/// Every field has a default so a theme can be built from nothing, from the
/// remote customization returned by the Authyo dashboard, or from a partial
/// override supplied by the host app via `AuthyoService.init(theme: ...)`.
/// Use [merge] to layer them: `defaults.merge(remote).merge(local)`.
@immutable
class AuthyoTheme {
  const AuthyoTheme({
    this.primary,
    this.background,
    this.surface,
    this.inputBackground,
    this.inputBorder,
    this.inputText,
    this.buttonColor,
    this.buttonTextColor,
    this.buttonBorderColor,
    this.socialButtonColor,
    this.socialButtonTextColor,
    this.socialButtonBorderColor,
    this.headerText,
    this.headerTextColor,
    this.showHeader,
    this.bodyText,
    this.bodyTextColor,
    this.showBody,
    this.showLogo,
    this.logoUrl,
    this.logo,
    this.hideBranding,
    this.resendTimerSeconds,
    this.buttonShape,
    this.mainLayout,
    this.socialLayout,
    this.fontFamily,
    this.privacyLink,
    this.termsLink,
    this.glassOpacity,
    this.inputShape,
    this.inputUnderline,
    this.otpHidden,
    this.rememberMe,
    this.rememberMeDays,
  });

  final Color? primary;
  final Color? background;
  final Color? surface;
  final Color? inputBackground;
  final Color? inputBorder;
  final Color? inputText;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final Color? buttonBorderColor;
  final Color? socialButtonColor;
  final Color? socialButtonTextColor;
  final Color? socialButtonBorderColor;
  final String? headerText;
  final Color? headerTextColor;
  final bool? showHeader;
  final String? bodyText;
  final Color? bodyTextColor;
  final bool? showBody;
  final bool? showLogo;

  /// Remote logo. Falls back to [logo] and then to the bundled Authyo logo.
  final String? logoUrl;

  /// Local logo override (e.g. `AssetImage('assets/my_logo.png')`).
  final ImageProvider? logo;
  final bool? hideBranding;
  final int? resendTimerSeconds;
  final AuthyoButtonShape? buttonShape;
  final AuthyoMainLayout? mainLayout;
  final AuthyoSocialLayout? socialLayout;
  final String? fontFamily;
  final String? privacyLink;
  final String? termsLink;

  /// Glassmorphism only: opacity of the frosted card, 0.2–1.0 (dashboard
  /// "Glass Opacity" slider, stored as 20–100).
  final double? glassOpacity;

  /// Corner shape of the input fields (dashboard "Input Style"). Null =
  /// follow [buttonShape].
  final AuthyoButtonShape? inputShape;

  /// Dashboard "Hide OTP": typed digits are masked like a password.
  final bool? otpHidden;

  /// Dashboard "Remember me": show the checkbox in the dialog. Off = no
  /// checkbox, nothing sent, nothing stored.
  final bool? rememberMe;

  /// Days a remembered session stays valid (server side), 1..365.
  final int? rememberMeDays;

  /// Dashboard "Input Style" = borderless: inputs draw only a bottom line.
  final bool? inputUnderline;

  /// Built-in defaults: the 1.0.x look (Authyo blue, white surface, pill button).
  static const AuthyoTheme defaults = AuthyoTheme(
    primary: AppColor.primary,
    background: Color(0xFFF4F5FA),
    surface: Colors.white,
    inputBackground: Colors.white,
    inputBorder: AppColor.primary,
    inputText: Color(0xFF1F2333),
    buttonColor: AppColor.primary,
    buttonTextColor: Colors.white,
    buttonBorderColor: AppColor.primary,
    socialButtonColor: Colors.white,
    socialButtonTextColor: Color(0xFF1F2333),
    socialButtonBorderColor: Color(0xFFE0E3EE),
    headerText: 'Verify your identity',
    headerTextColor: Color(0xFF1F2333),
    showHeader: false,
    bodyText: '',
    bodyTextColor: Color(0xFF5B6070),
    showBody: false,
    showLogo: true,
    hideBranding: false,
    resendTimerSeconds: 60,
    buttonShape: AuthyoButtonShape.pill,
    mainLayout: AuthyoMainLayout.center,
    socialLayout: AuthyoSocialLayout.bottom,
    glassOpacity: 0.6,
  );

  /// Default palette for a design style — the same values the Authyo
  /// dashboard loads into the Color tab when that style is picked, so a
  /// locally pinned style looks like the dashboard preview. Layered *under*
  /// the dashboard / local values: `defaults.merge(stylePalette).merge(remote)`.
  static AuthyoTheme stylePalette(AuthyoDesignStyle style, {Color? primary}) {
    final btn = primary ?? AppColor.primary;
    Color mix(Color a, Color b, double tOfB) => Color.lerp(a, b, tOfB)!;
    switch (style) {
      case AuthyoDesignStyle.flat:
      case AuthyoDesignStyle.flat2:
        return const AuthyoTheme();
      case AuthyoDesignStyle.minimalism:
        return const AuthyoTheme(
          background: Colors.white,
          surface: Colors.white,
          headerTextColor: Color(0xFF1F2333),
          bodyTextColor: Color(0xFF5B6070),
          inputBackground: Colors.white,
          inputBorder: Color(0xFF9A9DB0),
          inputText: Color(0xFF1F2333),
          buttonColor: Color(0xFF1F2333),
          buttonTextColor: Colors.white,
          buttonBorderColor: Color(0xFF1F2333),
          socialButtonColor: Colors.white,
          socialButtonBorderColor: Color(0xFF9A9DB0),
        );
      case AuthyoDesignStyle.skeuomorphism:
        return const AuthyoTheme(
          background: Color(0xFFF2F3F7),
          surface: Color(0xFFF2F3F7),
          inputBackground: Color(0xFFECEEF5),
          inputBorder: Color(0xFFB9BCC9),
          socialButtonColor: Color(0xFFF4F5F9),
          socialButtonBorderColor: Color(0xFFB9BCC9),
        );
      case AuthyoDesignStyle.claymorphism:
        final pastel = mix(btn, Colors.white, 0.88);
        return AuthyoTheme(
          background: pastel,
          surface: pastel,
          headerTextColor: const Color(0xFF1F2333),
          bodyTextColor: const Color(0xFF5B6070),
          inputBackground: Colors.white,
          inputBorder: pastel,
          inputText: const Color(0xFF1F2333),
          buttonBorderColor: btn,
          socialButtonColor: Colors.white,
          socialButtonBorderColor: mix(btn, Colors.white, 0.75),
        );
      case AuthyoDesignStyle.glassmorphism:
        // Frost of the user's own colours; only surfaces are nudged.
        return const AuthyoTheme(
          background: Colors.white,
          surface: Colors.white,
          inputBackground: Colors.white,
          inputBorder: Colors.white,
          socialButtonColor: Colors.white,
          socialButtonBorderColor: Colors.white,
        );
      case AuthyoDesignStyle.neumorphism:
        return const AuthyoTheme(
          background: Color(0xFFE0E5EC),
          surface: Color(0xFFE0E5EC),
          headerTextColor: Color(0xFF3A4152),
          bodyTextColor: Color(0xFF3A4152),
          inputBackground: Color(0xFFE0E5EC),
          inputBorder: Color(0xFFE0E5EC),
          inputText: Color(0xFF3A4152),
          buttonBorderColor: Color(0xFFE0E5EC),
          socialButtonColor: Color(0xFFE0E5EC),
          socialButtonTextColor: Color(0xFF3A4152),
          socialButtonBorderColor: Color(0xFFE0E5EC),
        );
    }
  }

  /// Builds a partial theme from the `appCustomizationModel` JSON returned by
  /// the Authyo backend. Only keys present (and parseable) are set, so the
  /// result is meant to be merged over [defaults].
  factory AuthyoTheme.fromCustomization(Map<String, dynamic>? json) {
    if (json == null) return const AuthyoTheme();
    bool? flag(String k) => json[k] is bool ? json[k] as bool : null;
    String? str(String k) {
      final v = json[k];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    int? timer;
    final rawTimer = json['resendButtonTimer'];
    if (rawTimer is num) {
      timer = rawTimer.toInt();
    } else if (rawTimer != null) {
      timer = int.tryParse(rawTimer.toString());
    }

    return AuthyoTheme(
      primary: parseColor(json['buttonColor']),
      background: parseColor(json['bodyBackground']),
      surface: parseColor(json['bodyBackground']),
      inputBackground: parseColor(json['inputBackground']),
      inputBorder: parseColor(json['inputBorder']),
      inputText: parseColor(json['inputText']),
      buttonColor: parseColor(json['buttonColor']),
      buttonTextColor: parseColor(json['buttonTextColor']),
      buttonBorderColor: parseColor(json['buttonBorderColor']),
      socialButtonColor: parseColor(json['smButtonColor']),
      socialButtonTextColor: parseColor(json['smButtonText']),
      socialButtonBorderColor: parseColor(json['smButtonBorder']),
      headerText: str('headerText'),
      headerTextColor: parseColor(json['headerTextColor']),
      showHeader: flag('isHeader'),
      bodyText: str('bodyText'),
      bodyTextColor: parseColor(json['bodyTextColor']),
      showBody: flag('isBody'),
      showLogo: flag('isLogo'),
      logoUrl: str('logoUrl'),
      hideBranding: flag('hideBranding'),
      resendTimerSeconds: timer,
      buttonShape: json['buttonStyle'] == null
          ? null
          : AuthyoButtonShape.fromValue(json['buttonStyle']),
      mainLayout: json['mainLayout'] == null
          ? null
          : AuthyoMainLayout.fromValue(json['mainLayout']),
      socialLayout: json['socialMediaLayout'] == null
          ? null
          : AuthyoSocialLayout.fromValue(json['socialMediaLayout']),
      privacyLink: str('privacyLink'),
      termsLink: str('termsLink'),
      glassOpacity: json['glassOpacity'] is num
          ? ((json['glassOpacity'] as num).toDouble().clamp(20, 100) / 100)
          : null,
      inputShape:
          (json['inputStyle'] is num &&
              (json['inputStyle'] as num) > 0 &&
              (json['inputStyle'] as num) < 4)
          ? AuthyoButtonShape.fromValue(json['inputStyle'])
          : null,
      inputUnderline: json['inputStyle'] is num
          ? (json['inputStyle'] as num) == 4
          : null,
      otpHidden: flag('isOtpHide'),
      rememberMe: flag('isRememberMe'),
      rememberMeDays: json['rememberMeDays'] is num
          ? (json['rememberMeDays'] as num).toInt()
          : null,
    );
  }

  /// Returns a copy where every non-null field of [other] replaces this one.
  AuthyoTheme merge(AuthyoTheme? other) {
    if (other == null) return this;
    return AuthyoTheme(
      primary: other.primary ?? primary,
      background: other.background ?? background,
      surface: other.surface ?? surface,
      inputBackground: other.inputBackground ?? inputBackground,
      inputBorder: other.inputBorder ?? inputBorder,
      inputText: other.inputText ?? inputText,
      buttonColor: other.buttonColor ?? buttonColor,
      buttonTextColor: other.buttonTextColor ?? buttonTextColor,
      buttonBorderColor: other.buttonBorderColor ?? buttonBorderColor,
      socialButtonColor: other.socialButtonColor ?? socialButtonColor,
      socialButtonTextColor:
          other.socialButtonTextColor ?? socialButtonTextColor,
      socialButtonBorderColor:
          other.socialButtonBorderColor ?? socialButtonBorderColor,
      headerText: other.headerText ?? headerText,
      headerTextColor: other.headerTextColor ?? headerTextColor,
      showHeader: other.showHeader ?? showHeader,
      bodyText: other.bodyText ?? bodyText,
      bodyTextColor: other.bodyTextColor ?? bodyTextColor,
      showBody: other.showBody ?? showBody,
      showLogo: other.showLogo ?? showLogo,
      logoUrl: other.logoUrl ?? logoUrl,
      logo: other.logo ?? logo,
      hideBranding: other.hideBranding ?? hideBranding,
      resendTimerSeconds: other.resendTimerSeconds ?? resendTimerSeconds,
      buttonShape: other.buttonShape ?? buttonShape,
      mainLayout: other.mainLayout ?? mainLayout,
      socialLayout: other.socialLayout ?? socialLayout,
      fontFamily: other.fontFamily ?? fontFamily,
      privacyLink: other.privacyLink ?? privacyLink,
      termsLink: other.termsLink ?? termsLink,
      glassOpacity: other.glassOpacity ?? glassOpacity,
      inputShape: other.inputShape ?? inputShape,
      inputUnderline: other.inputUnderline ?? inputUnderline,
      otpHidden: other.otpHidden ?? otpHidden,
      rememberMe: other.rememberMe ?? rememberMe,
      rememberMeDays: other.rememberMeDays ?? rememberMeDays,
    );
  }

  /// A fully populated view of this theme (every getter non-null), used by
  /// the style renderers. Falls back to [defaults] for anything unset.
  AuthyoResolvedTheme resolve() => AuthyoResolvedTheme._(defaults.merge(this));

  /// Parses `#RGB`, `#RRGGBB`, `#AARRGGBB`, `rgb(r,g,b)` and `rgba(r,g,b,a)`.
  /// Returns null when the value is missing or unparseable.
  static Color? parseColor(Object? raw) {
    if (raw == null) return null;
    if (raw is Color) return raw;
    if (raw is int) return Color(raw);
    var s = raw.toString().trim().toLowerCase();
    if (s.isEmpty) return null;
    if (s.startsWith('rgb')) {
      final nums = RegExp(
        r'[\d.]+',
      ).allMatches(s).map((m) => double.tryParse(m.group(0)!) ?? 0).toList();
      if (nums.length >= 3) {
        final a = nums.length > 3 ? (nums[3] * 255).round() : 255;
        return Color.fromARGB(
          a.clamp(0, 255),
          nums[0].round().clamp(0, 255),
          nums[1].round().clamp(0, 255),
          nums[2].round().clamp(0, 255),
        );
      }
      return null;
    }
    s = s.replaceFirst('#', '').replaceFirst('0x', '');
    if (s.length == 3) {
      s = s.split('').map((c) => '$c$c').join();
    }
    if (s.length == 6) s = 'ff$s';
    if (s.length != 8) return null;
    final v = int.tryParse(s, radix: 16);
    return v == null ? null : Color(v);
  }
}

/// Non-nullable projection of an [AuthyoTheme] for use inside renderers.
class AuthyoResolvedTheme {
  AuthyoResolvedTheme._(this._t);
  final AuthyoTheme _t;

  Color get primary => _t.primary!;
  Color get background => _t.background!;
  Color get surface => _t.surface!;
  Color get inputBackground => _t.inputBackground!;
  Color get inputBorder => _t.inputBorder!;
  Color get inputText => _t.inputText!;
  Color get buttonColor => _t.buttonColor!;
  Color get buttonTextColor => _t.buttonTextColor!;
  Color get buttonBorderColor => _t.buttonBorderColor!;
  Color get socialButtonColor => _t.socialButtonColor!;
  Color get socialButtonTextColor => _t.socialButtonTextColor!;
  Color get socialButtonBorderColor => _t.socialButtonBorderColor!;
  String get headerText => _t.headerText!;
  Color get headerTextColor => _t.headerTextColor!;
  bool get showHeader => _t.showHeader!;
  String get bodyText => _t.bodyText!;
  Color get bodyTextColor => _t.bodyTextColor!;
  bool get showBody => _t.showBody!;
  bool get showLogo => _t.showLogo!;
  String? get logoUrl => _t.logoUrl;
  ImageProvider? get logo => _t.logo;
  bool get hideBranding => _t.hideBranding!;
  int get resendTimerSeconds =>
      _t.resendTimerSeconds! <= 0 ? 60 : _t.resendTimerSeconds!;
  AuthyoButtonShape get buttonShape => _t.buttonShape!;
  AuthyoMainLayout get mainLayout => _t.mainLayout!;
  AuthyoSocialLayout get socialLayout => _t.socialLayout!;
  String? get fontFamily => _t.fontFamily;
  String? get privacyLink => _t.privacyLink;
  String? get termsLink => _t.termsLink;
  double get glassOpacity => (_t.glassOpacity ?? 0.6).clamp(0.2, 1.0);

  bool get inputUnderline => _t.inputUnderline ?? false;
  bool get otpHidden => _t.otpHidden ?? false;
  bool get rememberMeEnabled => _t.rememberMe ?? false;
  int get rememberMeDays => (_t.rememberMeDays ?? 30).clamp(1, 365);

  /// Dashboard resend timer as configured (0 = not set). Sent to the server
  /// as the new expiry on resend, exactly like the web widget.
  int get resendTimerConfigured => _t.resendTimerSeconds ?? 0;

  /// Input corner radius: "Input Style" when set, else the button shape.
  double get inputRadius {
    final shape = _t.inputShape;
    if (shape == null) return buttonShape.radius.clamp(4, 24).toDouble();
    return shape == AuthyoButtonShape.pill
        ? 24
        : shape.radius.clamp(4, 24).toDouble();
  }

  /// Text colour that is readable on [surface].
  Color get onSurface =>
      ThemeData.estimateBrightnessForColor(surface) == Brightness.dark
      ? Colors.white
      : const Color(0xFF1F2333);

  /// Muted variant of [onSurface] for hints and secondary text.
  Color get onSurfaceMuted => onSurface.withValues(alpha: 0.6);
}
