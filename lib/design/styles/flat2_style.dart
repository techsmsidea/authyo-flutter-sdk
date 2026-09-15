import 'package:flutter/material.dart';

import '../authyo_design_style.dart';
import 'authyo_style.dart';

/// Flat 2.0 (semi-flat): flat surfaces with subtle elevation and depth cues —
/// soft card shadow, a light tint behind the input and a gently lifted button.
class Flat2Style extends AuthyoStyle {
  Flat2Style(super.theme);

  @override
  AuthyoDesignStyle get id => AuthyoDesignStyle.flat2;

  @override
  double get cardRadius => 14;

  @override
  EdgeInsets get cardPadding => const EdgeInsets.fromLTRB(22, 14, 22, 18);

  @override
  BoxDecoration cardDecoration() => BoxDecoration(
    color: theme.surface,
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.12),
        blurRadius: 24,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  @override
  InputDecoration otpInputDecoration({required String hint, String? label}) {
    final base = super.otpInputDecoration(hint: hint, label: label);
    final soft = theme.inputBorder.withValues(alpha: 0.35);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderSide: BorderSide(color: c, width: w),
      borderRadius: BorderRadius.circular(inputRadius),
    );
    return base.copyWith(
      fillColor: Color.alphaBlend(
        theme.primary.withValues(alpha: 0.04),
        theme.inputBackground,
      ),
      border: border(soft),
      enabledBorder: border(soft),
      focusedBorder: border(theme.primary, 1.6),
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.buttonColor,
          borderRadius: BorderRadius.circular(buttonRadius),
          boxShadow: [
            BoxShadow(
              color: theme.buttonColor.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
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
    double size = 48,
  }) {
    final child = InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: IconTheme(
          data: IconThemeData(color: theme.primary, size: size * 0.5),
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
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(buttonRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: super.socialButton(icon: icon, label: label, onTap: onTap),
    );
  }
}
