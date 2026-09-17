import 'package:flutter/material.dart';

import '../authyo_design_style.dart';
import 'authyo_style.dart';

/// Claymorphism: pastel, puffy surfaces with very large radii, a soft
/// outer drop shadow and a light inner highlight so elements look like
/// moulded clay.
class ClayStyle extends AuthyoStyle {
  ClayStyle(super.theme);

  @override
  AuthyoDesignStyle get id => AuthyoDesignStyle.claymorphism;

  /// Card surface = dashboard "Widget Background" (palette default: a pastel
  /// tint of the button colour).
  Color get _pastel => theme.surface;

  Color get _pastelDeep => Color.lerp(theme.primary, Colors.white, 0.72)!;

  @override
  Color get barrierColor => _pastelDeep.withValues(alpha: 0.7);

  @override
  double get cardRadius => 32;

  @override
  EdgeInsets get cardPadding => const EdgeInsets.fromLTRB(24, 16, 24, 22);

  /// Two-tone clay shadow: soft coloured drop shadow + inner highlight.
  List<BoxShadow> _clayShadow(Color base, {double blur = 24}) => [
    BoxShadow(
      color: HSLColor.fromColor(base)
          .withLightness(
            (HSLColor.fromColor(base).lightness - 0.25).clamp(0.0, 1.0),
          )
          .toColor()
          .withValues(alpha: 0.35),
      blurRadius: blur,
      offset: Offset(0, blur * 0.5),
    ),
  ];

  /// Inner highlight: a soft white glow fading in from the top-left edge.
  /// (A non-uniform Border cannot be combined with a border radius, so the
  /// highlight is painted as a gradient instead.)
  BoxDecoration _innerGlow({
    BorderRadius? radius,
    BoxShape shape = BoxShape.rectangle,
    double strength = 0.55,
  }) => BoxDecoration(
    shape: shape,
    borderRadius: radius,
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      stops: const [0, 0.12, 0.45],
      colors: [
        Colors.white.withValues(alpha: strength),
        Colors.white.withValues(alpha: strength * 0.35),
        Colors.white.withValues(alpha: 0),
      ],
    ),
  );

  @override
  BoxDecoration cardDecoration() => BoxDecoration(
    color: _pastel,
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow: _clayShadow(_pastel, blur: 40),
  );

  @override
  Widget decorateCard(Widget card) {
    // Inner highlight rendered as an inset overlay so the card border does
    // not shrink the layout.
    return Stack(
      children: [
        card,
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: _innerGlow(
                radius: BorderRadius.circular(cardRadius),
                strength: 0.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  TextStyle get headerStyle =>
      super.headerStyle.copyWith(fontWeight: FontWeight.w700);

  @override
  InputDecoration otpInputDecoration({required String hint, String? label}) {
    OutlineInputBorder border(Color c, [double w = 0]) => OutlineInputBorder(
      borderSide: w == 0 ? BorderSide.none : BorderSide(color: c, width: w),
      borderRadius: BorderRadius.circular(inputRadius),
    );
    return super
        .otpInputDecoration(hint: hint, label: label)
        .copyWith(
          fillColor: theme.inputBackground,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          border: border(Colors.transparent),
          enabledBorder: border(Colors.transparent),
          focusedBorder: border(theme.primary, 2),
        );
  }

  @override
  Widget decorateInput(Widget field) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(inputRadius),
        boxShadow: [
          BoxShadow(
            color: _pastelDeep.withValues(alpha: 0.6),
            blurRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: field,
    );
  }

  @override
  double get buttonHeight => 52;

  Widget _clayBox({
    required Color color,
    required double radius,
    required Widget child,
    double? height,
  }) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: _clayShadow(color, blur: 16),
      ),
      foregroundDecoration: _innerGlow(radius: BorderRadius.circular(radius)),
      child: child,
    );
  }

  @override
  Widget primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return _clayBox(
      color: theme.buttonColor,
      radius: buttonRadius,
      height: buttonHeight,
      child: buttonInk(
        onPressed: loading ? null : onPressed,
        radius: buttonRadius,
        child: buttonLabel(label, loading, theme.buttonTextColor),
      ),
    );
  }

  @override
  Widget circleIconButton({
    required Widget icon,
    required VoidCallback? onTap,
    String? tooltip,
    double size = 54,
  }) {
    final child = InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.socialButtonColor,
          boxShadow: _clayShadow(_pastel, blur: 14),
        ),
        foregroundDecoration: _innerGlow(shape: BoxShape.circle),
        alignment: Alignment.center,
        child: IconTheme(
          data: IconThemeData(color: theme.primary, size: size * 0.46),
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
    return _clayBox(
      color: theme.socialButtonColor,
      radius: buttonRadius,
      height: 48,
      child: buttonInk(
        onPressed: onTap,
        radius: buttonRadius,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20, height: 20, child: icon),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.socialButtonTextColor,
                ),
              ),
            ),
          ],
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
    final child = SizedBox(
      width: 56,
      child: _clayBox(
        color: theme.socialButtonColor,
        radius: buttonRadius,
        height: 48,
        child: buttonInk(
          onPressed: onTap,
          radius: buttonRadius,
          child: SizedBox(width: 22, height: 22, child: icon),
        ),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip, child: child);
  }
}
