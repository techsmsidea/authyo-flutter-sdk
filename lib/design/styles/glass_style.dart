import 'dart:ui';

import 'package:flutter/material.dart';

import '../authyo_design_style.dart';
import 'authyo_style.dart';

/// Glassmorphism: the card is a frosted, translucent version of its own
/// surface colour (Widget Background, white by default) with a blur of
/// whatever sits behind it, a light edge highlight and a soft tinted shadow.
/// Inputs and buttons are translucent versions of their configured colours.
///
/// Like every style it never paints outside the card — the barrier is the
/// same scrim the other styles use, and no gradient scene is added.
class GlassStyle extends AuthyoStyle {
  GlassStyle(super.theme);

  @override
  AuthyoDesignStyle get id => AuthyoDesignStyle.glassmorphism;

  @override
  double get cardRadius => 24;

  @override
  EdgeInsets get cardPadding => const EdgeInsets.fromLTRB(22, 14, 22, 20);

  /// Card colour the frost is made of.
  Color get _tint => theme.surface;

  Color _lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  /// The card itself is transparent: the surface colour, orbs and droplets
  /// are painted by [decorateCard] *under* the content.
  @override
  BoxDecoration cardDecoration() => BoxDecoration(
    borderRadius: BorderRadius.circular(cardRadius),
    border: Border.all(color: _lerp(_tint, Colors.white, 0.3)),
  );

  /// Glass needs colour behind it: soft orbs derived from the button colour
  /// are painted inside the card, under the content.
  /// Inputs and buttons are frosted panels that blur what is beneath them.
  @override
  Widget decorateCard(Widget card) {
    final btn = theme.primary;
    final orbA = btn.withValues(alpha: 0.55);
    final orbB = _lerp(
      btn,
      const Color(0xFFFF6EC7),
      0.4,
    ).withValues(alpha: 0.45);
    final orbC = _lerp(
      btn,
      const Color(0xFF4FD1FF),
      0.45,
    ).withValues(alpha: 0.40);
    return ClipRRect(
      borderRadius: BorderRadius.circular(cardRadius),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GlassScenePainter(_tint, orbA, orbB, orbC),
              ),
            ),
          ),
          card,
        ],
      ),
    );
  }

  /// Frosted panel used for inputs, buttons and social buttons.
  Widget _frosted({
    required Widget child,
    required Color fill,
    required double radius,
    BoxShadow? shadow,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill.withValues(alpha: theme.glassOpacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
            boxShadow: shadow == null ? null : [shadow],
          ),
          child: child,
        ),
      ),
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
          filled: false,
          border: border(Colors.transparent),
          enabledBorder: border(Colors.transparent),
          focusedBorder: border(theme.primary, 1.5),
        );
  }

  @override
  Widget decorateInput(Widget field) {
    return _frosted(
      fill: theme.inputBackground,
      radius: inputRadius,
      child: field,
    );
  }

  @override
  Widget primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: _frosted(
        fill: theme.buttonColor,
        radius: buttonRadius,
        shadow: BoxShadow(
          color: theme.buttonColor.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        child: buttonInk(
          onPressed: loading ? null : onPressed,
          radius: buttonRadius,
          child: buttonLabel(label, loading, theme.buttonTextColor),
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
          color: theme.socialButtonColor.withValues(alpha: 0.55),
          border: Border.all(
            color: theme.socialButtonBorderColor.withValues(alpha: 0.7),
          ),
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
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.socialButtonColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(buttonRadius),
          border: Border.all(
            color: theme.socialButtonBorderColor.withValues(alpha: 0.7),
          ),
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
                    fontWeight: FontWeight.w500,
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

  @override
  Widget socialIconButton({
    required Widget icon,
    required VoidCallback? onTap,
    String? tooltip,
  }) {
    final child = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(buttonRadius),
      child: Container(
        width: 52,
        height: 44,
        decoration: BoxDecoration(
          color: theme.socialButtonColor.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(buttonRadius),
          border: Border.all(
            color: theme.socialButtonBorderColor.withValues(alpha: 0.7),
          ),
        ),
        alignment: Alignment.center,
        child: SizedBox(width: 22, height: 22, child: icon),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip, child: child);
  }
}

/// Paints the "scene" the glass sits over: the surface colour and three
/// soft colour orbs, clipped to the card.
class _GlassScenePainter extends CustomPainter {
  _GlassScenePainter(this.surface, this.orbA, this.orbB, this.orbC);
  final Color surface, orbA, orbB, orbC;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = surface);
    void orb(Offset c, double r, Color color) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    orb(Offset(size.width * 0.15, size.height * 0.12), size.width * 0.55, orbA);
    orb(Offset(size.width * 0.88, size.height * 0.30), size.width * 0.45, orbB);
    orb(Offset(size.width * 0.70, size.height * 0.92), size.width * 0.50, orbC);
  }

  @override
  bool shouldRepaint(_GlassScenePainter old) =>
      old.surface != surface ||
      old.orbA != orbA ||
      old.orbB != orbB ||
      old.orbC != orbC;
}
