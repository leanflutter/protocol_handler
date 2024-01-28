import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protocol_handler_platform_interface/src/protocol_handler_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelProtocolHandler platform = MethodChannelProtocolHandler();
  const MethodChannel channel =
      MethodChannel('dev.leanflutter.plugins/protocol_handler');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return 'myprotocol://hello';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getInitialUrl', () async {
    expect(await platform.getInitialUrl(), 'myprotocol://hello');
  });
}
