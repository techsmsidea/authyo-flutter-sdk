# Authyo Flutter Plugin

A Flutter plugin for integrating [Authyo](https://authyo.io) – a powerful multi-channel MFA service supporting WhatsApp, SMS, Email, and Call for OTP verification.

This plugin enables developers to implement OTP-based authentication for both legacy systems and modern, passwordless solutions with minimal configuration.

## 🚀 Features

- 📱 Multi-channel support (WhatsApp, SMS, Email, Call)
- 🧩 Plug-and-play OTP UI (or bring your own)
- 🧾 Works for both new and legacy systems
- 🔁 Configurable channel priority (no redeploy needed)
- 🔐 JWT-based login for new systems
- 🔧 REST API Support
- 📊 Transparent billing & usage dashboard
- 🆓 Free trial for all new accounts
- 🤝 Affiliate support built-in

## 🔧 Installation

Add the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  authyo_flutter: <latest_version>
```

Run:
```bash
flutter pub get
```

## 🛠️ Usage

### 1. Legacy Systems (UI Provided)

[![](https://mermaid.ink/img/pako:eNpVUtuO2kAM_RVrHvoElPslD12xsOyt2yKxrdQSHkaJQ0ZKZtK5QCni3-vMhIrmKR6fc-xj-8wSlSKLWLvdjqUVtsAIPuOeJyfYnIzFEo7C5jB3Nj8peFvNY-mhWaGOSc61hfdlLIG--fabQQ0oLWoDVa4kgqK45KLYQbv9Ce6386qChBeFuQpWhdsLCVaBxl8OjYWv7-tdELz3pMV2k6tj_QxCVs7CQeCxQSw8Ynmuk1JZ0khQHDC9u4T8kvLwA42HPYT-mjqGfgzKlOQ4VBoz1BpTIEtSYrG74X9Rnr76z15dkRPb8srAd9QiOzWch9B1CFY-eNyug81DDRQY6DdzbaiPHv3k7XhNkXArlISNSxI05mrr6dbWcxiqouVJMhZki7DB-foZCkWVdzfExs_Lti5TDxPIc1oQNaNNOY3emJCZ0qUBR6Yb9suts9cwjiOXNEpaX6JofokNO7qr9w1LYUphgllf5wNgKmw4jY_-Lrzi_HaZr6zFStSUTOkqz3UqZjbHEmMW0W-KGXeFjVksLwTlzqrNSSYsstphi2nl9jmLMl4YilyVcotLwfeal_9e6yaUfgt378-_xSoufypVXmUoZNGZ_WbRpNeZ9EajcXfWG3Sno9mwxU4satNTZ9Sf9SbDaXc4nk5Glxb74wV6ne6gT5TBpD-bjSfDUYvtdW2maZBuDvVCOWkJOxuOL38BzrgZqQ?type=png)](https://mermaid.live/edit#pako:eNpVUtuO2kAM_RVrHvoElPslD12xsOyt2yKxrdQSHkaJQ0ZKZtK5QCni3-vMhIrmKR6fc-xj-8wSlSKLWLvdjqUVtsAIPuOeJyfYnIzFEo7C5jB3Nj8peFvNY-mhWaGOSc61hfdlLIG--fabQQ0oLWoDVa4kgqK45KLYQbv9Ce6386qChBeFuQpWhdsLCVaBxl8OjYWv7-tdELz3pMV2k6tj_QxCVs7CQeCxQSw8Ynmuk1JZ0khQHDC9u4T8kvLwA42HPYT-mjqGfgzKlOQ4VBoz1BpTIEtSYrG74X9Rnr76z15dkRPb8srAd9QiOzWch9B1CFY-eNyug81DDRQY6DdzbaiPHv3k7XhNkXArlISNSxI05mrr6dbWcxiqouVJMhZki7DB-foZCkWVdzfExs_Lti5TDxPIc1oQNaNNOY3emJCZ0qUBR6Yb9suts9cwjiOXNEpaX6JofokNO7qr9w1LYUphgllf5wNgKmw4jY_-Lrzi_HaZr6zFStSUTOkqz3UqZjbHEmMW0W-KGXeFjVksLwTlzqrNSSYsstphi2nl9jmLMl4YilyVcotLwfeal_9e6yaUfgt378-_xSoufypVXmUoZNGZ_WbRpNeZ9EajcXfWG3Sno9mwxU4satNTZ9Sf9SbDaXc4nk5Glxb74wV6ne6gT5TBpD-bjSfDUYvtdW2maZBuDvVCOWkJOxuOL38BzrgZqQ)

### 2. Modern Systems (Passwordless)

[![](https://mermaid.ink/img/pako:eNpNU01z2jAQ_Ss7OvRk0pgYDD40QyDfkzbT0HZazEG110YztuTqA0oZ_nvXsmnxSburfdr33vrAMpUjS9hgMEilFbbCBF65MTul8wqNgce6qbBGabkVSsJO2A3MnN3sFbzczVLpG4tK7bIN1xaWi1QCfbPVF4MahGycNdBslESQrv5JOaUBay6qNQwGH-BmtdSiLCnfozaVK4UEq0DjL4fGwqfl67pDvfEt89XbRu3aNGwF7vra3NcWhzYtlaXuDMUW8-tjV19QHb6j8dduu_H6FwwdDMqc4Dg0GgvUGnMgRlJitT7r_6h8-13XTqqgNmfz3XbzdcGdD-5Xc15VJ3Jb1KLY-9ELJzMvqX_Uk-5R7n3jg2fytW0QWSf-m8sy8uTE6OGc0ePqc0cYnr4todCq7t8MIFPkrHTYmcebBlq_1mcgPa2nVT_mSVogBdo1ABKEbKMADElvoKYxeIk9xtM57edOmx2XpCu5mCkSM7PdDrz3zl-31sNCmFoY8_-xd2TDwGva7Y1HnZ27-5xKFrAaNaHktLWHtpgyu6ENTVlCxxwL7iqbslQe6Sp3Vr3tZcYSqx0GTCtXblhS8MpQ5JqcW1wIXmpe_8tiLqzSL91_4X-PgDVc_lCqPsFQyJID-82ScDy5GIfjOIqm01EYxsOA7VlydRFNhqPhNLoM43gaxqNjwP74_vBiFF8Np-Moji6jyeXVJGClbrn089EWop4rJy3dHQ3Hx79oRCZp?type=png)](https://mermaid.live/edit#pako:eNpNU01z2jAQ_Ss7OvRk0pgYDD40QyDfkzbT0HZazEG110YztuTqA0oZ_nvXsmnxSburfdr33vrAMpUjS9hgMEilFbbCBF65MTul8wqNgce6qbBGabkVSsJO2A3MnN3sFbzczVLpG4tK7bIN1xaWi1QCfbPVF4MahGycNdBslESQrv5JOaUBay6qNQwGH-BmtdSiLCnfozaVK4UEq0DjL4fGwqfl67pDvfEt89XbRu3aNGwF7vra3NcWhzYtlaXuDMUW8-tjV19QHb6j8dduu_H6FwwdDMqc4Dg0GgvUGnMgRlJitT7r_6h8-13XTqqgNmfz3XbzdcGdD-5Xc15VJ3Jb1KLY-9ELJzMvqX_Uk-5R7n3jg2fytW0QWSf-m8sy8uTE6OGc0ePqc0cYnr4todCq7t8MIFPkrHTYmcebBlq_1mcgPa2nVT_mSVogBdo1ABKEbKMADElvoKYxeIk9xtM57edOmx2XpCu5mCkSM7PdDrz3zl-31sNCmFoY8_-xd2TDwGva7Y1HnZ27-5xKFrAaNaHktLWHtpgyu6ENTVlCxxwL7iqbslQe6Sp3Vr3tZcYSqx0GTCtXblhS8MpQ5JqcW1wIXmpe_8tiLqzSL91_4X-PgDVc_lCqPsFQyJID-82ScDy5GIfjOIqm01EYxsOA7VlydRFNhqPhNLoM43gaxqNjwP74_vBiFF8Np-Moji6jyeXVJGClbrn089EWop4rJy3dHQ3Hx79oRCZp)

## Process
[![](https://mermaid.ink/img/pako:eNp9UctOwzAQ_BVrz0lpkiZNfUCqeNwQFQUOyBcr2TSWEjtsbESo-u84oUUVIG7endmZXc8eClMicAjDUGirbIOcbfHVoS6QXSu5I9myyhBbO1sPht3droWeyP2RdSQJzVgnyapCdVJb9tQj_eytu-5Xa5LdNG6ntNAjOg6Gl5eey9mNtkisq43GC2ylakaCR0b8bJCzh3GZ3rL7x81EOQPDk5jHWI_e801J1hFWSIQlK2qpNTZ_Wvffgn94PiOpavjXcuuKAvv-4tav7ghPSh4erTjbkCnQ7-D_l9DSIDQE0CL5U0sfyn4cEGBrbFEA988SK-kaK0Dog6dKZ8120AVwSw4DION2NfBKNr2vXFdKe8rnu4ulsobuvmKf0g_AR_FiTHuS8SXwPbwDj-N8tkiSKElXeZbEeRQHMACPltksWURZlCyzVZpEcXoI4GNSmM88dRHlcTRfxnk6T1YB7Gg857gi6hLpyjhtgadpdvgEFtDVHQ?type=png)](https://mermaid.live/edit#pako:eNp9UctOwzAQ_BVrz0lpkiZNfUCqeNwQFQUOyBcr2TSWEjtsbESo-u84oUUVIG7endmZXc8eClMicAjDUGirbIOcbfHVoS6QXSu5I9myyhBbO1sPht3droWeyP2RdSQJzVgnyapCdVJb9tQj_eytu-5Xa5LdNG6ntNAjOg6Gl5eey9mNtkisq43GC2ylakaCR0b8bJCzh3GZ3rL7x81EOQPDk5jHWI_e801J1hFWSIQlK2qpNTZ_Wvffgn94PiOpavjXcuuKAvv-4tav7ghPSh4erTjbkCnQ7-D_l9DSIDQE0CL5U0sfyn4cEGBrbFEA988SK-kaK0Dog6dKZ8120AVwSw4DION2NfBKNr2vXFdKe8rnu4ulsobuvmKf0g_AR_FiTHuS8SXwPbwDj-N8tkiSKElXeZbEeRQHMACPltksWURZlCyzVZpEcXoI4GNSmM88dRHlcTRfxnk6T1YB7Gg857gi6hLpyjhtgadpdvgEFtDVHQ)


## 🛠️ Getting Started

### 1. Install

Add to your `pubspec.yaml`:
```
dependencies:
	authyo_plugin: ^1.0.0 //Latest versions may vary
```

Import in your Dart code:
```
import 'package:authyo_plugin/authyo_plugin.dart';
```

### 2. Initialize

> **Important:**  
> You must initialize `AuthyoService` with your `clientId` and `clientSecret` before making any requests.

```
//Get AuthyoService Instance
final AuthyoService authyoService = AuthyoService.instance;

//Initialize AuthyoService using your Authyo credentials
authyoService.init(clientId: "YOUR_CLIENT_ID", clientSecret: "YOUR_CLIENT_SECRET");
```


---

## 🚦 Usage

### 🔑 Send OTP

```
// Call sendOtp function using AuthyoService
AuthyoResult otpResult = await authyoService.sendOtp(
    ctx: context,
    to: ‘+1234567890’, // or ‘user@email.com’
    otpLength: 6, // optional, defaults to 6
    expiry: 180, // optional, in seconds
    authWay: AuthwayEnum.SMS, // optional, can be SMS, Whatsapp, Email, Voice
    onVerificationComplete: (authyoResult) {
        // This callback is optional and only necessary if plugin's default OTP verification dialog is used.
        // If custom UI for OTP verification is used, you can omit this callback.
        // Check for result.
        if (authyoResult.result?.error == null) {
            // Verification successful.
        }
    });

bool success = otpResult.result?.data?.results?.firstWhere((element) => element.success == true, orElse: () => Results(success: false)).success;

if (success == true) {
  print("✅ OTP Sent: ${otpResult.result?.message}");
} else {
  print("❌ Error: ${otpResult.error?.message}");
}
```

### 🛡️ Verify OTP

```
// Call verifyOtp function using AuthyoService instance
AuthyoResult otpResult = await AuthyoService.instance.verifyOtp(maskId: "Mask ID",otp: "Received OTP");

if(otpResult.result!=null){
	print("Success: ${otpResult.result?.message}");
}
else{
	print("Error: ${otpResult.error?.message}");
}
```


---

## 🎨 Design styles & dashboard customization

The built-in dialog can be rendered in seven design languages. The look is resolved in this order (later wins):

1. Built-in defaults (Flat, Authyo blue)
2. **Your Authyo dashboard** — design style, colours, logo, button shape, layout, resend timer, enabled channels and social logins are fetched once (`GET /api/v1/authyoclient/mobileconfig`), cached on device and refreshed in the background.
3. Overrides passed to `init()` / `sendOtp()`

| `AuthyoDesignStyle` | Look |
|---|---|
| `flat` (default) | Solid colours, crisp borders — the 1.0.x look |
| `flat2` | Flat with soft elevation |
| `minimalism` | Monochrome, underline input, thin outlines |
| `skeuomorphism` | Glossy gradients, bevels, recessed input |
| `claymorphism` | Pastel, puffy, large radii |
| `glassmorphism` | Frosted translucent card over a blurred backdrop |
| `neumorphism` | Extruded / pressed-in surfaces on one background colour |

```dart
authyoService.init(
  clientId: "YOUR_CLIENT_ID",
  clientSecret: "YOUR_CLIENT_SECRET",
  // Optional – pin a style instead of following the dashboard:
  designStyle: AuthyoDesignStyle.glassmorphism,
  // Optional – partial theme override (anything unset comes from the dashboard / defaults):
  theme: const AuthyoTheme(primary: Color(0xFF0EA5E9), hideBranding: true),
);

// Per-call override:
await authyoService.sendOtp(ctx: context, to: '+1234567890', designStyle: AuthyoDesignStyle.claymorphism);

// Or change at runtime:
authyoService.setDesignStyle(AuthyoDesignStyle.neumorphism);
authyoService.setDesignStyle(null); // follow the dashboard again
```

`AuthyoTheme` fields map 1:1 to the dashboard customization: `buttonColor`, `buttonTextColor`, `inputBackground`, `inputBorder`, `inputText`, `smButton*` (social buttons), `headerText`/`bodyText` + colours, `logoUrl`, `hideBranding`, `resendButtonTimer`, `buttonStyle` (rectangular / rounded / pill), `mainLayout` (left / centre / right) and `socialMediaLayout` (top / bottom).

### Reading the remote config yourself

```dart
final cfg = await authyoService.loadConfig();      // cached → instant
cfg.designStyle;   // AuthyoDesignStyle? (null if the dashboard has none)
cfg.authMethods;   // ["Sms", "Whatsapp", "Email"]
cfg.socialLogins;  // [AuthyoSocialLogin(provider: google, id: "123"), ...]
cfg.otpLength;
```

### Showing the dialog for an OTP you already sent

```dart
final res = await authyoService.requestOtp(to: '+1234567890', authWay: AuthwayEnum.sms); // no UI
await authyoService.showVerificationDialog(context, sendResult: res, to: '+1234567890',
    onVerificationComplete: (r) { /* ... */ });
```

---

## 🔑 Social login (Google, Microsoft, GitHub, LinkedIn)

Providers you enable on the dashboard (Application → Social Media Login) appear automatically in the dialog. Tapping one opens the provider in the system browser; the Authyo callback redirects to `authyo://oauth/callback` and the result is delivered to `onVerificationComplete` with the session JWT in `result.data?.token`.

You can also trigger it without the dialog:

```dart
final cfg = await authyoService.loadConfig();
final result = await authyoService.socialLogin(cfg.socialLogins.first);
```

---

## 🪞 Same flow as the web widget

The dialog behaves exactly like the Authyo web widget (`auth-sdk.js`) on the same application:

| Step | Web widget | Flutter dialog |
|---|---|---|
| Top-left back button | returns to the identity form | closes the dialog (your form is behind it) |
| "OTP sent to: … **Change**" | rebuilds the identity form | closes the dialog |
| OTP entry | one box per digit, auto-advance, paste fills all | same (`otpLength` boxes) |
| Verify | automatic on the last digit (no button) | same |
| Countdown | `OTP will expire in m:ss` from the server's `expireTime` | same; falls back to the dashboard resend timer |
| After expiry | red notice + **Resend** (email) / **Sms · Whatsapp · VoiceCall** (phone, only enabled channels) | same, styled as primary buttons |
| Resend | passes the dashboard resend timer as the new expiry | same (`expiry`) |
| Social logins | icon row under an `OR` divider (or on top) | same |
| Success | green ring + check + "Verified successfully" inside the card | same, then the dialog closes and `onVerificationComplete` fires |
| Footer | Terms & Privacy Policy links, "Powered by Authyo" | same (`hideBranding` hides the second line) |
| Hide OTP | digits masked | same (`isOtpHide`) |

### One-time platform setup (required for social login)

**Android** — add to `android/app/src/main/AndroidManifest.xml` inside `<application>`:
```xml
<activity android:name="com.linusu.flutter_web_auth_2.CallbackActivity" android:exported="true">
  <intent-filter android:label="authyo_oauth_callback">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="authyo" />
  </intent-filter>
</activity>
```

**iOS** — add to `ios/Runner/Info.plist`:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key><string>Editor</string>
    <key>CFBundleURLName</key><string>io.authyo.oauth</string>
    <key>CFBundleURLSchemes</key><array><string>authyo</string></array>
  </dict>
</array>
```

### Using your own native sign-in SDKs instead

```dart
authyoService.init(
  clientId: ..., clientSecret: ...,
  onSocialLogin: (login, authUrl) async {
    // e.g. run google_sign_in here, or open authUrl yourself and
    // return AuthyoService.parseSocialCallback(callbackUri, login);
  },
);
```

---

## 📚 API Reference


#### Methods
##### init
```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
init({required String clientId, required String clientSecret, Duration? connectTimeout, Duration? receiveTimeout,
      bool? showVerificationDialog, AuthyoDesignStyle? designStyle, AuthyoTheme? theme,
      AuthyoSocialLoginHandler? onSocialLogin, bool prefetchConfig = true})
```
##### sendOtp
```
Future<AuthyoResult> sendOtp({
required String to,
int otpLength = 6,                 
int? expiry,
AuthwayEnum? authWay,
void Function(AuthyoResult authyoResult)? onVerificationComplete,
AuthyoDesignStyle? designStyle,
AuthyoTheme? theme,
});
```
- **to**: Phone number or email (required)
- **otpLength**: Length of OTP (optional, defaults to 6)
- **expiry**: OTP expiry in seconds (optional)
- **authWay**: Channel to send OTP (optional, defaults to dashboard preference)
- **onVerificationComplete**: Optional callback function which provide if authentication is successful or not. Only required when plugin's default OTP verification dialog is being used.
- **designStyle** / **theme**: Optional per-call overrides of the dialog look (see *Design styles*).

Returns: `AuthyoResult`

##### verifyOtp
```
Future<AuthyoResult> verifyOtp({required String maskId, required String otp})
```
- **maskId**: Received from `sendOtp` response (required)
- **otp**: The OTP entered by the user (required)

Returns: `AuthyoResult`

##### Pointing at another server
```dart
authyoService.init(clientId: ..., clientSecret: ..., baseUrl: 'https://staging.authyo.io');
```

##### Other methods
- `requestOtp({to, expiry, otpLength, authWay})` — send an OTP with no UI.
- `showVerificationDialog(context, {sendResult, to, onVerificationComplete, designStyle, theme, otpLength})` — open the dialog for an already-sent OTP.
- `loadConfig({forceRefresh})` / `currentConfig` / `clearConfigCache()` — dashboard configuration.
- `setDesignStyle(style)` / `setTheme(theme)` / `setShowVerificationDialog(bool)` — runtime switches.
- `socialLogin(AuthyoSocialLogin)` — run a social provider sign-in.

---

### AuthyoResult

A wrapper for API responses.
```
class AuthyoResult {  
  final AuthyoResponseModel? result;  
  final AuthyoError? error;  
  AuthyoResult.success(this.result) : error = null;  
  AuthyoResult.failure(this.error) : result = null;  
}
```


---

### AuthyoBaseResponse

For `sendOtp`:
```
{
	"success":  true,
	"message":  "submited successfully",
	"data":  {  
		"isTried":  1,
		"isSent":  1,
	    "results":  [
		    {	"success":  true,
			    "message":  "message submitted successfully",
			    "to":  "919898******",
			    "authtype":  "WHATSAPP",
			    "maskId":  "36eeb3a16fAaAab49b48de0d729b9a35",
			    "createdTime":  1747312374,
			    "expiretime":  1747312434
			}
		]
	}
}
```
For `verifyOtp`:
```
{
    "success": true,
    "message": "OTP Verified Successfully",
    "status": "verified",
    "data": {
        "tokenType": "Bearer",
        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJGYTh6bE92N2FMUTdRcEl6enVkQnh3R0VxMVhTZUFCalRvcXdjcE0zM2w4PSIsImlzcyI6Imh0dHBzOi8vYXV0aHlvLmlvIiwiYXVkIjoiYWVhNWRhYzBlMjNDhiZmJjYzhjMTdmMDM2ZDlhZjgiLCJpYXQiOiIxNzUxOTA0MzkyIiwiZXhwIjoiMTc1MTkwNDY5MiIsInVzZXJJZCI6IkFZLUZhOHpsT3Y3YUxRN1FwSXp6dWRCeHdHRXExWFNlQUJqVG9xd2NwTTMzbDg9IiwicGhvbmUiOiI5MTc0MDUwODkwOTkifQ.6U3gFxTqSTuHNtsA77pRfvo8i9f0wfgvqbWb088v8Lg",
        "expiresIn": 300,
        "user": {
            "phone": "9174050*****",
            "userId": "AY-Fa8zlOv7aLQ7QpIzzudBGEq1XSeABjToqwcpM33l8="
        }
    }
}
```

---

## ❗ Error Handling

All errors are subclasses of `AuthyoError`, including:
- `BadRequestError` (400)
- `UnauthorizedError` (401)
- `ForbiddenError` (403)
- `NotFoundError` (404)
- `TooManyRequestsError` (429)
- `InternalServerError` (500)
- `ServiceUnavailableError` (503)
- `NetworkError`
- `TimeoutError`
- `UnknownApiError`

## 📘 Documentation

Read the [full documentation](https://authyo.io/docs) for implementation steps, API tokens, dashboard configuration, and more.

## 🧪 Try It Free

Sign up at [authyo.io](https://app.authyo.io/account/welcome?ref=HARSCE2BE4&utm_source=partner&utm_medium=referral&utm_campaign=partner-program) and get free credits to test MFA in your app.

## 🧍 Affiliate Program

Promote Authyo and earn revenue. Details on your [Authyo Dashboard](https://authyo.io/dashboard).

## 📫 Support

For issues, feature requests, or contributions, file a GitHub issue or contact support via [authyo.io](https://authyo.io).
