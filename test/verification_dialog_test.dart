import 'package:authyo_plugin/authyo_plugin.dart';
import 'package:authyo_plugin/design/authyo_style_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Send result as the API returns it. [expirySeconds] mirrors the
/// `createdTime` / `expireTime` pair the web widget counts down from.
AuthyoResult _sentResult({int? expirySeconds}) => AuthyoResult.success(
  AuthyoResponseModel(
    success: true,
    message: 'sent',
    data: Data(
      results: [
        Results(
          success: true,
          maskId: 'MASK-1',
          to: '+911234567890',
          createdTime: expirySeconds == null ? null : 1000,
          expiretime: expirySeconds == null ? null : 1000 + expirySeconds,
        ),
      ],
    ),
  ),
);

Widget _host(Widget dialog) => MaterialApp(
  home: Scaffold(body: Builder(builder: (_) => dialog)),
);

/// Verifies any code without touching the network.
class _FakeService extends AuthyoService {
  _FakeService() : super.forTesting();
  String? verifiedOtp;
  bool? verifiedRememberMe;

  @override
  Future<AuthyoResult> verifyOtp({
    required String maskId,
    required String otp,
    bool rememberMe = false,
  }) async {
    verifiedOtp = otp;
    verifiedRememberMe = rememberMe;
    return AuthyoResult.success(
      AuthyoResponseModel(success: true, message: 'verified successfully'),
    );
  }
}

const _fourSocials = [
  AuthyoSocialLogin(provider: AuthyoSocialProvider.google, id: '1'),
  AuthyoSocialLogin(provider: AuthyoSocialProvider.microsoft, id: '2'),
  AuthyoSocialLogin(provider: AuthyoSocialProvider.github, id: '3'),
  AuthyoSocialLogin(provider: AuthyoSocialProvider.linkedin, id: '4'),
];

Finder _otpBoxes() => find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.counterText == '',
);

/// Button label, case-insensitive (Minimalism upper-cases its buttons).
Finder _label(String text) => find.byWidgetPredicate(
  (w) => w is Text && w.data?.toLowerCase() == text.toLowerCase(),
);

void main() {
  for (final style in AuthyoDesignStyle.values) {
    testWidgets('renders ${style.label} dialog like the web widget', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          PhoneVerificationDialog(
            authyoRes: _sentResult(expirySeconds: 120),
            to: '+911234567890',
            style: AuthyoStyleFactory.create(style, AuthyoTheme.defaults),
            config: const AuthyoWidgetConfig(
              authMethods: ['Sms', 'Whatsapp'],
              socialLogins: [
                AuthyoSocialLogin(
                  provider: AuthyoSocialProvider.google,
                  id: '1',
                ),
              ],
            ),
            otpLength: 6,
          ),
        ),
      );
      await tester.pump();

      // Same slots as the web widget's OTP screen.
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(find.textContaining('OTP sent to: '), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is Text && (w.data?.toLowerCase() == 'verify otp'),
        ),
        findsOneWidget,
      );
      expect(_otpBoxes(), findsNWidgets(6));
      // No visible Verify button: the last digit verifies, like the widget.
      expect(find.text('Verify OTP'), findsOneWidget); // the heading only
      expect(find.text('OTP will expire in 2:00'), findsOneWidget);
      expect(find.byTooltip('Google'), findsOneWidget);
      expect(find.text('OR'), findsOneWidget);
      expect(find.textContaining('By signing in'), findsOneWidget);
      expect(find.textContaining('XXXXXXXX7890'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('countdown follows the server expiry, not the resend timer', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        PhoneVerificationDialog(
          authyoRes: _sentResult(expirySeconds: 90),
          to: '+911234567890',
          style: AuthyoStyleFactory.create(
            AuthyoDesignStyle.flat,
            const AuthyoTheme(resendTimerSeconds: 30),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('OTP will expire in 1:30'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('OTP will expire in 1:29'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('phone: expiry shows red notice and one button per channel', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        PhoneVerificationDialog(
          authyoRes: _sentResult(expirySeconds: 2),
          to: '+911234567890',
          style: AuthyoStyleFactory.create(
            AuthyoDesignStyle.flat,
            AuthyoTheme.defaults,
          ),
          config: const AuthyoWidgetConfig(
            authMethods: ['Sms', 'Whatsapp', 'VoiceCall', 'Email'],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(_label('Sms'), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    expect(
      find.text('OTP expired. Please select your way to receive otp.'),
      findsOneWidget,
    );
    // Same labels as the web widget, email excluded for a phone target.
    expect(_label('Sms'), findsOneWidget);
    expect(_label('Whatsapp'), findsOneWidget);
    expect(_label('VoiceCall'), findsOneWidget);
    expect(_label('Resend'), findsNothing);
    expect(find.textContaining('OTP will expire'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('email: expiry shows a single Resend button', (tester) async {
    await tester.pumpWidget(
      _host(
        PhoneVerificationDialog(
          authyoRes: _sentResult(),
          to: 'jasmin@example.com',
          style: AuthyoStyleFactory.create(
            AuthyoDesignStyle.minimalism,
            const AuthyoTheme(resendTimerSeconds: 1),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('jasmiX@example.com'), findsOneWidget);
    // No server expiry in the reply -> falls back to the dashboard timer.
    expect(find.text('OTP will expire in 0:01'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(
      find.text('OTP expired. Please click resend button to receive otp.'),
      findsOneWidget,
    );
    expect(_label('Resend'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('OTP boxes auto-advance, paste fills all, backspace goes back', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        PhoneVerificationDialog(
          authyoRes: _sentResult(expirySeconds: 120),
          to: '+911234567890',
          otpLength: 4,
        ),
      ),
    );
    await tester.pump();
    final boxes = _otpBoxes();
    expect(boxes, findsNWidgets(4));

    await tester.enterText(boxes.at(0), '1');
    await tester.pump();
    expect(tester.widget<TextField>(boxes.at(0)).controller!.text, '1');
    expect(tester.widget<TextField>(boxes.at(1)).focusNode!.hasFocus, isTrue);

    // Pasting a partial code spreads it from the focused box on.
    await tester.enterText(boxes.at(1), '23');
    await tester.pump();
    expect(tester.widget<TextField>(boxes.at(1)).controller!.text, '2');
    expect(tester.widget<TextField>(boxes.at(2)).controller!.text, '3');
    expect(tester.widget<TextField>(boxes.at(3)).focusNode!.hasFocus, isTrue);

    // Backspace on an empty box clears the previous one and moves back.
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();
    expect(tester.widget<TextField>(boxes.at(2)).controller!.text, '');
    expect(tester.widget<TextField>(boxes.at(2)).focusNode!.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'last digit verifies, shows the badge in the card, then closes and reports',
    (tester) async {
      final service = _FakeService();
      AuthyoResult? reported;
      var opened = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                if (!opened) {
                  opened = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    showDialog<void>(
                      context: context,
                      builder: (_) => PhoneVerificationDialog(
                        authyoRes: _sentResult(expirySeconds: 120),
                        to: '+911234567890',
                        otpLength: 4,
                        service: service,
                        verifiedDisplayDuration: const Duration(seconds: 1),
                        onVerificationComplete: (r) => reported = r,
                        config: const AuthyoWidgetConfig(
                          socialLogins: _fourSocials,
                        ),
                      ),
                    );
                  });
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      final boxes = _otpBoxes();
      expect(boxes, findsNWidgets(4));
      await tester.enterText(boxes.at(0), '1234');
      await tester.pump();
      await tester.pump();

      // Verified: badge in the card, no boxes / timer / socials / Change.
      expect(service.verifiedOtp, '1234');
      expect(find.text('Verified successfully'), findsOneWidget);
      expect(_otpBoxes(), findsNothing);
      expect(find.textContaining('OTP will expire'), findsNothing);
      expect(find.byTooltip('Google'), findsNothing);
      expect(find.text('Change'), findsNothing);
      expect(find.textContaining('OTP sent to: '), findsOneWidget);
      expect(reported, isNull);
      expect(tester.takeException(), isNull);

      // ...then the dialog closes and the host is told.
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Verified successfully'), findsNothing);
      expect(reported?.result?.message, 'verified successfully');
    },
  );

  group('remember me', () {
    const key = 'authyo_remember_';
    Widget host(
      _FakeService service, {
      required bool enabled,
      bool pre = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PhoneVerificationDialog(
            authyoRes: _sentResult(expirySeconds: 120),
            to: '+911234567890',
            otpLength: 4,
            service: service,
            verifiedDisplayDuration: const Duration(minutes: 1),
            style: AuthyoStyleFactory.create(
              AuthyoDesignStyle.flat,
              AuthyoTheme(rememberMe: enabled),
            ),
          ),
        ),
      );
    }

    testWidgets(
      'off: no checkbox, flag false, nothing stored, stale value dropped',
      (tester) async {
        SharedPreferences.setMockInitialValues({key: 'stale@example.com'});
        final service = _FakeService();
        await tester.pumpWidget(host(service, enabled: false));
        await tester.pump();
        expect(find.text('Remember me'), findsNothing);
        await tester.enterText(_otpBoxes().first, '1234');
        await tester.pump();
        await tester.pump();
        expect(service.verifiedRememberMe, isFalse);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(key), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('on but unticked: flag false and nothing stored', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final service = _FakeService();
      await tester.pumpWidget(host(service, enabled: true));
      await tester.pump();
      expect(find.text('Remember me'), findsOneWidget);
      await tester.enterText(_otpBoxes().first, '1234');
      await tester.pump();
      await tester.pump();
      expect(service.verifiedRememberMe, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(key), isNull);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'on and ticked: flag true, identity stored, pre-ticked next time',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final service = _FakeService();
        await tester.pumpWidget(host(service, enabled: true));
        await tester.pump();
        await tester.tap(find.text('Remember me'));
        await tester.pump();
        expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
        await tester.enterText(_otpBoxes().first, '1234');
        await tester.pump();
        await tester.pump();
        expect(service.verifiedRememberMe, isTrue);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString(key), '+911234567890');
        await tester.pumpWidget(const SizedBox());

        // Next dialog for the same identity starts ticked.
        await tester.pumpWidget(host(_FakeService(), enabled: true));
        await tester.pump();
        await tester.pump();
        expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
        await tester.pumpWidget(const SizedBox());
      },
    );
  });

  testWidgets('hideBranding removes footer and header shows when enabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        PhoneVerificationDialog(
          authyoRes: _sentResult(),
          to: '+911234567890',
          style: AuthyoStyleFactory.create(
            AuthyoDesignStyle.flat2,
            const AuthyoTheme(
              hideBranding: true,
              showHeader: true,
              headerText: 'Welcome back',
              resendTimerSeconds: 1,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('Powered by'), findsNothing);
    expect(find.textContaining('By signing in'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox());
  });

  // Busiest possible card: four social icon buttons (top and bottom
  // placement), three resend buttons after expiry, underline inputs and
  // the smallest phone width. Every style must lay it out without a
  // RenderFlex overflow or any other exception.
  for (final style in AuthyoDesignStyle.values) {
    for (final layout in AuthyoSocialLayout.values) {
      testWidgets(
        '${style.label} keeps layout with socials ($layout) + resend',
        (tester) async {
          tester.view.physicalSize = const Size(320, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            _host(
              PhoneVerificationDialog(
                authyoRes: _sentResult(expirySeconds: 1),
                to: '+911234567890',
                style: AuthyoStyleFactory.create(
                  style,
                  AuthyoTheme(
                    socialLayout: layout,
                    inputUnderline: style == AuthyoDesignStyle.minimalism,
                    glassOpacity: 0.4,
                    otpHidden: true,
                  ),
                ),
                config: const AuthyoWidgetConfig(
                  authMethods: ['Sms', 'Whatsapp', 'VoiceCall', 'Email'],
                  socialLogins: _fourSocials,
                ),
                otpLength: 6,
              ),
            ),
          );
          await tester.pump();
          expect(find.byTooltip('Google'), findsOneWidget);
          expect(find.byTooltip('LinkedIn'), findsOneWidget);
          expect(_otpBoxes(), findsNWidgets(6));
          expect(tester.takeException(), isNull);

          await tester.pump(const Duration(seconds: 2));
          expect(_label('Sms'), findsOneWidget);
          expect(_label('Whatsapp'), findsOneWidget);
          expect(_label('VoiceCall'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
