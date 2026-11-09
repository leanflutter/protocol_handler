#ifndef FLUTTER_PLUGIN_PROTOCOL_HANDLER_PLUGIN_C_API_H_
#define FLUTTER_PLUGIN_PROTOCOL_HANDLER_PLUGIN_C_API_H_

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void ProtocolHandlerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar);

// Call first thing in wWinMain. When this process was started with a URL
// argument and another instance of the same executable is running, sends the
// URL to it (nativeapi's ProtocolHandler emits it there), brings that
// instance's window to the front and returns true: exit without creating a
// window. Returns false otherwise, including for a launch without a URL.
FLUTTER_PLUGIN_EXPORT bool ProtocolHandlerForwardToRunningInstance(void);

#if defined(__cplusplus)
}  // extern "C"
#endif

#endif  // FLUTTER_PLUGIN_PROTOCOL_HANDLER_PLUGIN_C_API_H_
