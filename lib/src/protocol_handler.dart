import 'dart:async';

import 'method_channel/method_channel_protocol_handler.dart';

class ProtocolHandler {
  ProtocolHandler._();

  /// The shared instance of [ProtocolHandler].
  static final ProtocolHandler instance = ProtocolHandler._();

  final MethodChannelProtocolHandler _methodChannel =
      MethodChannelProtocolHandler();

  Stream<String?> register({
    required String protocol,
  }) {
    return _methodChannel.protocolStream;
  }
}

final protocolHandler = ProtocolHandler.instance;
