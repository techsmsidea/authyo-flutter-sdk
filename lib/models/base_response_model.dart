/// Represents the base response model returned from Authyo API calls.
///
/// Includes success status, message, error information, and nested data.
class AuthyoResponseModel {
  bool? success;
  String? message;
  Data? data;
  String? status;
  String? error;
  String? errorCode;

  AuthyoResponseModel({
    this.success,
    this.message,
    this.data,
    this.status,
    this.error,
    this.errorCode,
  });

  /// Creates a AuthyoResponseModel model from json.
  AuthyoResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    if (json['status'] == null) {
      status = json['success'] == true ? "Success" : "Failure";
    } else {
      status = json['status'];
    }
  }

  /// Creates a response model from an error response.
  AuthyoResponseModel.withError(Map<String, dynamic> json) {
    success = false;
    error = json['error'].toString();
    errorCode = json['errorCode'].toString();
  }

  /// Creates a json model from AuthyoResponseModel.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

/// Contains detailed data from a successful Authyo response,
/// including OTP results, token info, and user details.
class Data {
  int? isTried;
  int? isSent;
  List<Results>? results;

  String? tokenType;
  String? token;
  int? expiresIn;
  User? user;

  Data({
    this.isTried,
    this.isSent,
    this.results,
    this.tokenType,
    this.token,
    this.expiresIn,
    this.user,
  });

  Data.fromJson(Map<String, dynamic> json) {
    isTried = json['isTried'];
    isSent = json['isSent'];

    tokenType = json['tokenType'];
    token = json['token'];
    expiresIn = json['expiresIn'];

    if (json['user'] != null) {
      user = User.fromJson(json['user']);
    }

    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isTried'] = isTried;
    data['isSent'] = isSent;
    data['tokenType'] = tokenType;
    data['token'] = token;
    data['expiresIn'] = expiresIn;
    data['user'] = user?.toJson();

    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/// Represents the user object returned in the response.
class User {
  String? phone;
  String? userId;
  String? email;
  String? identity;
  String? displayName;

  /// Channel the identity was verified through (e.g. `sms`, `google`).
  String? channel;

  User({
    this.phone,
    this.userId,
    this.email,
    this.identity,
    this.displayName,
    this.channel,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    phone: json["phone"],
    userId: json["userId"],
    email: json["email"],
    identity: json["identity"],
    displayName: json["displayName"],
    channel: json["channel"],
  );

  Map<String, dynamic> toJson() => {
    "phone": phone,
    "userId": userId,
    "email": email,
    "identity": identity,
    "displayName": displayName,
    "channel": channel,
  };
}

/// Represents an individual OTP result including delivery status and metadata.
class Results {
  bool? success;
  String? message;
  String? to;
  String? authtype;
  String? maskId;
  int? createdTime;
  int? expiretime;

  Results({
    this.success,
    this.message,
    this.to,
    this.authtype,
    this.maskId,
    this.createdTime,
    this.expiretime,
  });

  Results.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    to = json['to'];
    authtype = json['authtype'];
    maskId = json['maskId'];
    createdTime = json['createdTime'];
    // The API spells it `expireTime`; older builds used `expiretime`.
    expiretime = json['expireTime'] ?? json['expiretime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['to'] = to;
    data['authtype'] = authtype;
    data['maskId'] = maskId;
    data['createdTime'] = createdTime;
    data['expiretime'] = expiretime;
    return data;
  }
}
