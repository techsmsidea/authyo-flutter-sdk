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
