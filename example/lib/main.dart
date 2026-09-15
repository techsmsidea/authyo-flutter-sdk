import 'package:authyo_plugin/authyo_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Replace with the credentials from https://app.authyo.io → Applications.
const String kClientId = 'YOUR-CLIENT-ID';
const String kClientSecret = 'YOUR-CLIENT-SECRET';

/// Authyo server. Leave null for production (https://authyo.io). For a local
/// backend use e.g. 'http://10.0.2.2:5000' (Android emulator),
/// 'http://localhost:5000' (iOS simulator) or 'http://YOUR-LAN-IP:5000'
/// (physical device). Can also be passed with
/// `flutter run --dart-define=AUTHYO_BASE_URL=http://...`.
const String? kBaseUrl = String.fromEnvironment('AUTHYO_BASE_URL') == ''
    ? null
    : String.fromEnvironment('AUTHYO_BASE_URL');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authyo Plugin',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2D398F),
        useMaterial3: true,
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final AuthyoService authyoService = AuthyoService.instance;
  final TextEditingController targetController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool useEmail = false;
  bool useBuiltInDialog = true;

  /// null = follow whatever is configured on the Authyo dashboard.
  AuthyoDesignStyle? selectedStyle;

  String? currentMaskId;
  AuthyoWidgetConfig? remoteConfig;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    authyoService.init(
      clientId: kClientId,
      clientSecret: kClientSecret,
      baseUrl: kBaseUrl,
      showVerificationDialog: useBuiltInDialog,
      // Optional local overrides – comment out to follow the dashboard:
      // designStyle: AuthyoDesignStyle.glassmorphism,
      // theme: const AuthyoTheme(primary: Colors.teal),
    );
    authyoService.loadConfig().then((cfg) async {
      if (!mounted) return;
      setState(() => remoteConfig = cfg);
      // "Remember me" (dashboard option): prefill what the user asked us to
      // remember last time. Null when the option is off or nothing was kept.
      final remembered = await authyoService.rememberedIdentity();
      if (mounted && remembered != null && targetController.text.isEmpty) {
        setState(() {
          targetController.text = remembered;
          useEmail = remembered.contains('@');
        });
      }
    });
  }

  @override
  void dispose() {
    targetController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    setState(() => sending = true);
    final res = await authyoService.sendOtp(
      ctx: context,
      to: targetController.text.trim(),
      authWay: useEmail ? AuthwayEnum.email : AuthwayEnum.sms,
      designStyle: selectedStyle,
      onVerificationComplete: (result) {
        if (result.error == null) {
          _snack('✅ Verified: ${result.result?.message}');
          setState(() => currentMaskId = null);
        } else {
          _snack('❌ ${result.error?.message}');
        }
      },
    );
    if (!mounted) return;
    setState(() => sending = false);

    if (res.error != null) {
      _snack('Oops! ${res.error?.message}');
      return;
    }
    final maskId = res.result?.data?.results
        ?.where((r) => r.maskId != null)
        .map((r) => r.maskId)
        .firstOrNull;
    _snack('OTP sent successfully');
    if (!useBuiltInDialog) setState(() => currentMaskId = maskId);
  }

  Future<void> _verifyOtp() async {
    final res = await authyoService.verifyOtp(
      maskId: currentMaskId ?? '',
      otp: otpController.text.trim(),
    );
    if (!mounted) return;
    if (res.error != null) {
      _snack('Oops! ${res.error?.message}');
    } else {
      _snack('✅ ${res.result?.message}');
      otpController.clear();
      setState(() => currentMaskId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authyo Plugin')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _styleCard(),
          const SizedBox(height: 16),
          if (currentMaskId != null && !useBuiltInDialog)
            _customOtpCard()
          else
            _sendCard(),
        ],
      ),
    );
  }

  Widget _styleCard() {
    final cfg = remoteConfig;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dialog design',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AuthyoDesignStyle?>(
              value: selectedStyle,
              decoration: const InputDecoration(
                labelText: 'Design style',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    'Follow dashboard'
                    '${cfg?.designStyle != null ? ' (${cfg!.designStyle!.label})' : ''}',
                  ),
                ),
                for (final s in AuthyoDesignStyle.values)
                  DropdownMenuItem(value: s, child: Text(s.label)),
              ],
              onChanged: (v) => setState(() => selectedStyle = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use built-in verification dialog'),
              value: useBuiltInDialog,
              onChanged: (v) {
                setState(() {
                  useBuiltInDialog = v;
                  currentMaskId = null;
                });
                authyoService.setShowVerificationDialog(v);
              },
            ),
            if (cfg != null)
              Text(
                'Dashboard: ${cfg.authMethods.isEmpty ? 'no channels' : cfg.authMethods.join(', ')}'
                ' · ${cfg.socialLogins.length} social login(s)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  Widget _sendCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: targetController,
              keyboardType: useEmail
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              inputFormatters: useEmail
                  ? const []
                  : [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
              decoration: InputDecoration(
                labelText: useEmail ? 'Email address' : 'Phone number',
                hintText: useEmail ? 'jon@example.com' : '+911234567890',
                border: const OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use email'),
              value: useEmail,
              onChanged: (v) {
                targetController.clear();
                setState(() => useEmail = v);
              },
            ),
            FilledButton(
              onPressed: sending ? null : _sendOtp,
              child: sending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _customOtpCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Custom UI – enter the OTP you received',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _verifyOtp,
              child: const Text('Verify OTP'),
            ),
            TextButton(
              onPressed: () => setState(() => currentMaskId = null),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
