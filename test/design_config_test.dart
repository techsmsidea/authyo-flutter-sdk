import 'package:authyo_plugin/authyo_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthyoDesignStyle.fromValue', () {
    test('maps backend ints', () {
      expect(AuthyoDesignStyle.fromValue(1), AuthyoDesignStyle.flat);
      expect(AuthyoDesignStyle.fromValue(6), AuthyoDesignStyle.glassmorphism);
      expect(AuthyoDesignStyle.fromValue('7'), AuthyoDesignStyle.neumorphism);
    });

    test('maps keys and names case-insensitively', () {
      expect(
        AuthyoDesignStyle.fromValue('Claymorphism'),
        AuthyoDesignStyle.claymorphism,
      );
      expect(AuthyoDesignStyle.fromValue('FLAT2'), AuthyoDesignStyle.flat2);
    });

    test('falls back to flat for unknown / null', () {
      expect(AuthyoDesignStyle.fromValue(null), AuthyoDesignStyle.flat);
      expect(AuthyoDesignStyle.fromValue(99), AuthyoDesignStyle.flat);
      expect(AuthyoDesignStyle.fromValue('brutalism'), AuthyoDesignStyle.flat);
    });
  });

  group('AuthyoTheme.parseColor', () {
    test('parses hex forms', () {
      expect(AuthyoTheme.parseColor('#2D398F'), const Color(0xFF2D398F));
      expect(AuthyoTheme.parseColor('2d398f'), const Color(0xFF2D398F));
      expect(AuthyoTheme.parseColor('#802D398F'), const Color(0x802D398F));
      expect(AuthyoTheme.parseColor('#fff'), const Color(0xFFFFFFFF));
    });

    test('parses rgb()/rgba()', () {
      expect(
        AuthyoTheme.parseColor('rgb(45, 57, 143)'),
        const Color(0xFF2D398F),
      );
      expect(
        AuthyoTheme.parseColor('rgba(255,255,255,0.5)'),
        const Color(0x80FFFFFF),
      );
    });

    test('returns null on junk', () {
      expect(AuthyoTheme.parseColor(''), isNull);
      expect(AuthyoTheme.parseColor('blue'), isNull);
      expect(AuthyoTheme.parseColor(null), isNull);
    });
  });

  group('AuthyoTheme', () {
    test('fromCustomization maps dashboard keys', () {
      final t = AuthyoTheme.fromCustomization({
        'buttonColor': '#112233',
        'buttonTextColor': '#ffffff',
        'inputBackground': '#f0f0f0',
        'buttonStyle': 2,
        'mainLayout': 1,
        'socialMediaLayout': 1,
        'hideBranding': true,
        'resendButtonTimer': 120,
        'isLogo': false,
        'logoUrl': 'https://cdn/logo.png',
        'headerText': 'Hello',
        'isHeader': true,
      });
      expect(t.primary, const Color(0xFF112233));
      expect(t.buttonShape, AuthyoButtonShape.rounded);
      expect(t.mainLayout, AuthyoMainLayout.left);
      expect(t.socialLayout, AuthyoSocialLayout.top);
      expect(t.hideBranding, isTrue);
      expect(t.resendTimerSeconds, 120);
      expect(t.showLogo, isFalse);
      expect(t.logoUrl, 'https://cdn/logo.png');
      expect(t.headerText, 'Hello');
      expect(t.showHeader, isTrue);
      // untouched keys stay null so defaults win on merge
      expect(t.surface, isNull);
    });

    test('merge: later non-null wins, nulls fall through', () {
      const remote = AuthyoTheme(
        primary: Color(0xFF111111),
        hideBranding: true,
      );
      const local = AuthyoTheme(primary: Color(0xFF222222));
      final merged = AuthyoTheme.defaults.merge(remote).merge(local);
      expect(merged.primary, const Color(0xFF222222));
      expect(merged.hideBranding, isTrue);
      expect(merged.surface, AuthyoTheme.defaults.surface);
    });

    test('resolve never yields nulls and guards timer', () {
      final r = const AuthyoTheme(resendTimerSeconds: 0).resolve();
      expect(r.resendTimerSeconds, 60);
      expect(r.primary, AuthyoTheme.defaults.primary);
    });
  });

  group('AuthyoWidgetConfig.fromJson', () {
    test('parses the mobileconfig shape', () {
      final cfg = AuthyoWidgetConfig.fromJson({
        'success': true,
        'data': {
          'authMethods': ['Sms', 'Whatsapp', 'Email'],
          'socialLogins': [
            {'provider': 'Google', 'id': 12},
            {'provider': 'Github', 'id': '13'},
          ],
          'customization': {'buttonColor': '#abcdef', 'designStyle': 6},
          'otpLength': 4,
        },
      });
      expect(cfg.designStyle, AuthyoDesignStyle.glassmorphism);
      expect(cfg.authMethods, ['Sms', 'Whatsapp', 'Email']);
      expect(cfg.socialLogins.length, 2);
      expect(cfg.socialLogins.first.provider, AuthyoSocialProvider.google);
      expect(cfg.socialLogins.first.id, '12');
      expect(cfg.socialLogins.last.provider, AuthyoSocialProvider.github);
      expect(cfg.theme.buttonColor, const Color(0xFFABCDEF));
      expect(cfg.otpLength, 4);
    });

    test('parses the legacy CDN shape (results + appCustomizationModel)', () {
      final cfg = AuthyoWidgetConfig.fromJson({
        'success': true,
        'data': {
          'results': ['Sms', 'Email', 'Google,123', 'GoogleOneTap,5*cid'],
          'appCustomizationModel': {'buttonStyle': 3},
          'otpLength': 6,
        },
      });
      expect(cfg.designStyle, isNull);
      expect(cfg.authMethods, ['Sms', 'Email']);
      expect(cfg.socialLogins.map((s) => s.id), ['123']);
      expect(cfg.theme.buttonShape, AuthyoButtonShape.pill);
    });

    test('parses a bare AppCustomizationModel', () {
      final cfg = AuthyoWidgetConfig.fromJson({
        'success': true,
        'data': {'buttonColor': '#000000', 'hideBranding': true},
      });
      expect(cfg.theme.hideBranding, isTrue);
      expect(cfg.socialLogins, isEmpty);
    });
  });

  group('AuthyoService.parseSocialCallback', () {
    const login = AuthyoSocialLogin(
      provider: AuthyoSocialProvider.google,
      id: '1',
    );

    test('success carries token and email', () {
      final r = AuthyoService.parseSocialCallback(
        'authyo://oauth/callback?success=true&token=abc.def&email=a%40b.com',
        login,
      );
      expect(r.error, isNull);
      expect(r.result?.data?.token, 'abc.def');
      expect(r.result?.data?.user?.email, 'a@b.com');
      expect(r.result?.data?.user?.channel, 'google');
    });

    test('failure surfaces the message', () {
      final r = AuthyoService.parseSocialCallback(
        'authyo://oauth/callback?success=false&message=Token%20exchange%20failed',
        login,
      );
      expect(r.result, isNull);
      expect(r.error?.message, 'Token exchange failed');
    });
  });
}
