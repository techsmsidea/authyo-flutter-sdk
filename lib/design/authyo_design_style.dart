/// The visual design language used by the built-in verification dialog.
///
/// The integer values mirror the `designStyle` column stored in the Authyo
/// dashboard customization (`appcustomization.designstyle`), so the value
/// returned by the remote config can be mapped directly with [fromValue].
enum AuthyoDesignStyle {
  /// Solid colours, no shadows, small radius. This is the default and matches
  /// the look of the dialog shipped in 1.0.x.
  flat(1, 'flat'),

  /// Flat with subtle elevation and depth cues.
  flat2(2, 'flat2'),

  /// Monochrome, typography-driven, maximum whitespace.
  minimalism(3, 'minimalism'),

  /// Glossy gradients, bevels and realistic depth.
  skeuomorphism(4, 'skeuomorphism'),

  /// Pastel, puffy, large-radius "clay" surfaces.
  claymorphism(5, 'claymorphism'),

  /// Translucent frosted-glass panels over a blurred backdrop.
  glassmorphism(6, 'glassmorphism'),

  /// Soft extruded/inset surfaces on a single background colour.
  neumorphism(7, 'neumorphism');

  /// Numeric id as stored in the Authyo backend.
  final int value;

  /// Stable string id (used in JSON and in the example app).
  final String key;

  const AuthyoDesignStyle(this.value, this.key);

  /// Resolves a style from an `int`, a numeric string or a key such as
  /// `"glassmorphism"`. Unknown or null values fall back to [flat] so that an
  /// older SDK keeps working when a new style is added on the server.
  static AuthyoDesignStyle fromValue(Object? raw) {
    if (raw == null) return AuthyoDesignStyle.flat;
    if (raw is AuthyoDesignStyle) return raw;
    if (raw is int) {
      return AuthyoDesignStyle.values.firstWhere(
        (s) => s.value == raw,
        orElse: () => AuthyoDesignStyle.flat,
      );
    }
    final text = raw.toString().trim().toLowerCase();
    final asInt = int.tryParse(text);
    if (asInt != null) return fromValue(asInt);
    return AuthyoDesignStyle.values.firstWhere(
      (s) => s.key == text || s.name.toLowerCase() == text,
      orElse: () => AuthyoDesignStyle.flat,
    );
  }

  /// Human readable label for pickers / debugging.
  String get label {
    switch (this) {
      case AuthyoDesignStyle.flat:
        return 'Flat';
      case AuthyoDesignStyle.flat2:
        return 'Flat 2.0';
      case AuthyoDesignStyle.minimalism:
        return 'Minimalism';
      case AuthyoDesignStyle.skeuomorphism:
        return 'Skeuomorphism';
      case AuthyoDesignStyle.claymorphism:
        return 'Claymorphism';
      case AuthyoDesignStyle.glassmorphism:
        return 'Glassmorphism';
      case AuthyoDesignStyle.neumorphism:
        return 'Neumorphism';
    }
  }
}
