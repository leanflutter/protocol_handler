import 'dart:io';

import 'package:protocol_handler_platform_interface/protocol_handler_platform_interface.dart';
import 'package:protocol_handler_windows/src/protocol_handler_windows_base.dart';
import 'package:win32_registry/win32_registry.dart';

class ProtocolHandlerWindowsImpl extends ProtocolHandlerWindowsBase {
  /// The [ProtocolHandlerWindows] constructor.
  ProtocolHandlerWindowsImpl() : super();

  /// Registers this class as the default instance of [ProtocolHandlerWindowsImpl].
  static void registerWith() {
    ProtocolHandlerPlatform.instance = ProtocolHandlerWindowsImpl();
  }

  @override
  Future<void> register(String scheme, {String? friendlyAppName}) async {
    String appPath = Platform.resolvedExecutable;

    String protocolRegKey = 'Software\\Classes\\$scheme';
    RegistryValue protocolRegValue = const RegistryValue.string(
      'URL Protocol',
      '',
    );
    String protocolCmdRegKey = 'shell\\open\\command';
    RegistryValue protocolCmdRegValue = RegistryValue.string(
      '',
      '$appPath "%1"',
    );

    final regKey = Registry.currentUser.createKey(protocolRegKey);
    regKey.createValue(protocolRegValue);
    regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);

    if (friendlyAppName != null) {
      String applicationRegKey = 'Application';
      RegistryValue friendlyAppNameRegValue = RegistryValue.string(
        'ApplicationName',
        friendlyAppName,
      );
      regKey.createKey(applicationRegKey).createValue(friendlyAppNameRegValue);
    }
  }
}
