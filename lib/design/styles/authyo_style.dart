import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../verified_badge.dart';

import '../authyo_design_style.dart';
import '../authyo_theme.dart';

/// Base renderer for the verification dialog.
///
/// The dialog is built from a fixed set of slots (card, OTP field, primary
/// button, icon buttons, social buttons, text styles). A design style
/// overrides the decoration of those slots but never the behaviour — the
/// logic lives in `VerificationController`.
///
/// The defaults here produce the **Flat** look; the other styles subclass
/// this and override only what differs.
abstract class AuthyoStyle {
  AuthyoStyle(this.theme);

  /// Resolved (non-nullable) theme tokens.
  final AuthyoResolvedTheme theme;

  AuthyoDesignStyle get id;

  // ---------------------------------------------------------------------------
  // Dialog chrome
  // ---------------------------------------------------------------------------

  /// Colour drawn behind the dialog.
  Color get barrierColor => Colors.black.withValues(alpha: 0.45);

  /// Padding inside the card.
  EdgeInsets get cardPadding => const EdgeInsets.fromLTRB(20, 12, 20, 16);

  /// Card corner radius.
  double get cardRadius => 8;

  /// Decoration of the dialog card.
  BoxDecoration cardDecoration() => BoxDecoration(
    color: theme.surface,
    borderRadius: BorderRadius.circular(cardRadius),
  );

  /// Full-screen layer drawn behind the (already centred, scrollable)
  /// dialog. Styles with a special backdrop (blur, gradient) override this
  /// and must return [dialog] on top of their own layers.
  Widget backdrop(BuildContext context, Widget dialog) => dialog;

  /// Wraps the decorated card (e.g. with a blur filter or an overlay).
  Widget decorateCard(Widget card) => card;

  /// Base font family applied to everything in the dialog.
  String? get fontFamily => theme.fontFamily;

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  TextStyle get headerStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: theme.headerTextColor,
  );

  TextStyle get bodyStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    color: theme.bodyTextColor,
    height: 1.4,
  );

  TextStyle get infoStyle =>
      TextStyle(fontFamily: fontFamily, fontSize: 12, color: theme.onSurface);

  TextStyle get mutedStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: theme.onSurfaceMuted,
  );

  TextStyle get linkStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: theme.primary,
  );

  TextStyle get brandStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: theme.onSurfaceMuted,
  );

  // ---------------------------------------------------------------------------
  // Components
  // ---------------------------------------------------------------------------

  /// Corner radius for the OTP input.
  double get inputRadius => theme.inputRadius;

  /// Corner radius for buttons (driven by the dashboard `buttonStyle`).
  double get buttonRadius => theme.buttonShape.radius;

  /// Height of the primary button.
  double get buttonHeight => 46;

  /// Decoration for the OTP input field.
  InputDecoration otpInputDecoration({required String hint, String? label}) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderSide: BorderSide(color: c, width: w),
      borderRadius: BorderRadius.circular(inputRadius),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: theme.inputBackground,
      hintStyle: TextStyle(
        fontFamily: fontFamily,
        color: theme.onSurfaceMuted,
        letterSpacing: 4,
      ),
      labelStyle: TextStyle(
        fontFamily: fontFamily,
        color: theme.onSurfaceMuted,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(theme.inputBorder),
      enabledBorder: border(theme.inputBorder),
      focusedBorder: border(theme.primary, 1.5),
      errorBorder: border(Colors.redAccent),
      focusedErrorBorder: border(Colors.redAccent, 1.5),
    );
  }

  /// Borderless variant used when the dashboard "Input Style" is set to
  /// underline: no fill, only a bottom line, in every design style.
  InputDecoration underlineInputDecoration({
    required String hint,
    String? label,
  }) {
    UnderlineInputBorder line(Color c, [double w = 1]) => UnderlineInputBorder(
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: false,
      hintStyle: TextStyle(
        fontFamily: fontFamily,
        color: theme.onSurfaceMuted,
        letterSpacing: 4,
      ),
      labelStyle: TextStyle(
        fontFamily: fontFamily,
        color: theme.onSurfaceMuted,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      border: line(theme.inputBorder),
      enabledBorder: line(theme.inputBorder),
      focusedBorder: line(theme.primary, 1.5),
      errorBorder: line(Colors.redAccent),
      focusedErrorBorder: line(Colors.redAccent, 1.5),
    );
  }

  /// Text style of the digits typed in the OTP field.
  TextStyle get otpTextStyle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    letterSpacing: 6,
    fontWeight: FontWeight.w600,
    color: theme.inputText,
  );

  /// Extra chrome a style paints around an input (inset shadow, frost,
  /// clay drop…). Applied to the single-field [otpField] and to every
  /// digit box of [otpBox], so both looks stay identical. Not used for the
  /// underline input style, which is chrome-less in every design.
  Widget decorateInput(Widget field) => field;

  /// Single-field OTP input (kept for hosts that build their own layout).
  Widget otpField({
    required TextEditingController controller,
    required String hint,
    String? label,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onSubmitted,
    int? maxLength,
  }) {
    final field = TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      style: otpTextStyle,
      maxLength: maxLength,
      obscureText: theme.otpHidden,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration:
          (theme.inputUnderline
                  ? underlineInputDecoration(hint: hint, label: label)
                  : otpInputDecoration(hint: hint, label: label))
              .copyWith(counterText: ''),
      validator: validator,
      onFieldSubmitted: onSubmitted,
      autofillHints: const [AutofillHints.oneTimeCode],
    );
    return theme.inputUnderline ? field : decorateInput(field);
  }

  /// Size of one OTP digit box (the web widget uses 40px boxes, 8px apart).
  Size get otpBoxSize => const Size(42, 48);

  /// Gap between OTP digit boxes.
  double get otpBoxGap => 8;

  /// One digit box of the OTP entry; the dialog renders one per digit, with
  /// auto-advance and auto-verify like the web widget.
  Widget otpBox({
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
    bool autofocus = false,
  }) {
    final decoration =
        (theme.inputUnderline
                ? underlineInputDecoration(hint: '')
                : otpInputDecoration(hint: ''))
            .copyWith(
              counterText: '',
              hintText: null,
              labelText: null,
              isDense: true,
              // Centre the digit and make the field fill the whole box.
              contentPadding: EdgeInsets.symmetric(
                vertical: ((otpBoxSize.height - 26) / 2).clamp(0, 48),
              ),
            );
    final field = TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      textAlignVertical: TextAlignVertical.center,
      style: otpTextStyle.copyWith(letterSpacing: 0),
      obscureText: theme.otpHidden,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: decoration,
      onChanged: onChanged,
      autofillHints: const [AutofillHints.oneTimeCode],
    );
    return SizedBox(
      width: otpBoxSize.width,
      height: otpBoxSize.height,
      child: theme.inputUnderline ? field : decorateInput(field),
    );
  }

  /// "OTP sent to: …" chip with the "Change" link beside it, like
  /// the web widget's row under the header.
  /// [onChange] null hides the link (verified state).
  Widget sentToRow({required String target, VoidCallback? onChange}) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 4,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            'OTP sent to: $target',
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: theme.primary,
            ),
          ),
        ),
        if (onChange != null)
          InkWell(
            onTap: onChange,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Text(
                'Change',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontSize: 14,
                  color: theme.primary,
                  decoration: TextDecoration.underline,
                  decorationColor: theme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Countdown / expiry line under the OTP boxes. [error] switches to the
  /// red "OTP expired…" look.
  Widget statusText(String text, {bool error = false, TextAlign? align}) {
    return Text(
      text,
      textAlign: align ?? TextAlign.center,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: 13,
        color: error ? const Color(0xFFD8000C) : theme.primary,
      ),
    );
  }

  /// Green ring + check + "Verified successfully", shown inside the card
  /// once verification succeeds (same as the web widget).
  Widget verifiedBadge({String message = 'Verified successfully'}) =>
      AuthyoVerifiedBadge(message: message, fontFamily: fontFamily);

  /// The main "Verify" button.
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
          border: Border.all(color: theme.buttonBorderColor),
        ),
        child: buttonInk(
          onPressed: loading ? null : onPressed,
          radius: buttonRadius,
          child: buttonLabel(label, loading, theme.buttonTextColor),
        ),
      ),
    );
  }

  /// A flat text-only action (e.g. "Resend OTP").
  Widget textButton({required String label, required VoidCallback? onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: theme.primary,
        textStyle: linkStyle,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
      ),
      child: Text(label),
    );
  }

  /// Circular icon button used for the resend channels (SMS / WhatsApp / Call).
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
          border: Border.all(color: theme.inputBorder),
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

  /// Colour used to tint the channel/social icon images.
  Color get iconTint => theme.primary;

  /// Full-width social login button ("Continue with Google").
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
          color: theme.socialButtonColor,
          borderRadius: BorderRadius.circular(buttonRadius),
          border: Border.all(color: theme.socialButtonBorderColor),
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

  /// Compact social button (icon only) used when there are many providers.
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
          color: theme.socialButtonColor,
          borderRadius: BorderRadius.circular(buttonRadius),
          border: Border.all(color: theme.socialButtonBorderColor),
        ),
        alignment: Alignment.center,
        child: SizedBox(width: 22, height: 22, child: icon),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip, child: child);
  }

  /// Round "back" control in the card's top-left corner (the web widget's
  /// back button). Leaves the OTP screen so the identity can be changed.
  Widget backButton(VoidCallback onTap) => circleIconButton(
    icon: const Icon(Icons.arrow_back_rounded),
    onTap: onTap,
    tooltip: 'Back',
    size: 34,
  );

  /// Frame around the logo (e.g. a plate in skeuomorphic style).
  Widget logoFrame(Widget logo) => logo;

  /// Thin separator used between social buttons and the OTP form.
  Widget divider(String label) {
    final line = Expanded(
      child: Divider(color: theme.onSurfaceMuted.withValues(alpha: 0.3)),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(label, style: mutedStyle),
        ),
        line,
      ],
    );
  }

  /// Progress indicator shown while a request is in flight.
  Widget progress() => SizedBox(
    width: 28,
    height: 28,
    child: CircularProgressIndicator(strokeWidth: 2.5, color: theme.primary),
  );

  // ---------------------------------------------------------------------------
  // Helpers shared by subclasses
  // ---------------------------------------------------------------------------

  @protected
  Widget buttonInk({
    required VoidCallback? onPressed,
    required double radius,
    required Widget child,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(radius),
        child: Center(child: child),
      ),
    );
  }

  @protected
  Widget buttonLabel(String label, bool loading, Color color) {
    if (loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    return Text(
      label,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
