import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

import 'protocol_registrar.dart';

class ProtocolRegistrarImplWindows extends ProtocolRegistrar {
  ProtocolRegistrarImplWindows._();

  /// The shared instance of [ProtocolRegistrarImplWindows].
  static final ProtocolRegistrarImplWindows instance =
      ProtocolRegistrarImplWindows._();

  @override
  Future<void> register(String scheme) async {
    String appPath = Platform.resolvedExecutable;

    String protocolRegKey = 'Software\\Classes\\$scheme';
    RegistryValue protocolRegValue = const RegistryValue(
      'URL Protocol',
      RegistryValueType.string,
      '',
    );
    String protocolCmdRegKey = 'shell\\open\\command';
    RegistryValue protocolCmdRegValue = RegistryValue(
      '',
      RegistryValueType.string,
      '$appPath "%1"',
    );

    final regKey = Registry.currentUser.createKey(protocolRegKey);
    regKey.createValue(protocolRegValue);
    regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);
  }
}
