import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'authyo_plugin_platform_interface.dart';

/// An implementation of [AuthyoPluginPlatform] that uses method channels.
class MethodChannelAuthyoPlugin extends AuthyoPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('authyo_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
