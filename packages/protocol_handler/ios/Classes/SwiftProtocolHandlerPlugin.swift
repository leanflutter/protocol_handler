import Flutter
import UIKit

public class SwiftProtocolHandlerPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel!
    
    private var _initialUrl: String?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "dev.leanflutter.plugins/protocol_handler", binaryMessenger: registrar.messenger())
        let instance = SwiftProtocolHandlerPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getInitialUrl":
            result(self._initialUrl ?? "");
            break;
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        let url: Any? = launchOptions[UIApplication.LaunchOptionsKey.url];
        if (url != nil) {
            self._initialUrl = (url as! URL).absoluteString
        }
        return true
    }
    
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let args: NSDictionary = [
            "url": url.absoluteString,
        ]
        channel.invokeMethod("onProtocolUrlReceived", arguments: args, result: nil)
        return true
    }
}
