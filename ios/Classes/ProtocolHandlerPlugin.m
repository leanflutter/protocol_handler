#import "ProtocolHandlerPlugin.h"
#if __has_include(<protocol_handler/protocol_handler-Swift.h>)
#import <protocol_handler/protocol_handler-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "protocol_handler-Swift.h"
#endif

@implementation ProtocolHandlerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftProtocolHandlerPlugin registerWithRegistrar:registrar];
}
@end
