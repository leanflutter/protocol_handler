import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protocol_handler/protocol_handler.dart';

void main() {
  const MethodChannel channel = MethodChannel('protocol_handler');

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
    expect(await ProtocolHandler.platformVersion, '42');
  });
}
