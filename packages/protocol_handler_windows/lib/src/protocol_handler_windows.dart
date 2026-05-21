import 'dart:io';

import 'package:protocol_handler_platform_interface/protocol_handler_platform_interface.dart';
import 'package:win32_registry/win32_registry.dart';

class ProtocolHandlerWindows extends MethodChannelProtocolHandler {
  /// The [ProtocolHandlerWindows] constructor.
  ProtocolHandlerWindows() : super();

  /// Registers this class as the default instance of [ProtocolHandlerWindows].
  static void registerWith() {
    ProtocolHandlerPlatform.instance = ProtocolHandlerWindows();
  }

  @override
  Future<void> register(String scheme) async {
    String appPath = Platform.resolvedExecutable;

    String protocolRegKey = 'Software\\Classes\\$scheme';
    String protocolCmdRegKey = 'shell\\open\\command';

    final regKey = CURRENT_USER.create(protocolRegKey);
    regKey.setValue('URL Protocol', RegistryValue.string(''));
    regKey.create(protocolCmdRegKey).setValue('', RegistryValue.string('$appPath "%1"'));
  }
}
