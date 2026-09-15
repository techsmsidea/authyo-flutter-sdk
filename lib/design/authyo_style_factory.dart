import 'authyo_design_style.dart';
import 'authyo_theme.dart';
import 'styles/authyo_style.dart';
import 'styles/clay_style.dart';
import 'styles/flat2_style.dart';
import 'styles/flat_style.dart';
import 'styles/glass_style.dart';
import 'styles/minimal_style.dart';
import 'styles/neumorphic_style.dart';
import 'styles/skeuomorphic_style.dart';

/// Creates the renderer for a given [AuthyoDesignStyle].
class AuthyoStyleFactory {
  AuthyoStyleFactory._();

  static AuthyoStyle create(AuthyoDesignStyle style, AuthyoTheme theme) {
    final resolved = theme.resolve();
    switch (style) {
      case AuthyoDesignStyle.flat:
        return FlatStyle(resolved);
      case AuthyoDesignStyle.flat2:
        return Flat2Style(resolved);
      case AuthyoDesignStyle.minimalism:
        return MinimalStyle(resolved);
      case AuthyoDesignStyle.skeuomorphism:
        return SkeuomorphicStyle(resolved);
      case AuthyoDesignStyle.claymorphism:
        return ClayStyle(resolved);
      case AuthyoDesignStyle.glassmorphism:
        return GlassStyle(resolved);
      case AuthyoDesignStyle.neumorphism:
        return NeumorphicStyle(resolved);
    }
  }
}
