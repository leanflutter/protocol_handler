import Flutter
import UIKit

/// Forwards the URLs UIKit hands to the application and scene delegates to
/// nativeapi's ProtocolHandler. The Dart API is protocol_handler's ProtocolHandler.
public class ProtocolHandlerPlugin: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = ProtocolHandlerPlugin()
    NativeAPICore.attach()
    // Both lifecycle delegate lists are weak. There is no MethodChannel here
    // to retain the plugin, so keep it alive for the lifetime of this engine.
    registrar.publish(instance)
    registrar.addApplicationDelegate(instance)
    registrar.addSceneDelegate(instance)
  }

  // Apps without a scene manifest.

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]
  ) -> Bool {
    if let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL {
      NativeAPICore.deliver(url, isLaunch: true)
    }
    return true
  }

  public func application(
    _ application: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    NativeAPICore.deliver(url, isLaunch: false)
    // Leave the URL to other plugins as well.
    return false
  }

  // Scene-based apps (the Flutter template since 3.38).

  public func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    for context in connectionOptions?.urlContexts ?? [] {
      NativeAPICore.deliver(context.url, isLaunch: true)
    }
    return false
  }

  public func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    for context in URLContexts {
      NativeAPICore.deliver(context.url, isLaunch: false)
    }
    return false
  }
}
