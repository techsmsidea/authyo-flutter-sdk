import 'package:flutter/material.dart';

import '../authyo_design_style.dart';
import '../authyo_theme.dart';
import 'authyo_style.dart';

/// Minimalism: monochrome, typography-driven, generous whitespace.
/// Inputs are a single bottom line, buttons are thin outlines, and the
/// accent colour is used sparingly (only on the focused line and links).
class MinimalStyle extends AuthyoStyle {
  MinimalStyle(super.theme);

  @override
  AuthyoDesignStyle get id => AuthyoDesignStyle.minimalism;

  Color get _ink => theme.onSurface;

  @override
  Color get barrierColor => Colors.black.withValues(alpha: 0.25);

  @override
  double get cardRadius => 4;

  @override
  EdgeInsets get cardPadding => const EdgeInsets.fromLTRB(28, 16, 28, 28);

  @override
  BoxDecoration cardDecoration() => BoxDecoration(
    color: theme.surface,
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 30,
        offset: const Offset(0, 12),
      ),
    ],
  );

  @override
  TextStyle get headerStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.4,
    color: theme.headerTextColor,
  );

  @override
  TextStyle get infoStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    letterSpacing: 0.3,
    color: theme.onSurfaceMuted,
  );

  @override
  TextStyle get linkStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    color: _ink,
    decoration: TextDecoration.underline,
    decorationColor: _ink.withValues(alpha: 0.5),
  );

  @override
  TextStyle get otpTextStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    letterSpacing: 10,
    fontWeight: FontWeight.w300,
    color: theme.inputText,
  );

  @override
  InputDecoration otpInputDecoration({required String hint, String? label}) {
    UnderlineInputBorder line(Color c, [double w = 1]) => UnderlineInputBorder(
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: fontFamily,
        color: theme.onSurfaceMuted.withValues(alpha: 0.4),
        letterSpacing: 10,
      ),
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: line(_ink.withValues(alpha: 0.25)),
      enabledBorder: line(_ink.withValues(alpha: 0.25)),
      focusedBorder: line(theme.primary, 1.5),
      errorBorder: line(Colors.redAccent),
      focusedErrorBorder: line(Colors.redAccent, 1.5),
    );
  }

  @override
  double get buttonHeight => 48;

  /// Square by default; follows the dashboard shape when rounded / pill.
  double get _r =>
      theme.buttonShape == AuthyoButtonShape.rectangular ? 2 : buttonRadius;

  @override
  Widget primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _ink,
          borderRadius: BorderRadius.circular(_r),
        ),
        child: buttonInk(
          onPressed: loading ? null : onPressed,
          radius: _r,
          child: loading
              ? buttonLabel(label, true, theme.surface)
              : Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w500,
                    color: theme.surface,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Color get iconTint => _ink;

  @override
  Widget circleIconButton({
    required Widget icon,
    required VoidCallback? onTap,
    String? tooltip,
    double size = 44,
  }) {
    final child = InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: _ink.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: IconTheme(
          data: IconThemeData(color: _ink, size: size * 0.45),
          child: icon,
        ),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip, child: child);
  }

  @override
  Widget socialButton({
    required Widget icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_r),
          border: Border.all(color: _ink.withValues(alpha: 0.3)),
        ),
        child: buttonInk(
          onPressed: onTap,
          radius: _r,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 18, height: 18, child: icon),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 13,
                    letterSpacing: 0.4,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget socialIconButton({
    required Widget icon,
    required VoidCallback? onTap,
    String? tooltip,
  }) {
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_r),
      child: Container(
        width: 52,
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_r),
          border: Border.all(color: _ink.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: SizedBox(width: 20, height: 20, child: icon),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip, child: child);
  }
}
