import 'package:flutter/services.dart';

class MethodChannelProtocolHandler {
  final MethodChannel _channel = const MethodChannel('protocol_handler');
  final EventChannel _eventChannel =
      const EventChannel('protocol_handler/events');

  @override
  late final Stream<String?> protocolStream = _eventChannel
      .receiveBroadcastStream()
      .map<String?>((dynamic v) => v as String?);
}
