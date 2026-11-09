import Foundation

/// The nativeapi core library, which Flutter embeds as cnativeapi.framework
/// and Dart otherwise loads only once it runs. Loading it here, while the
/// plugin registers, lets it receive URLs delivered before Dart starts; Dart's
/// later load resolves to the same image.
enum NativeAPICore {
  private typealias AttachFunction = @convention(c) () -> Void
  private typealias DeliverFunction = @convention(c) (UnsafePointer<CChar>, Int32) -> Void

  private static let deliverFunction: DeliverFunction? = {
    guard let frameworks = Bundle.main.privateFrameworksPath else { return nil }
    let path = frameworks + "/cnativeapi.framework/cnativeapi"
    guard let handle = dlopen(path, RTLD_NOW) else {
      NSLog("protocol_handler: cannot load %@", path)
      return nil
    }
    if let attach = dlsym(handle, "nativeapi_protocol_handler_host_attach") {
      unsafeBitCast(attach, to: AttachFunction.self)()
    }
    guard let deliver = dlsym(handle, "nativeapi_protocol_handler_host_deliver") else {
      return nil
    }
    return unsafeBitCast(deliver, to: DeliverFunction.self)
  }()

  static func attach() {
    _ = deliverFunction
  }

  static func deliver(_ url: URL, isLaunch: Bool) {
    guard let deliver = deliverFunction else { return }
    url.absoluteString.withCString { deliver($0, isLaunch ? 1 : 0) }
  }
}
