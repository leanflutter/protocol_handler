import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:protocol_handler/src/protocol_registrar_impl_android.dart';
import 'package:protocol_handler/src/protocol_registrar_impl_ios.dart';
import 'package:protocol_handler/src/protocol_registrar_impl_macos.dart';
import 'package:protocol_handler/src/protocol_registrar_impl_windows.dart'
    if (dart.library.html) 'package:protocol_handler/src/protocol_registrar_impl_windows_noop.dart';

class ProtocolRegistrar {
  /// The shared instance of [ProtocolRegistrar].
  static ProtocolRegistrar get instance {
    if (!kIsWeb && Platform.isAndroid) {
      return ProtocolRegistrarImplAndroid.instance;
    } else if (!kIsWeb && Platform.isIOS) {
      return ProtocolRegistrarImplIOS.instance;
    } else if (!kIsWeb && Platform.isMacOS) {
      return ProtocolRegistrarImplMacOS.instance;
    } else if (!kIsWeb && Platform.isWindows) {
      return ProtocolRegistrarImplWindows.instance;
    }
    return ProtocolRegistrar();
  }

  Future<void> register(String scheme) async {
    throw UnimplementedError();
  }
}

final protocolRegistrar = ProtocolRegistrar.instance;
