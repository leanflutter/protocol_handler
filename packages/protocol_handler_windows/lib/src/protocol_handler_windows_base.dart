import 'package:protocol_handler_platform_interface/protocol_handler_platform_interface.dart';

abstract class ProtocolHandlerWindowsBase extends MethodChannelProtocolHandler {
  Future<void> register(String scheme, {String? friendlyAppName});
}
