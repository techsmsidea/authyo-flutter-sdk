import '../authyo_design_style.dart';
import 'authyo_style.dart';

/// Flat design: solid colours, no shadows, crisp 1px borders.
///
/// This is the base look implemented by [AuthyoStyle] itself and matches the
/// dialog shipped in 1.0.x, so it is the safe default.
class FlatStyle extends AuthyoStyle {
  FlatStyle(super.theme);

  @override
  AuthyoDesignStyle get id => AuthyoDesignStyle.flat;
}
