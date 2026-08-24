import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protocol_handler_plus_platform_interface/src/protocol_handler_plus_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelProtocolHandlerPlus platform = MethodChannelProtocolHandlerPlus();
  const MethodChannel channel = MethodChannel(
    'dev.stan_at_work.plugins/protocol_handler_plus',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return 'myprotocol://hello';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getInitialUrl', () async {
    expect(await platform.getInitialUrl(), 'myprotocol://hello');
  });
}
