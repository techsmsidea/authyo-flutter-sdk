import 'package:flutter/material.dart';

import '../authyo_design_style.dart';
import 'authyo_style.dart';

/// Skeuomorphism: glossy gradients, bevelled edges and realistic depth —
/// a brushed card, a recessed input well and a "physical" glass button.
class SkeuomorphicStyle extends AuthyoStyle {
  SkeuomorphicStyle(super.theme);

  @override
  AuthyoDesignStyle get id => AuthyoDesignStyle.skeuomorphism;

  Color _lighten(Color c, [double amount = 0.12]) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color c, [double amount = 0.12]) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  Color get barrierColor => Colors.black.withValues(alpha: 0.6);

  @override
  double get cardRadius => 16;

  @override
  EdgeInsets get cardPadding => const EdgeInsets.fromLTRB(22, 14, 22, 18);

  @override
  BoxDecoration cardDecoration() => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_lighten(theme.surface, 0.04), _darken(theme.surface, 0.06)],
    ),
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: Colors.black.withValues(alpha: 0.18)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.45),
        blurRadius: 30,
        spreadRadius: 2,
        offset: const Offset(0, 16),
      ),
    ],
  );

  /// Bevel: a bright edge along the top and a dark edge along the bottom,
  /// painted as gradients so they can follow the rounded corners.
  @override
  Widget decorateCard(Widget card) => Stack(
    children: [
      card,
      Positioned.fill(
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cardRadius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.012, 0.985, 1],
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0),
                  Colors.black.withValues(alpha: 0),
                  Colors.black.withValues(alpha: 0.28),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );

  @override
  TextStyle get headerStyle => super.headerStyle.copyWith(
    shadows: [
      Shadow(
        color: Colors.white.withValues(alpha: 0.8),
        offset: const Offset(0, 1),
      ),
    ],
  );

  @override
  Widget logoFrame(Widget logo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_darken(theme.surface, 0.06), _lighten(theme.surface, 0.03)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.9),
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: logo,
    );
  }

  @override
  InputDecoration otpInputDecoration({required String hint, String? label}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderSide: BorderSide(color: c, width: w),
      borderRadius: BorderRadius.circular(inputRadius),
    );
    return super
        .otpInputDecoration(hint: hint, label: label)
        .copyWith(
          fillColor: _darken(theme.inputBackground, 0.03),
          border: border(Colors.black.withValues(alpha: 0.25)),
          enabledBorder: border(Colors.black.withValues(alpha: 0.25)),
          focusedBorder: border(theme.primary, 1.5),
        );
  }

  @override
  Widget decorateInput(Widget field) {
    // Recessed "well": an inner top shadow painted over the field.
    return Stack(
      children: [
        field,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 14,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(inputRadius),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.18),
                    Colors.black.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get buttonHeight => 48;

  @override
  Widget primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    final c = theme.buttonColor;
    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0, 0.5, 0.5, 1],
            colors: [_lighten(c, 0.18), _lighten(c, 0.06), c, _darken(c, 0.1)],
          ),
          borderRadius: BorderRadius.circular(buttonRadius),
          border: Border.all(color: _darken(c, 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.35),
              blurRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: buttonInk(
          onPressed: loading ? null : onPressed,
          radius: buttonRadius,
          child: DefaultTextStyle.merge(
            style: TextStyle(
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: buttonLabel(label, loading, theme.buttonTextColor),
          ),
        ),
      ),
    );
  }

  @override
  Widget circleIconButton({
    required Widget icon,
    required VoidCallback? onTap,
    String? tooltip,
    double size = 50,
  }) {
    final child = InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.4),
            radius: 0.9,
            colors: [
              _lighten(theme.surface, 0.06),
              _darken(theme.surface, 0.12),
            ],
          ),
          border: Border.all(color: Colors.black.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              offset: const Offset(0, 1),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: IconTheme(
          data: IconThemeData(color: theme.primary, size: size * 0.48),
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
    final c = theme.socialButtonColor;
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lighten(c, 0.06), _darken(c, 0.08)],
          ),
          borderRadius: BorderRadius.circular(buttonRadius),
          border: Border.all(color: _darken(c, 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
      ),
    );
  }
}
