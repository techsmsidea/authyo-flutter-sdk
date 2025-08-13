class VerifyOTPParams {
  String? maskId;
  String? otp;

  VerifyOTPParams({this.maskId, this.otp});

  VerifyOTPParams.fromJson(Map<String, dynamic> json) {
    maskId = json['maskId'];
    otp = json['otp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maskId'] = maskId;
    data['otp'] = otp;
    return data;
  }
}
