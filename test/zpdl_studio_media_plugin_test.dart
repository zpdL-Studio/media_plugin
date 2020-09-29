import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zpdl_studio_media_plugin/zpdl_studio_media_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('zpdl_studio_media_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ZpdlStudioMediaPlugin.platformVersion, '42');
  });
}
