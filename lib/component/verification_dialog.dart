import 'dart:async';

import 'package:authyo_plugin/authyo_plugin.dart';
import 'package:authyo_plugin/colors/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A dialog widget for verifying a phone number or email address using OTP.
///
/// This widget displays an OTP input field, handles OTP verification,
/// allows OTP resend via different methods (SMS, WhatsApp, etc.), and
/// notifies the parent on successful verification.
class PhoneVerificationDialog extends StatefulWidget {
  const PhoneVerificationDialog({
    super.key,
    required this.authyoRes,
    required this.to,
    this.onVerificationComplete,
  });

  final AuthyoResult authyoRes;
  final String to;
  final void Function(AuthyoResult authyoResult)? onVerificationComplete;

  @override
  State<PhoneVerificationDialog> createState() =>
      _PhoneVerificationDialogState();
}

class _PhoneVerificationDialogState extends State<PhoneVerificationDialog> {
  final AuthyoService _authyoService = AuthyoService.instance;
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ValueNotifier _isLoading = ValueNotifier(false);

  final ValueNotifier<bool> _showOtpPage = ValueNotifier(false);
  String? currentMaskId;
  final TextEditingController _otpTextController = TextEditingController();

  Timer? _timer;
  late int _secondsRemaining;
  bool _showOptions = false;
  late AuthwayEnum _authway;

  @override
  void initState() {
    super.initState();

    if (widget.authyoRes.error != null) {
      _isLoading.value = false;
    } else {
      _isLoading.value = false;
      if (widget.authyoRes.result?.data?.results != null) {
        if (widget.authyoRes.result!.data!.results!.isEmpty) {
          return;
        }
        final maskResult = widget.authyoRes.result?.data?.results?.firstWhere(
          (element) => element.maskId != null,
          orElse: () {
            return widget.authyoRes.result!.data!.results![0];
          },
        );

        if (maskResult == null || maskResult.maskId == null) {
        } else {
          String? maskId = widget.authyoRes.result?.data?.results
              ?.firstWhere((element) => element.maskId != null)
              .maskId;
          currentMaskId = maskId;
          _showOtpPage.value = true;
        }
      }
    }
    _resetTimer();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _showOptions = true;
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    setState(() {
      _secondsRemaining = 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: Row(
                children: [
                  Spacer(),
                  InkWell(
                    child: Icon(Icons.close),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Image.asset(
                  'packages/authyo_plugin/res/authyo-logo.png',
                ),
              ),
            ),

            Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Text(
                  widget.to.contains('@') ? _maskEmail() : _maskPhone(),
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.left,
                ),
              ],
            ),

            _buildOtpForm(),

            Container(
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: AppColor.primary,
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (_formKey.currentState!.validate()) {
                    _isLoading.value = true;

                    AuthyoResult otpResult = await AuthyoService.instance
                        .verifyOtp(
                          maskId: currentMaskId ?? '',
                          otp: _otpTextController.text,
                        );

                    if (otpResult.error != null) {
                      _isLoading.value = false;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Oops! ${otpResult.error?.message}'),
                        ),
                      );
                    } else {
                      _isLoading.value = false;

                      messenger.showSnackBar(
                        SnackBar(content: Text('${otpResult.result?.message}')),
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        FocusScope.of(context).unfocus();
                      }
                    }

                    widget.onVerificationComplete!(otpResult);
                  }
                },
                child: Text(
                  'Verify OTP',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12, top: 16),
              child: Row(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Powered By', style: TextStyle(fontSize: 14)),
                  Text(
                    'Authyo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpForm() {
    return Center(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (context, loading, value) {
              if (loading) {
                return Center(child: CircularProgressIndicator());
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16,
                children: [
                  TextFormField(
                    controller: _otpTextController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      label: Text('Enter Verification OTP'),
                      focusColor: Colors.transparent,

                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColor.primary,
                          width: 1.25,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.primary),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColor.primary),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      hintText: "123456",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      labelStyle: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),

                  _showOptions
                      ? widget.to.contains('@')
                            ? TextButton(
                                onPressed: () async {
                                  if (widget.to.contains('@')) {
                                    _authway = AuthwayEnum.email;
                                    _resetTimer();
                                    _showOptions = false;

                                    AuthyoResult res = await _resendOTP();
                                    if (res.error == null) {
                                      _startTimer();
                                    }
                                  } else {
                                    setState(() {
                                      _resetTimer();
                                      _showOptions = true;
                                    });
                                  }
                                },
                                child: Text(
                                  'Resend OTP',
                                  style: TextStyle(color: AppColor.primary),
                                ),
                              )
                            : Column(
                                spacing: 16,
                                children: [
                                  Text(
                                    'Resend OTP to: ',
                                    textAlign: TextAlign.left,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: !widget.to.contains('@')
                                          ? AuthwayEnum.values.map((e) {
                                              return e.authWay ==
                                                      AuthwayEnum.email.authWay
                                                  ? SizedBox()
                                                  : InkWell(
                                                      onTap: () async {
                                                        _authway = e;
                                                        _resetTimer();
                                                        _showOptions = false;

                                                        AuthyoResult res =
                                                            await _resendOTP();
                                                        if (res.error == null) {
                                                          _startTimer();
                                                        }
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color:
                                                                  const Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.15,
                                                                  ),
                                                              spreadRadius: 2,
                                                              blurRadius: 4,
                                                            ),
                                                          ],
                                                        ),
                                                        padding: EdgeInsets.all(
                                                          10,
                                                        ),
                                                        margin:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                            ),
                                                        child: Image.asset(
                                                          'packages/authyo_plugin/res/${e.authWay}.png',
                                                          width: 24,
                                                          height: 24,
                                                          color:
                                                              AppColor.primary,
                                                        ),
                                                      ),
                                                    );
                                            }).toList()
                                          : [],
                                    ),
                                  ),
                                ],
                              )
                      : Text(
                          _secondsRemaining == 60
                              ? '1:00 minute remaining'
                              : _secondsRemaining == 1
                              ? '0:0$_secondsRemaining second remaining'
                              : _secondsRemaining < 10
                              ? '0:0$_secondsRemaining seconds remaining'
                              : '0:$_secondsRemaining seconds remaining',
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<AuthyoResult> _resendOTP() async {
    _isLoading.value = true;
    final messenger = ScaffoldMessenger.of(context);
    AuthyoResult otpResult = await _authyoService.sendOtp(
      ctx: context,
      to: widget.to,
      resendOTP: true,
      authWay: _authway,
    );

    if (otpResult.error != null) {
      _isLoading.value = false;
      messenger.showSnackBar(
        SnackBar(content: Text('Oops! ${otpResult.error?.message}')),
      );
    } else {
      _isLoading.value = false;
      if (otpResult.result?.data?.results != null) {
        if (otpResult.result!.data!.results!.isEmpty) {
          messenger.showSnackBar(
            SnackBar(content: Text('Error: ${otpResult.result?.message}')),
          );
        }
        final maskResult = otpResult.result?.data?.results?.firstWhere(
          (element) => element.maskId != null,
          orElse: () {
            return otpResult.result!.data!.results![0];
          },
        );

        if (maskResult == null || maskResult.maskId == null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'Error in sending OTP. Please check entered details.',
              ),
            ),
          );
        } else {
          String? maskId = otpResult.result?.data?.results
              ?.firstWhere((element) => element.maskId != null)
              .maskId;
          messenger.showSnackBar(
            SnackBar(content: Text('OTP Sent Successfully')),
          );
          _phoneNumberController.text = '';
          currentMaskId = maskId ?? '';
        }
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Error in sending OTP. Please check entered details.',
            ),
          ),
        );
      }
    }
    return otpResult;
  }

  String _maskPhone() {
    return 'OTP has been sent to ${'X' * (widget.to.length - 4)}${widget.to.substring(widget.to.length - 4, widget.to.length)}';
  }

  String _maskEmail() {
    List emailPart = widget.to.split('@');
    if (emailPart.length == 2) {
      String name = emailPart[0];
      String domain = emailPart[1];
      return 'OTP has been sent to ${name.substring(0, name.length > 5 ? 5 : 1)}${'X' * (name.length > 5 ? name.length - 5 : name.length - 1)}@$domain';
    } else {
      return 'OTP has been sent to ${widget.to}';
    }
  }
}
