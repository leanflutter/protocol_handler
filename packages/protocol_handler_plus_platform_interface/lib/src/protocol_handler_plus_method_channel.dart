import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:protocol_handler_plus_platform_interface/src/protocol_handler_plus_platform_interface.dart';

/// An implementation of [ProtocolHandlerPlusPlatform] that uses method channels.
class MethodChannelProtocolHandlerPlus extends ProtocolHandlerPlusPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(
    'dev.stan_at_work.plugins/protocol_handler_plus',
  );

  /// The event channel used to receive events from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel(
    'dev.stan_at_work.plugins/protocol_handler_plus_event',
  );

  @override
  Stream<String?> get onUrlReceived {
    return eventChannel.receiveBroadcastStream().cast<String?>();
  }

  @override
  Future<void> register(String scheme) {
    return Future(() => null);
  }

  @override
  Future<String?> getInitialUrl() async {
    String initialUrl = await methodChannel.invokeMethod('getInitialUrl');
    return initialUrl.isEmpty ? null : initialUrl;
  }
}
