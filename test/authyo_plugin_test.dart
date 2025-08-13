import 'package:flutter_test/flutter_test.dart';
import 'package:authyo_plugin/authyo_plugin.dart';
import 'package:authyo_plugin/authyo_plugin_platform_interface.dart';
import 'package:authyo_plugin/authyo_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAuthyoPluginPlatform
    with MockPlatformInterfaceMixin
    implements AuthyoPluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final AuthyoPluginPlatform initialPlatform = AuthyoPluginPlatform.instance;

  test('$MethodChannelAuthyoPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelAuthyoPlugin>());
  });

  test('getPlatformVersion', () async {
    MockAuthyoPluginPlatform fakePlatform = MockAuthyoPluginPlatform();
    AuthyoPluginPlatform.instance = fakePlatform;

  });
}
