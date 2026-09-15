import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../authyo_plugin.dart';
import '../design/authyo_style_factory.dart';
import 'verification_controller.dart';

/// The built-in OTP verification dialog.
///
/// Mirrors the web widget's OTP screen slot for slot: back button, logo,
/// header / body text, "OTP sent to … Change", "Verify OTP", one box per
/// digit (auto-advance, auto-verify on the last digit), the expiry
/// countdown that turns into the resend buttons, social logins, the
/// verified badge, terms / privacy and branding. Every design style draws
/// the same slots differently.
///
/// Usually shown for you by `AuthyoService.sendOtp`. To show it manually use
/// `AuthyoService.instance.showVerificationDialog(...)`.
class PhoneVerificationDialog extends StatefulWidget {
  const PhoneVerificationDialog({
    super.key,
    required this.authyoRes,
    required this.to,
    this.onVerificationComplete,
    this.style,
    this.config = AuthyoWidgetConfig.empty,
    this.otpLength,
    this.verifiedDisplayDuration = const Duration(milliseconds: 1600),
    @visibleForTesting this.service,
  });

  /// Result of the `sendOtp` call that opened this dialog (carries `maskId`
  /// and the OTP expiry used for the countdown).
  final AuthyoResult authyoRes;

  /// Phone number or email the OTP was sent to.
  final String to;

  /// Called after a successful or failed verification, with the result.
  /// On success it fires after the "Verified successfully" badge has been
  /// shown and the dialog has closed.
  final void Function(AuthyoResult authyoResult)? onVerificationComplete;

  /// Renderer to use. Defaults to Flat with the default theme.
  final AuthyoStyle? style;

  /// Remote config (channels, social logins). Empty by default.
  final AuthyoWidgetConfig config;

  /// Expected OTP length (number of digit boxes). Defaults to 6.
  final int? otpLength;

  /// How long the success badge stays before the dialog closes.
  final Duration verifiedDisplayDuration;

  /// Test seam: service used for verify / resend / social calls.
  final AuthyoService? service;

  @override
  State<PhoneVerificationDialog> createState() =>
      _PhoneVerificationDialogState();
}

/// Alias with a clearer name; identical to [PhoneVerificationDialog].
typedef AuthyoVerificationDialog = PhoneVerificationDialog;

class _PhoneVerificationDialogState extends State<PhoneVerificationDialog> {
  late final AuthyoStyle _style;
  late final VerificationController _c;
  final _boxesKey = GlobalKey<_OtpBoxesState>();
  String? _shownMessage;
  Timer? _closeTimer;

  AuthyoResolvedTheme get _t => _style.theme;
  int get _digits => widget.otpLength ?? 6;

  @override
  void initState() {
    super.initState();
    _style =
        widget.style ??
        AuthyoStyleFactory.create(AuthyoDesignStyle.flat, AuthyoTheme.defaults);
    _c = VerificationController(
      to: widget.to,
      sendResult: widget.authyoRes,
      resendTimerSeconds: _t.resendTimerConfigured,
      config: widget.config,
      otpLength: widget.otpLength,
      rememberMeEnabled: _t.rememberMeEnabled,
      service: widget.service,
    );
    _c.addListener(_onControllerChanged);
    _c.start();
    // Pre-tick "Remember me" when this identity was remembered last time
    // (the web widget does the same when it prefills the form).
    if (_t.rememberMeEnabled) {
      (widget.service ?? AuthyoService.instance).rememberedIdentity().then((
        remembered,
      ) {
        if (!mounted || remembered == null || remembered != widget.to) return;
        setState(() => _c.rememberMe = true);
      });
    }
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final msg = _c.errorMessage ?? _c.infoMessage;
    if (msg != null && msg != _shownMessage) {
      _shownMessage = msg;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text(_c.errorMessage != null ? 'Oops! $msg' : msg),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (_c.completed != null && _closeTimer == null) {
      // Show the verified badge in the card (like the web widget), then
      // close and report.
      final result = _c.completed!;
      _c.completed = null;
      FocusScope.of(context).unfocus();
      _closeTimer = Timer(widget.verifiedDisplayDuration, () {
        if (!mounted) return;
        Navigator.of(context).pop();
        widget.onVerificationComplete?.call(result);
      });
    }
    setState(() {});
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _c.removeListener(_onControllerChanged);
    _c.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    if (_c.isLoading || _c.verified) return;
    _c.otp = code;
    FocusScope.of(context).unfocus();
    final res = await _c.verify();
    if (res.error != null) {
      _boxesKey.currentState?.clear();
      widget.onVerificationComplete?.call(res);
    }
  }

  Future<void> _resend(AuthwayEnum channel) async {
    _boxesKey.currentState?.clear();
    await _c.resend(channel);
  }

  Future<void> _social(AuthyoSocialLogin login) async {
    final res = await _c.social(login);
    if (res.error != null && res.error!.code != 0) {
      widget.onVerificationComplete?.call(res);
    }
  }

  /// Back / Change: leave the OTP screen so the host can change the identity.
  void _back() => Navigator.of(context).pop();

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final width = math.min(MediaQuery.sizeOf(context).width * 0.88, 400.0);
    final card = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: DecoratedBox(
        decoration: _style.cardDecoration(),
        child: Padding(padding: _style.cardPadding, child: _content()),
      ),
    );

    // Centred, and scrollable when the keyboard leaves too little room.
    final dialog = SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: MediaQuery.viewInsetsOf(context),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: _style.decorateCard(card),
          ),
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: _style.backdrop(context, dialog),
    );
  }

  Widget _content() {
    final layout = _t.mainLayout;
    final socialsTop = _t.socialLayout == AuthyoSocialLayout.top;
    final hasSocial = _c.socialLogins.isNotEmpty && !_c.verified;

    return DefaultTextStyle.merge(
      style: TextStyle(fontFamily: _style.fontFamily),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: layout.crossAxis,
        children: [
          // Web widget: round back button pinned to the top-left corner.
          if (!_c.verified)
            Align(
              alignment: Alignment.centerLeft,
              child: _style.backButton(_back),
            ),
          if (_t.showLogo) ...[
            Align(
              alignment: _alignmentFor(layout),
              child: _style.logoFrame(_logo()),
            ),
            const SizedBox(height: 14),
          ],
          if (_t.showHeader && _t.headerText.isNotEmpty) ...[
            Text(
              _t.headerText,
              style: _style.headerStyle,
              textAlign: layout.textAlign,
            ),
            const SizedBox(height: 8),
          ],
          // "OTP sent to: … Change" replaces the body text once the OTP is
          // out (the web widget hides "Change" once verified).
          _style.sentToRow(
            target: _c.maskedTarget,
            onChange: _c.verified ? null : _back,
          ),
          const SizedBox(height: 14),
          if (hasSocial && socialsTop) ...[
            _socialSection(),
            const SizedBox(height: 14),
          ],
          if (_c.verified)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: _style.verifiedBadge()),
            )
          else ...[
            Text(
              'Verify OTP',
              style: _style.headerStyle.copyWith(fontSize: 16),
              textAlign: layout.textAlign,
            ),
            const SizedBox(height: 12),
            if (_c.isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(child: _style.progress()),
              )
            else ...[
              _OtpBoxes(
                key: _boxesKey,
                style: _style,
                length: _digits,
                alignment: _wrapAlignmentFor(layout),
                onCompleted: _verify,
              ),
              if (_t.rememberMeEnabled) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: _alignmentFor(layout),
                  child: _style.checkbox(
                    label: 'Remember me',
                    value: _c.rememberMe,
                    onChanged: (v) => setState(() => _c.rememberMe = v),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              _timerSection(layout),
            ],
          ],
          if (hasSocial && !socialsTop) ...[
            const SizedBox(height: 14),
            _style.divider('OR'),
            const SizedBox(height: 14),
            _socialSection(),
          ],
          const SizedBox(height: 18),
          _footer(),
        ],
      ),
    );
  }

  /// Countdown while the OTP is valid; once expired, the red notice and the
  /// resend buttons (one per channel for phones, "Resend" for email).
  Widget _timerSection(AuthyoMainLayout layout) {
    if (!_c.canResend) {
      return _style.statusText(
        'OTP will expire in ${_c.countdownLabel}',
        align: layout.textAlign,
      );
    }
    final channels = _c.resendChannels;
    final single = _c.isEmail || channels.length <= 1;
    return Column(
      crossAxisAlignment: layout.crossAxis,
      children: [
        _style.statusText(
          single
              ? 'OTP expired. Please click resend button to receive otp.'
              : 'OTP expired. Please select your way to receive otp.',
          error: true,
          align: layout.textAlign,
        ),
        const SizedBox(height: 10),
        if (single)
          _style.primaryButton(
            label: 'Resend',
            onPressed: channels.isEmpty ? null : () => _resend(channels.first),
          )
        else
          for (var i = 0; i < channels.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _style.primaryButton(
              label: _channelLabel(channels[i]),
              onPressed: () => _resend(channels[i]),
            ),
          ],
      ],
    );
  }

  /// Same labels the web widget puts on its resend buttons.
  String _channelLabel(AuthwayEnum c) {
    switch (c) {
      case AuthwayEnum.sms:
        return 'Sms';
      case AuthwayEnum.whatsapp:
        return 'Whatsapp';
      case AuthwayEnum.voiceCall:
        return 'VoiceCall';
      case AuthwayEnum.email:
        return 'Resend';
    }
  }

  /// Social providers as a row of icon buttons (the web widget's layout).
  Widget _socialSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        for (final s in _c.socialLogins)
          _style.socialIconButton(
            tooltip: s.provider.label,
            icon: _ProviderGlyph(s),
            onTap: _c.isLoading || _c.verified ? null : () => _social(s),
          ),
      ],
    );
  }

  Widget _footer() {
    final muted = _style.brandStyle;
    final link = muted.copyWith(
      decoration: TextDecoration.underline,
      decorationColor: muted.color,
    );
    TapGestureRecognizer? open(String? url) {
      if (url == null || url.isEmpty) return null;
      return TapGestureRecognizer()
        ..onTap = () {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        };
    }

    return Column(
      children: [
        Text.rich(
          TextSpan(
            text: 'By signing in, you agree to ',
            style: muted,
            children: [
              TextSpan(
                text: 'Terms',
                style: link,
                recognizer: open(_t.termsLink),
              ),
              const TextSpan(text: ' & '),
              TextSpan(
                text: 'Privacy Policy',
                style: link,
                recognizer: open(_t.privacyLink),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        if (!_t.hideBranding) ...[
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              text: 'Powered by ',
              style: muted,
              children: [
                TextSpan(
                  text: 'Authyo',
                  style: muted.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Alignment _alignmentFor(AuthyoMainLayout l) {
    switch (l) {
      case AuthyoMainLayout.left:
        return Alignment.centerLeft;
      case AuthyoMainLayout.center:
        return Alignment.center;
      case AuthyoMainLayout.right:
        return Alignment.centerRight;
    }
  }

  WrapAlignment _wrapAlignmentFor(AuthyoMainLayout l) {
    switch (l) {
      case AuthyoMainLayout.left:
        return WrapAlignment.start;
      case AuthyoMainLayout.center:
        return WrapAlignment.center;
      case AuthyoMainLayout.right:
        return WrapAlignment.end;
    }
  }

  Widget _logo() {
    const fallback = AssetImage('packages/authyo_plugin/res/authyo-logo.png');
    final provider =
        _t.logo ??
        (_t.logoUrl != null && _t.logoUrl!.startsWith('http')
            ? NetworkImage(_t.logoUrl!) as ImageProvider
            : fallback);
    return Image(
      image: provider,
      height: 44,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          const Image(image: fallback, height: 44, fit: BoxFit.contain),
    );
  }
}

/// One text box per OTP digit, like the web widget: typing advances to the
/// next box, backspace on an empty box goes back, pasting a whole code fills
/// every box, and [onCompleted] fires as soon as the last digit is in.
class _OtpBoxes extends StatefulWidget {
  const _OtpBoxes({
    super.key,
    required this.style,
    required this.length,
    required this.onCompleted,
    this.alignment = WrapAlignment.center,
  });

  final AuthyoStyle style;
  final int length;
  final ValueChanged<String> onCompleted;
  final WrapAlignment alignment;

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  late final List<TextEditingController> _ctrls = List.generate(
    widget.length,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _nodes = List.generate(
    widget.length,
    (_) => FocusNode(),
  );

  String get code => _ctrls.map((c) => c.text).join();

  void clear() {
    for (final c in _ctrls) {
      c.clear();
    }
    if (mounted && _nodes.isNotEmpty) _nodes.first.requestFocus();
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _changed(int i, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 1) {
      // Paste / autofill: spread the digits over the boxes from this one.
      var idx = i;
      for (final ch in digits.split('')) {
        if (idx >= widget.length) break;
        _ctrls[idx].text = ch;
        idx++;
      }
      _nodes[math.min(idx, widget.length - 1)].requestFocus();
    } else {
      _ctrls[i].text = digits;
      if (digits.isNotEmpty && i < widget.length - 1) {
        _nodes[i + 1].requestFocus();
      }
    }
    final full = code;
    if (full.length == widget.length) {
      widget.onCompleted(full);
    }
  }

  KeyEventResult _key(int i, FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[i].text.isEmpty &&
        i > 0) {
      _ctrls[i - 1].clear();
      _nodes[i - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.style.otpBoxGap,
      runSpacing: widget.style.otpBoxGap,
      alignment: widget.alignment,
      children: [
        for (var i = 0; i < widget.length; i++)
          Focus(
            onKeyEvent: (node, event) => _key(i, node, event),
            child: widget.style.otpBox(
              controller: _ctrls[i],
              focusNode: _nodes[i],
              autofocus: i == 0,
              onChanged: (v) => _changed(i, v),
            ),
          ),
      ],
    );
  }
}

/// Brand glyph for a social provider. Uses the dashboard-provided icon when
/// there is one, else a coloured initial.
class _ProviderGlyph extends StatelessWidget {
  const _ProviderGlyph(this.login);
  final AuthyoSocialLogin login;

  @override
  Widget build(BuildContext context) {
    final url = login.iconUrl;
    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _initial(),
      );
    }
    return _initial();
  }

  Widget _initial() {
    final (String letter, Color color) = switch (login.provider) {
      AuthyoSocialProvider.google => ('G', const Color(0xFF4285F4)),
      AuthyoSocialProvider.microsoft => ('M', const Color(0xFF00A4EF)),
      AuthyoSocialProvider.github => ('GH', const Color(0xFF24292F)),
      AuthyoSocialProvider.linkedin => ('in', const Color(0xFF0A66C2)),
      AuthyoSocialProvider.unknown => ('?', Colors.grey),
    };
    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
