import 'dart:async';

import 'package:flutter/foundation.dart';

import '../authyo_plugin.dart';

/// State + behaviour of the verification dialog, independent of how it is
/// drawn. The dialog widget listens to this and asks the active
/// `AuthyoStyle` to render each slot.
class VerificationController extends ChangeNotifier {
  VerificationController({
    required this.to,
    required AuthyoResult sendResult,
    required this.resendTimerSeconds,
    required this.config,
    this.otpLength,
    AuthyoService? service,
  }) : _service = service ?? AuthyoService.instance {
    _adoptSendResult(sendResult);
  }

  final AuthyoService _service;

  /// Phone number or email the OTP was sent to.
  final String to;

  /// Dashboard "resend button timer" (seconds, 0 = not set). Like the web
  /// widget it is sent to the server as the new expiry when resending and
  /// used as the countdown only when the server reply carries no expiry.
  final int resendTimerSeconds;

  /// Remote configuration (channels, social logins…).
  final AuthyoWidgetConfig config;

  /// Expected OTP length, used to cap the input. Null = unknown.
  final int? otpLength;

  String? maskId;
  String otp = '';
  bool isLoading = false;

  /// True once the OTP has expired: the resend options replace the timer.
  bool canResend = false;
  int secondsRemaining = 0;

  /// OTP lifetime reported by the last send/resend reply, if any.
  int? _expirySeconds;

  /// True after a successful verification (OTP or social) while the
  /// success badge is shown.
  bool verified = false;

  /// Last error message to surface to the user (cleared on next action).
  String? errorMessage;

  /// Last informational message (e.g. "OTP sent").
  String? infoMessage;

  /// Set once verification (OTP or social) succeeds.
  AuthyoResult? completed;

  Timer? _timer;
  bool _disposed = false;

  bool get isEmail => to.contains('@');

  /// Channels offered for "resend". Uses the dashboard configuration when
  /// available; falls back to every channel valid for the target type.
  List<AuthwayEnum> get resendChannels {
    final configured = config.authMethods
        .map(_channelFromApiName)
        .whereType<AuthwayEnum>()
        .toList();
    final all = configured.isEmpty ? AuthwayEnum.values.toList() : configured;
    return isEmail
        ? all.where((c) => c == AuthwayEnum.email).toList()
        : all.where((c) => c != AuthwayEnum.email).toList();
  }

  List<AuthyoSocialLogin> get socialLogins => config.socialLogins;

  void start() {
    _restartTimer();
  }

  // ---------------------------------------------------------------------------

  void _adoptSendResult(AuthyoResult res) {
    final results = res.result?.data?.results;
    if (results == null || results.isEmpty) return;
    final withMask = results.where((r) => r.maskId != null);
    final r = withMask.isNotEmpty ? withMask.first : results.first;
    maskId = r.maskId;
    // Same countdown as the web widget: expireTime - createdTime.
    final created = r.createdTime ?? 0;
    final expires = r.expiretime ?? 0;
    _expirySeconds = created > 0 && expires > created
        ? expires - created
        : null;
  }

  /// Seconds the countdown starts from.
  int get countdownSeconds =>
      _expirySeconds ?? (resendTimerSeconds > 0 ? resendTimerSeconds : 60);

  void _restartTimer() {
    _timer?.cancel();
    secondsRemaining = countdownSeconds;
    canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_disposed) {
        t.cancel();
        return;
      }
      if (secondsRemaining > 0) {
        secondsRemaining--;
      } else {
        canResend = true;
        t.cancel();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  /// `m:ss` countdown label.
  String get countdownLabel {
    final m = secondsRemaining ~/ 60;
    final s = secondsRemaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  Future<AuthyoResult> verify() async {
    errorMessage = null;
    infoMessage = null;
    if (otp.trim().isEmpty) {
      errorMessage = 'Please enter the OTP';
      notifyListeners();
      return AuthyoResult.failure(BadRequestError(errorMessage!));
    }
    _setLoading(true);
    final res = await _service.verifyOtp(maskId: maskId ?? '', otp: otp.trim());
    if (_disposed) return res;
    if (res.error != null) {
      errorMessage = res.error!.message;
    } else {
      _timer?.cancel();
      verified = true;
      completed = res;
    }
    _setLoading(false);
    return res;
  }

  Future<AuthyoResult> resend(AuthwayEnum channel) async {
    errorMessage = null;
    infoMessage = null;
    _setLoading(true);
    final res = await _service.requestOtp(
      to: to,
      authWay: channel,
      otpLength: otpLength,
      expiry: resendTimerSeconds > 0 ? resendTimerSeconds : null,
    );
    if (_disposed) return res;
    if (res.error != null) {
      errorMessage = res.error!.message;
    } else {
      _adoptSendResult(res);
      if (maskId == null) {
        errorMessage = 'Error in sending OTP. Please check entered details.';
      } else {
        infoMessage = 'OTP sent successfully';
        otp = '';
        _restartTimer();
      }
    }
    _setLoading(false);
    return res;
  }

  Future<AuthyoResult> social(AuthyoSocialLogin login) async {
    errorMessage = null;
    infoMessage = null;
    _setLoading(true);
    final res = await _service.socialLogin(login);
    if (_disposed) return res;
    if (res.error != null) {
      // A cancelled browser session (code 0) is not worth an error banner.
      if (res.error!.code != 0) errorMessage = res.error!.message;
    } else {
      _timer?.cancel();
      verified = true;
      completed = res;
    }
    _setLoading(false);
    return res;
  }

  static AuthwayEnum? _channelFromApiName(String name) {
    switch (name.trim().toLowerCase()) {
      case 'sms':
        return AuthwayEnum.sms;
      case 'whatsapp':
        return AuthwayEnum.whatsapp;
      case 'voicecall':
      case 'call':
        return AuthwayEnum.voiceCall;
      case 'email':
        return AuthwayEnum.email;
      default:
        return null;
    }
  }

  /// `+91XXXXXX1234` / `abXXXX@domain` for the "sent to" line.
  String get maskedTarget {
    if (isEmail) {
      final parts = to.split('@');
      if (parts.length != 2) return to;
      final name = parts[0];
      final keep = name.length > 5 ? 5 : 1;
      return '${name.substring(0, keep)}${'X' * (name.length - keep)}@${parts[1]}';
    }
    if (to.length <= 4) return to;
    return '${'X' * (to.length - 4)}${to.substring(to.length - 4)}';
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
