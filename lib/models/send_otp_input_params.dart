class AuthyoOTPRequestParams {
  String? to;
  int? expiry;
  int? otplength;
  String? authway;

  AuthyoOTPRequestParams({this.to, this.expiry, this.otplength, this.authway});

  AuthyoOTPRequestParams.fromJson(Map<String, dynamic> json) {
    to = json['to'];
    expiry = json['expiry'];
    otplength = json['otplength'];
    authway = json['authway'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['to'] = to;
    data['expiry'] = expiry;
    data['otplength'] = otplength;
    data['authway'] = authway;
    return data;
  }
}
