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

## 📚 API Reference


#### Methods
##### init
```                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
init({required String clientId, required String clientSecret, Duration? connectTimeout, Duration? receiveTimeout, bool? showVerificationDialog})
```
##### sendOtp
```
Future<AuthyoResult> sendOtp({
required String to,
int otpLength = 6,                 
int? expiry,
AuthwayEnum? authWay,
void Function(AuthyoResult authyoResult)? onVerificationComplete
});
```
- **to**: Phone number or email (required)
- **otpLength**: Length of OTP (optional, defaults to 6)
- **expiry**: OTP expiry in seconds (optional)
- **authWay**: Channel to send OTP (optional, defaults to dashboard preference)
- **onVerificationComplete**: Optional callback function which provide if authentication is successful or not. Only required when plugin's default OTP verification dialog is being used.

Returns: `AuthyoResult`

##### verifyOtp
```
Future<AuthyoResult> verifyOtp({required String maskId, required String otp})
```
- **maskId**: Received from `sendOtp` response (required)
- **otp**: The OTP entered by the user (required)

Returns: `AuthyoResult

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

Sign up at [authyo.io](https://authyo.io) and get free credits to test MFA in your app.

## 🧍 Affiliate Program

Promote Authyo and earn revenue. Details on your [Authyo Dashboard](https://authyo.io/dashboard).

## 📫 Support

For issues, feature requests, or contributions, file a GitHub issue or contact support via [authyo.io](https://authyo.io).
