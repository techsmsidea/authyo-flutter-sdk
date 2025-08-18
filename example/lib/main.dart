import 'package:flutter/material.dart';
import 'package:authyo_plugin/authyo_plugin.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthyoService authyoService = AuthyoService.instance;
  final TextEditingController phoneNumberController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ValueNotifier isLoading = ValueNotifier(false);
  final ValueNotifier<AuthwayEnum> senderSwitch = ValueNotifier<AuthwayEnum>(
    AuthwayEnum.sms,
  );

  ValueNotifier<String> currentMaskId = ValueNotifier<String>('');

  bool showVerificationDialogFlag = true;

  @override
  void initState() {
    super.initState();
    authyoService.init(
      clientId: null, // YOUR-CLIENT-ID
      clientSecret: null, // YOUR-CLIENT-SECRET
      showVerificationDialog: showVerificationDialogFlag,
    );
  }

  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Authyo Plugin')),
        body: Builder(
          builder: (BuildContext context) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 12,
                ),
                child: ValueListenableBuilder(
                  valueListenable: currentMaskId,
                  builder: (context, value, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        value.isNotEmpty && showVerificationDialogFlag == false
                            ? Column(
                                children: [
                                  TextField(
                                    controller: otpController,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      label: Text('Enter OTP'),
                                      focusColor: Colors.transparent,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.25,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      hintText: '******',
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
                                      labelStyle: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );
                                      AuthyoResult otpResult =
                                          await authyoService.verifyOtp(
                                            maskId: currentMaskId.value,
                                            otp: otpController.text,
                                          );

                                      if (showVerificationDialogFlag == false) {
                                        if (otpResult.error != null) {
                                          isLoading.value = false;
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Oops! ${otpResult.error?.message}',
                                              ),
                                            ),
                                          );
                                        } else {
                                          isLoading.value = false;
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                otpResult.result?.message ?? '',
                                              ),
                                            ),
                                          );

                                          phoneNumberController.text = '';
                                          otpController.text = '';
                                          currentMaskId.value = '';
                                        }
                                      }
                                    },
                                    child: Text('Verify OTP'),
                                  ),
                                ],
                              )
                            : ValueListenableBuilder(
                                valueListenable: senderSwitch,
                                builder: (context, sender, child) {
                                  return Column(
                                    spacing: 12,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      TextFormField(
                                        controller: phoneNumberController,
                                        keyboardType:
                                            senderSwitch.value ==
                                                AuthwayEnum.sms
                                            ? TextInputType.phone
                                            : TextInputType.emailAddress,
                                        inputFormatters:
                                            senderSwitch.value ==
                                                AuthwayEnum.sms
                                            ? [
                                                FilteringTextInputFormatter.allow(
                                                  (RegExp(r'[0-9+]')),
                                                ),
                                              ]
                                            : [],
                                        decoration: InputDecoration(
                                          label: Text(
                                            sender == AuthwayEnum.sms
                                                ? 'Phone Number'
                                                : "Email Address",
                                          ),
                                          focusColor: Colors.transparent,
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                              width: 1.25,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                          ),
                                          hintText: sender == AuthwayEnum.sms
                                              ? "+91-123-456-7890"
                                              : "jon@gmail.com",
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade400,
                                          ),
                                          labelStyle: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        spacing: 12,
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text('Use Email'),
                                          Switch(
                                            value:
                                                senderSwitch.value ==
                                                AuthwayEnum.email,
                                            onChanged: (value) async {
                                              phoneNumberController.text = '';
                                              FocusScope.of(context).unfocus();

                                              if (value == true) {
                                                senderSwitch.value =
                                                    AuthwayEnum.email;
                                              } else {
                                                senderSwitch.value =
                                                    AuthwayEnum.sms;
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          final messenger =
                                              ScaffoldMessenger.of(context);

                                          FocusScope.of(context).unfocus();
                                          AuthyoResult?
                                          otpResult = await authyoService.sendOtp(
                                            ctx: context,
                                            to: phoneNumberController.text,
                                            authWay: senderSwitch.value,
                                            onVerificationComplete:
                                                (authyoResult) {
                                                  // Check for result.
                                                  if (authyoResult
                                                          .result
                                                          ?.error ==
                                                      null) {
                                                    // Verification successful.
                                                  }
                                                },
                                          );

                                          if (otpResult.error != null) {
                                            isLoading.value = false;
                                            messenger.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Oops! ${otpResult.error?.message}',
                                                ),
                                              ),
                                            );
                                          } else {
                                            isLoading.value = false;
                                            if (otpResult
                                                    .result
                                                    ?.data
                                                    ?.results !=
                                                null) {
                                              if (otpResult
                                                  .result!
                                                  .data!
                                                  .results!
                                                  .isEmpty) {
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Error: ${otpResult.result?.message}',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              final maskResult = otpResult
                                                  .result
                                                  ?.data
                                                  ?.results
                                                  ?.firstWhere(
                                                    (element) =>
                                                        element.maskId != null,
                                                    orElse: () {
                                                      return otpResult
                                                          .result!
                                                          .data!
                                                          .results![0];
                                                    },
                                                  );
                                              if (maskResult == null ||
                                                  maskResult.maskId == null) {
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Unable to find maskId: ${maskResult!.message}',
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                String? maskId = otpResult
                                                    .result
                                                    ?.data
                                                    ?.results
                                                    ?.firstWhere(
                                                      (element) =>
                                                          element.maskId !=
                                                          null,
                                                    )
                                                    .maskId;
                                                messenger.showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'OTP Sent Successfully',
                                                    ),
                                                  ),
                                                );
                                                currentMaskId.value =
                                                    maskId ?? '';
                                              }
                                            } else {
                                              messenger.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Unable to find maskId: ${otpResult.result?.data?.results?.first.message}',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        child: const Text('Send OTP'),
                                      ),
                                    ],
                                  );
                                },
                              ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
