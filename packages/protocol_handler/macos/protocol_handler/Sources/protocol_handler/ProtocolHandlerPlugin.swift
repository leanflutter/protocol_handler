import Cocoa
import FlutterMacOS

/// Loads nativeapi's core library while plugins register, which in the
/// Flutter runner is before the application finishes launching. Core then
/// installs its kAEGetURL handler in time to see the launch URL. The Dart API
/// is protocol_handler's ProtocolHandler.
public class ProtocolHandlerPlugin: NSObject, FlutterPlugin {
  private typealias AttachFunction = @convention(c) () -> Void

  private static let attached: Bool = {
    guard let frameworks = Bundle.main.privateFrameworksPath else { return false }
    let path = frameworks + "/cnativeapi.framework/cnativeapi"
    guard let handle = dlopen(path, RTLD_NOW),
      let attach = dlsym(handle, "nativeapi_protocol_handler_host_attach")
    else {
      NSLog("protocol_handler: cannot load %@", path)
      return false
    }
    unsafeBitCast(attach, to: AttachFunction.self)()
    return true
  }()

  public static func register(with registrar: FlutterPluginRegistrar) {
    _ = attached
  }
}
