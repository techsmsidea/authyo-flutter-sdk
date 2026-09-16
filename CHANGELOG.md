## [1.1.1] - 2026-09-16

### Added
- Sign in with Apple appears in the dialog when configured on the dashboard (`AuthyoSocialProvider.apple`); the backend's Apple callback now returns to the app via `authyo://oauth/callback` like the other providers.

## [1.1.0] - 2026-09-12

### Added
- Seven selectable design styles for the built-in dialog: Flat (default), Flat 2.0, Minimalism, Skeuomorphism, Claymorphism, Glassmorphism, Neumorphism (`AuthyoDesignStyle`).
- `AuthyoTheme` — colours, texts, logo, button shape, layout and resend timer, mirroring the dashboard customization; mergeable so dashboard values and local overrides layer cleanly.
- Remote configuration: the SDK fetches the dashboard's design style, customization, enabled channels and social logins (`AuthyoService.loadConfig()`), caches them on device and refreshes in the background. The OTP flow never blocks on it.
- Social login (Google, Microsoft, GitHub, LinkedIn) inside the dialog and via `AuthyoService.socialLogin()`, using the system browser and the `authyo://oauth/callback` scheme. `onSocialLogin` lets host apps plug in native SDKs.
- `init()` options: `designStyle`, `theme`, `onSocialLogin`, `prefetchConfig`; `sendOtp()` options: `designStyle`, `theme`.
- `requestOtp()` (send without UI), `showVerificationDialog()`, `setDesignStyle()`, `setTheme()`, `setShowVerificationDialog()`.
- The dialog follows the web widget's OTP flow step for step: top-left back button, "OTP sent to: … Change", one box per digit with auto-advance / paste / auto-verify on the last digit (no Verify button), `OTP will expire in m:ss` from the server's `expireTime`, red expiry notice with **Resend** / **Sms · Whatsapp · VoiceCall** buttons for the channels enabled on the dashboard, resend passes the dashboard timer as the new expiry, social logins as an icon row under `OR`, an in-card "Verified successfully" badge before closing, Terms & Privacy footer, and `isOtpHide`.
- `AuthyoStyle` gained `decorateInput`, `otpBox`, `backButton`, `sentToRow`, `statusText`, `verifiedBadge` (styles decorate the digit boxes the same way as the single field); `AuthyoVerifiedBadge` widget.
- `PhoneVerificationDialog` gained `verifiedDisplayDuration` and a test-only `service` seam (`AuthyoService.forTesting`).
- "Remember me" (dashboard option): the dialog shows the checkbox only when enabled; ticking it sends `rememberMe` on verify (longer session token) and keeps the identity on device — `AuthyoService.rememberedIdentity()` / `forgetIdentity()`; `verifyOtp(rememberMe:)`. When the option is off nothing is shown, sent or stored.
- `User` model gains `email`, `identity`, `displayName`, `channel`.

### Changed
- Dialog logic extracted into `VerificationController`; rendering is delegated to an `AuthyoStyle` per design.
- `sendOtp` for `AuthwayEnum.email` now sends `"Email"` as `authway` (previously the enum's `toString()`).
- Example app gained a design-style picker and a built-in-dialog toggle.

### Dependencies
- `shared_preferences`, `flutter_web_auth_2`, `url_launcher` (Terms / Privacy links).

## [1.0.3] - 2025-08-18

### Improved
- Clear and helpful error message now shown when `AuthyoService.init()` is called without `clientId` or `clientSecret`.
- The message includes a link to the Authyo dashboard, making it easier for developers to obtain their credentials quickly.

## [1.0.2] - 2025-08-18

- Code formatting and LICENSE modified. 

## [1.0.1] - 2025-08-14

- Inline comments to clarify core logic in the `sendOtp` and `verifyOtp` methods.
- Basic input validation messages for phone number and email.
- Scoped `ScaffoldMessenger.of(context)` to variables before `await` calls to follow best practices.
- Renamed internal variable references for clarity and consistency.

## [1.0.0] - 2025-08-13

- Initial release of the `authyo_plugin`.
- Supports password-less authentication using:
    - Email
    - SMS
    - WhatsApp
    - Voice Call
- Provides `sendOtp` and `verifyOtp` methods for OTP-based verification.
- Built-in customizable verification dialog.
