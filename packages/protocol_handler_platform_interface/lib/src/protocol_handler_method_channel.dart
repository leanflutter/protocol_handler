import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'protocol_handler_platform_interface.dart';

/// An implementation of [ProtocolHandlerPlatform] that uses method channels.
class MethodChannelProtocolHandler extends ProtocolHandlerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('protocol_handler');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
