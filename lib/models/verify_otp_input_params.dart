class VerifyOTPParams {
  String? maskId;
  String? otp;

  /// "Remember me" ticked; only honoured when the app enabled the option.
  bool rememberMe = false;

  VerifyOTPParams({this.maskId, this.otp, this.rememberMe = false});

  VerifyOTPParams.fromJson(Map<String, dynamic> json) {
    maskId = json['maskId'];
    otp = json['otp'];
    rememberMe = json['rememberMe'] == true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maskId'] = maskId;
    data['otp'] = otp;
    if (rememberMe) data['rememberMe'] = true;
    return data;
  }
}
