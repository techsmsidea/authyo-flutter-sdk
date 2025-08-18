/// The AuthyoPlugin to make your app's password-less authentications smooth and easy
/// Use [AuthyoService] to initialize your API client, set clientId and clientSecret,
/// and perform [sendOtp] and [verifyOtp] calls.
/// Response is returned as [AuthyoResult] class.

library;

import 'package:authyo_plugin/component/verification_dialog.dart';
import 'package:authyo_plugin/constants/endpoints.dart';
import 'package:authyo_plugin/models/verify_otp_input_params.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'models/base_response_model.dart';
import 'models/send_otp_input_params.dart';

part 'services/api_service.dart';

part 'handlers/authyo_error.dart';

part 'handlers/errors.dart';

part 'models/authyo_result.dart';

/// Enum representing the available OTP delivery channels in Authyo.
enum AuthwayEnum {
  /// Send OTP via WhatsApp
  whatsapp('WHATSAPP'),

  /// Send OTP via Email
  email('Email'),

  /// Send OTP via SMS
  sms('SMS'),

  /// Send OTP via Voice Call
  voiceCall('VoiceCall');

  /// The string identifier for each auth way (used internally).
  final String authWay;

  const AuthwayEnum(this.authWay);
}

/// Singleton service to interact with Authyo APIs for sending and verifying OTPs.
class AuthyoService {
  /// The single instance of [AuthyoService].
  static final AuthyoService instance = AuthyoService._internal();
  _ApiService? _apiService;
  bool _showDefaultDialog = true;

  AuthyoService._internal();

  /// Initializes the plugin with your [clientId] and [clientSecret].
  ///
  /// You can optionally set [connectTimeout], [receiveTimeout], and whether to
  /// use the built-in verification dialog with [showVerificationDialog].
  /// Call this method before making any [sendOtp] or [verifyOtp] requests.
  void init({
    required String clientId,
    required String clientSecret,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool? showVerificationDialog,
  }) {
    _apiService = _ApiService(
      clientId: clientId,
      clientSecret: clientSecret,
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
    );

    _showDefaultDialog = showVerificationDialog ?? true;
  }

  /// Clears the current [clientId] and [clientSecret].
  void clearToken() {
    _apiService?.clearToken();
  }

  /// SEND OTP REQUEST
  /// Triggers a [sendOtp] request to Authyo Servers using your [clientId] and [clientSecret].
  /// [to] param requires a [phoneNumber] or [emailAddress]
  /// This request optionally accepts [expiry] (in seconds), [otpLength] (By Default 6), [authWay] (sms,whatsapp etc..).
  /// Returns an [AuthyoResult] containing either the an [AuthyoResponseModel] or an [ApiError].
  /// [authWay] an optional argument to specify the platform to send OTP such as SMS, Whatsapp, Voice call.
  /// [onVerificationComplete] callback function to check whether OTP validation is successful or not. It should be ONLY used when plugin's default OTP verification dialog is used.
  Future<AuthyoResult> sendOtp({
    required BuildContext ctx,
    required String to,
    bool resendOTP = false,
    int? expiry,
    int? otpLength,
    AuthwayEnum? authWay,
    void Function(AuthyoResult authyoResult)? onVerificationComplete,
  }) async {
    final messenger = ScaffoldMessenger.of(ctx);

    if (_apiService == null) {
      throw AuthyoInitializationError(
        'AuthyoService has not been initialized, please initialize and try again',
      );
    }

    if (to.isEmpty) {
      return AuthyoResult.failure(
        InternalServerError("Enter valid Phone or Email address."),
      );
    }

    if (authWay == AuthwayEnum.email) {
      if (_isValidEmail(to)) {
        AuthyoOTPRequestParams authyoOTPRequestParams = AuthyoOTPRequestParams(
          authway: authWay.toString(),
          expiry: expiry,
          otplength: otpLength,
          to: to,
        );
        AuthyoResponseModel? response = await _apiService?.post(
          AuthyoEndpoints.sendOtpEndpoint,
          body: authyoOTPRequestParams.toJson(),
        );

        if (response == null) {
          return AuthyoResult.failure(
            InternalServerError(
              "${response?.error ?? "Something went wrong while processing your request"} ",
            ),
          );
        }

        bool? success = response.data?.results
            ?.firstWhere(
              (element) => element.success == true,
              orElse: () => Results(success: false),
            )
            .success;
        if (response.success == true && success == true) {
          if (resendOTP == false) {
            if (_showDefaultDialog && ctx.mounted) {
              showDialog(
                context: ctx,
                barrierDismissible: false,
                builder: (context) {
                  return PhoneVerificationDialog(
                    authyoRes: AuthyoResult.success(response),
                    to: to,
                    onVerificationComplete: onVerificationComplete,
                  );
                },
              );
            }
          }
          return AuthyoResult.success(response);
        } else {
          return AuthyoResult.failure(
            InternalServerError(
              "${response.error ?? "Something went wrong while processing your request"} ",
            ),
          );
        }
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text('Please check the Email address!')),
        );
        return AuthyoResult.failure(
          InternalServerError("Please check the Email address!"),
        );
      }
    } else if (authWay == AuthwayEnum.sms ||
        authWay == AuthwayEnum.whatsapp ||
        authWay == AuthwayEnum.voiceCall) {
      if (_isValidPhoneNumber(to.startsWith('+') ? to : '+$to')) {
        AuthyoOTPRequestParams authyoOTPRequestParams = AuthyoOTPRequestParams(
          authway: authWay?.authWay,
          expiry: expiry,
          otplength: otpLength,
          to: to,
        );
        AuthyoResponseModel? response = await _apiService?.post(
          AuthyoEndpoints.sendOtpEndpoint,
          body: authyoOTPRequestParams.toJson(),
        );

        if (response == null) {
          return AuthyoResult.failure(
            InternalServerError(
              "${response?.error ?? "Something went wrong while processing your request"} ",
            ),
          );
        }

        bool? success = response.data?.results
            ?.firstWhere(
              (element) => element.success == true,
              orElse: () => Results(success: false),
            )
            .success;

        if (response.success == true && success == true) {
          if (_showDefaultDialog && resendOTP == false && ctx.mounted) {
            showDialog(
              context: ctx,
              barrierDismissible: false,
              builder: (context) {
                return PhoneVerificationDialog(
                  authyoRes: AuthyoResult.success(response),
                  to: to,
                  onVerificationComplete: onVerificationComplete,
                );
              },
            );
          }
          return AuthyoResult.success(response);
        } else {
          return AuthyoResult.failure(
            InternalServerError(
              "${response.error ?? "Error in sending OTP. Please check the entered details."} ",
            ),
          );
        }
      } else {
        return AuthyoResult.failure(
          InternalServerError("Please check the Phone Number!"),
        );
      }
    } else if (authWay == null) {
      AuthyoOTPRequestParams authyoOTPRequestParams = AuthyoOTPRequestParams(
        authway: "",
        expiry: expiry,
        otplength: otpLength,
        to: to,
      );
      AuthyoResponseModel? response = await _apiService?.post(
        AuthyoEndpoints.sendOtpEndpoint,
        body: authyoOTPRequestParams.toJson(),
      );

      if (response == null) {
        return AuthyoResult.failure(
          InternalServerError(
            "${response?.error ?? "Something went wrong while processing your request"} ",
          ),
        );
      }

      bool? otpSentSuccess = response.data?.results
          ?.firstWhere(
            (element) => element.success == true,
            orElse: () => Results(success: false),
          )
          .success;

      if (response.success == true && otpSentSuccess == true) {
        if (_showDefaultDialog && resendOTP == false && ctx.mounted) {
          showDialog(
            context: ctx,
            barrierDismissible: false,
            builder: (context) {
              return PhoneVerificationDialog(
                authyoRes: AuthyoResult.success(response),
                to: to,
                onVerificationComplete: onVerificationComplete,
              );
            },
          );
        } else {
          messenger.showSnackBar(
            SnackBar(content: Text('Something went wrong!')),
          );
        }

        return AuthyoResult.success(response);
      } else if (otpSentSuccess == false) {
        return AuthyoResult.failure(
          InternalServerError(
            'Oops, Issue in sending OTP. Please check the entered details.',
          ),
        );
      } else {
        return AuthyoResult.failure(
          InternalServerError(
            "${response.error ?? "Something went wrong while processing your request"} ",
          ),
        );
      }
    } else {
      return AuthyoResult.failure(InternalServerError("Something went wrong!"));
    }
  }

  /// VERIFY OTP
  /// Triggers a [verifyOtp] request to Authyo Servers using your [clientId] and [clientSecret].
  /// [maskId] param requires a valid maskId received from [sendOtp] response, in case of success.
  /// [otp] param requires the OTP you have received via your desired [authWay]
  /// Returns an [AuthyoResult] containing either the an [AuthyoResponseModel] or an [ApiError].
  Future<AuthyoResult> verifyOtp({
    required String maskId,
    required String otp,
  }) async {
    if (_apiService == null) {
      throw AuthyoInitializationError(
        'AuthyoService has not been initialized, please initialize and try again',
      );
    }
    VerifyOTPParams verifyOTPParams = VerifyOTPParams(maskId: maskId, otp: otp);
    AuthyoResponseModel? response = await _apiService?.get(
      AuthyoEndpoints.verifyOtpEndpoint,
      queryParameters: verifyOTPParams.toJson(),
    );
    if (response?.success == true) {
      return AuthyoResult.success(response);
    }
    return AuthyoResult.failure(
      InternalServerError(
        "${response?.error ?? "Something went wrong while processing your request"} ",
      ),
    );
  }

  /// Validates whether the given phone number is in international format.
  bool _isValidPhoneNumber(String phoneNumber) {
    final RegExp regex = RegExp(r'^\+[1-9]\d{9,15}$');
    return regex.hasMatch(phoneNumber);
  }

  /// Validates if the given string is a valid email address.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegex.hasMatch(email);
  }
}
