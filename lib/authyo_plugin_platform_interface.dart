import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'authyo_plugin_method_channel.dart';

abstract class AuthyoPluginPlatform extends PlatformInterface {
  /// Constructs a AuthyoPluginPlatform.
  AuthyoPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static AuthyoPluginPlatform _instance = MethodChannelAuthyoPlugin();

  /// The default instance of [AuthyoPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelAuthyoPlugin].
  static AuthyoPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AuthyoPluginPlatform] when
  /// they register themselves.
  static set instance(AuthyoPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
