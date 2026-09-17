import 'package:flutter/material.dart';

import '../authyo_design_style.dart';
import 'authyo_style.dart';

/// Neumorphism: every element shares one background colour and is either
/// extruded (light shadow top-left, dark shadow bottom-right) or pressed in
/// (the same shadows inverted). Buttons animate from extruded to inset while
/// held.
class NeumorphicStyle extends AuthyoStyle {
  NeumorphicStyle(super.theme);

  @override
  AuthyoDesignStyle get id => AuthyoDesignStyle.neumorphism;

  /// Base = dashboard "Widget Background" (palette default: soft grey-blue).
  /// Light / dark shadows are derived from it so any base works.
  Color get _base => theme.surface;

  Color get _light => Color.lerp(_base, Colors.white, 0.55)!;
  Color get _dark => Color.lerp(_base, const Color(0xFF5F6784), 0.30)!;

  List<BoxShadow> _raised({double d = 8, double blur = 16}) => [
    BoxShadow(color: _light, offset: Offset(-d, -d), blurRadius: blur),
    BoxShadow(
      color: _dark.withValues(alpha: 0.7),
      offset: Offset(d, d),
      blurRadius: blur,
    ),
  ];

  /// The barrier matches the base colour so the card looks carved from it.
  @override
  Color get barrierColor => _base.withValues(alpha: 0.92);

  @override
  double get cardRadius => 28;

  @override
  EdgeInsets get cardPadding => const EdgeInsets.fromLTRB(24, 16, 24, 22);

  @override
  BoxDecoration cardDecoration() => BoxDecoration(
    color: _base,
    borderRadius: BorderRadius.circular(cardRadius),
    boxShadow: _raised(d: 12, blur: 28),
  );

  Color get _ink => theme.bodyTextColor;

  @override
  TextStyle get headerStyle =>
      super.headerStyle.copyWith(color: _ink, fontWeight: FontWeight.w700);

  @override
  TextStyle get infoStyle => super.infoStyle.copyWith(color: _ink);

  @override
  TextStyle get mutedStyle =>
      super.mutedStyle.copyWith(color: _ink.withValues(alpha: 0.6));

  @override
  TextStyle get brandStyle =>
      super.brandStyle.copyWith(color: _ink.withValues(alpha: 0.6));

  @override
  Widget logoFrame(Widget logo) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    decoration: BoxDecoration(
      color: _base,
      borderRadius: BorderRadius.circular(18),
      boxShadow: _raised(d: 5, blur: 10),
    ),
    child: logo,
  );

  @override
  InputDecoration otpInputDecoration({required String hint, String? label}) {
    OutlineInputBorder none() => OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(inputRadius),
    );
    return super
        .otpInputDecoration(hint: hint, label: label)
        .copyWith(
          // The inset paints the input colour itself so its pressed-in edges
          // stay visible (the field's own fill would cover them).
          filled: false,
          border: none(),
          enabledBorder: none(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: theme.primary.withValues(alpha: 0.5),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(inputRadius),
          ),
        );
  }

  @override
  Widget decorateInput(Widget field) {
    return _NeuInset(
      base: theme.inputBackground,
      light: _light,
      dark: _dark,
      radius: inputRadius,
      child: field,
    );
  }

  @override
  double get buttonHeight => 50;

  @override
  Widget primaryButton({
    required String label,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return _NeuPressable(
      base: _base,
      light: _light,
      dark: _dark,
      radius: buttonRadius,
      height: buttonHeight,
      onTap: loading ? null : onPressed,
      child: buttonLabel(label, loading, theme.primary),
    );
  }

  @override
  Widget circleIconButton({
    required Widget icon,
    required VoidCallback? onTap,
    String? tooltip,
    double size = 54,
  }) {
    final child = _NeuPressable(
      base: _base,
      light: _light,
      dark: _dark,
      radius: size / 2,
      height: size,
      width: size,
      onTap: onTap,
      child: IconTheme(
        data: IconThemeData(color: theme.primary, size: size * 0.46),
        child: icon,
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
    return _NeuPressable(
      base: _base,
      light: _light,
      dark: _dark,
      radius: buttonRadius,
      height: 46,
      onTap: onTap,
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
                color: _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget socialIconButton({
    required Widget icon,
    required VoidCallback? onTap,
    String? tooltip,
  }) {
    final child = _NeuPressable(
      base: _base,
      light: _light,
      dark: _dark,
      radius: buttonRadius,
      height: 46,
      width: 56,
      onTap: onTap,
      child: SizedBox(width: 22, height: 22, child: icon),
    );
    return tooltip == null ? child : Tooltip(message: tooltip, child: child);
  }

  @override
  Widget divider(String label) {
    final line = Expanded(
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          color: _base,
          borderRadius: BorderRadius.circular(1),
          boxShadow: _raised(d: 1, blur: 2),
        ),
      ),
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
}

/// An inset (pressed-in) neumorphic well. Flutter has no inset box shadow,
/// so it is faked with two gradient bands painted along the inner edges.
class _NeuInset extends StatelessWidget {
  const _NeuInset({
    required this.base,
    required this.light,
    required this.dark,
    required this.radius,
    required this.child,
  });

  final Color base;
  final Color light;
  final Color dark;
  final double radius;
  final Widget child;

  /// Mirror of the raised look: dark along the top + left edges, light along
  /// the bottom + right edges, each a fixed 9px edge gradient — the web
  /// widget's `linear-gradient(..., transparent 9px)` — clipped by the shape.
  static const double _edgeSize = 9;

  Widget _edge({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required Alignment begin,
    required Alignment end,
    required Color c,
  }) => Positioned(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    width: (left != null && right != null) ? null : _edgeSize,
    height: (top != null && bottom != null) ? null : _edgeSize,
    child: IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            // Fade to the same hue at alpha 0 (not transparent black):
            // Impeller would otherwise darken the fade mid-way.
            colors: [c, c.withValues(alpha: 0)],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    // Same alphas as the web widget's pressed() gradients.
    final dk = dark.withValues(alpha: 0.55);
    final lt = light.withValues(alpha: 0.75);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: base)),
          _edge(
            top: 0,
            left: 0,
            right: 0,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            c: dk,
          ),
          _edge(
            top: 0,
            bottom: 0,
            left: 0,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            c: dk,
          ),
          _edge(
            bottom: 0,
            left: 0,
            right: 0,
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            c: lt,
          ),
          _edge(
            top: 0,
            bottom: 0,
            right: 0,
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            c: lt,
          ),
          child,
        ],
      ),
    );
  }
}

/// Extruded surface that sinks in while pressed.
class _NeuPressable extends StatefulWidget {
  const _NeuPressable({
    required this.base,
    required this.light,
    required this.dark,
    required this.radius,
    required this.height,
    required this.onTap,
    required this.child,
    this.width,
  });

  final Color base;
  final Color light;
  final Color dark;
  final double radius;
  final double height;
  final double? width;
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<_NeuPressable> createState() => _NeuPressableState();
}

class _NeuPressableState extends State<_NeuPressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final raised = !_down;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _down = true) : null,
      onTapUp: enabled ? (_) => setState(() => _down = false) : null,
      onTapCancel: enabled ? () => setState(() => _down = false) : null,
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        height: widget.height,
        width: widget.width ?? double.infinity,
        decoration: BoxDecoration(
          color: widget.base,
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: raised
              ? [
                  BoxShadow(
                    color: widget.light,
                    offset: const Offset(-6, -6),
                    blurRadius: 12,
                  ),
                  BoxShadow(
                    color: widget.dark.withValues(alpha: 0.7),
                    offset: const Offset(6, 6),
                    blurRadius: 12,
                  ),
                ]
              : const [],
        ),
        child: raised
            ? Center(child: widget.child)
            : _NeuInset(
                base: widget.base,
                light: widget.light,
                dark: widget.dark,
                radius: widget.radius,
                child: Center(child: widget.child),
              ),
      ),
    );
  }
}
