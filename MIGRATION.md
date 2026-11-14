# Migrating to the NativeAPI implementation

`protocol_handler` 0.3.0 introduced the 0.2.x public capabilities on NativeAPI.
Use Flutter 3.50+, Dart 3.14+ and `protocol_handler: ^0.3.0` (which depends on
`nativeapi: ^0.6.0`). Remove direct dependencies/imports of the former
`protocol_handler_android`, `_ios`, `_macos`, `_windows` and
`_platform_interface` packages. Keep this import:

```dart
import 'package:protocol_handler/protocol_handler.dart';
```

**iOS fix on `main`:** four-platform verification found that 0.3.0 did not retain
its iOS lifecycle delegate, so URL callbacks could be lost. The fix is listed under
`Unreleased` in the [changelog](CHANGELOG.md). Until that patch is published, use
the repository version for iOS:

```yaml
dependencies:
  protocol_handler:
    git:
      url: https://github.com/leanflutter/protocol_handler.git
      ref: main
```

Keep the `protocol_handler` plugin in a Flutter application, even when consuming
NativeAPI directly. Its native host code captures links before Dart loads the
library and connects Android intents, Apple application/scene callbacks and
Windows second-instance forwarding to the core. Adding only `nativeapi` or
`nativeapi_flutter` does not install this host integration.

## Public capability mapping

| 0.2.x capability | 0.3.x Flutter facade | Direct `nativeapi` equivalent |
| --- | --- | --- |
| `register(String scheme)` | Same method; now returns `Future<bool>` | `ProtocolHandler.instance.register(scheme)` returns `bool` |
| `getInitialUrl()` | Same `Future<String?>` method | `ProtocolHandler.instance.getInitialUrl()` returns `String?` |
| `onUrlReceived` | Same broadcast `Stream<String?>`; only non-null URLs are emitted | `addListener((event) { if (event is ProtocolUrlReceivedEvent) ... })` |
| `ProtocolListener.onProtocolUrlReceived(String url)` | Same mixin and callback | Read `ProtocolUrlReceivedEvent.url` in the callback |
| `addListener(listener)` / `removeListener(listener)` | Same object-based methods | Save the `ListenerId` returned by `addListener`; pass it to `removeListener` |
| `listeners` | Snapshot of registered `ProtocolListener` objects | Keep your own collection of returned listener IDs |
| `hasListeners` | Whether any `ProtocolListener` is attached; independent of stream subscribers | Inspect your own listener-ID collection |

Code that ignored the old `register()` result can continue to await it. Code
typed as `Future<void> Function(String)` must change to `Future<bool> Function(String)`.
The result means runtime registration on unpackaged Windows and declaration
validation on Android/iOS/macOS. It does not change the user's default app on macOS.

## Platform setup

### Android

Keep the VIEW filter inside the exported Flutter activity in
`android/app/src/main/AndroidManifest.xml`, use `singleTop` for delivery to the
existing foreground activity, and disable Flutter's own deep-link routing when
the plugin handles navigation:

```xml
<activity android:name=".MainActivity"
    android:exported="true" android:launchMode="singleTop">
    <meta-data android:name="flutter_deeplinking_enabled" android:value="false" />
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="myprotocol" />
    </intent-filter>
</activity>
```

Merge this into your existing activity; keep its theme, configuration and launcher
filter. `register()` validates the declared scheme; it cannot add an intent filter
at runtime. The plugin forwards the launch intent and `onNewIntent`. This feature
does not configure verified HTTPS Android App Links.

### iOS and macOS

Add the following to **each target's** `Runner/Info.plist`
(`ios/Runner/Info.plist` and `macos/Runner/Info.plist`):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.example.myapp</string>
        <key>CFBundleURLSchemes</key>
        <array><string>myprotocol</string></array>
    </dict>
</array>
```

On **iOS**, also disable Flutter's own routing:

```xml
<key>FlutterDeepLinkingEnabled</key>
<false/>
```

Keep Flutter's generated plugin registration. iOS supports the Flutter application
delegate and scene delegate URL callbacks; custom delegates must forward lifecycle
callbacks to Flutter. macOS loads the core early to capture its URL Apple event.
Neither platform adds URL schemes to the bundle at runtime. HTTPS Universal Links
and their associated-domain configuration are outside this migration.

See Flutter's [deep-link handler configuration](https://docs.flutter.dev/ui/navigation/deep-linking).

### Windows (unpackaged)

Replace the old `protocol_handler_windows/...` include and
`FindWindow` / `DispatchToProtocolHandler` block in `windows/runner/main.cpp`:

```cpp
#include <protocol_handler/protocol_handler_plugin_c_api.h>

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                     _In_ wchar_t* command_line, _In_ int show_command) {
  if (ProtocolHandlerForwardToRunningInstance()) {
    return EXIT_SUCCESS;
  }
  // Keep the rest of your Flutter runner here.
}
```

Call the helper **before creating the Flutter engine or window**. It forwards a
URL to the already-running instance of the same executable and exits the second
instance. It does not enforce single-instance behavior for launches without a URL.
Keep generated plugin registration and the runner's inclusion of
`flutter/generated_plugins.cmake`, which links `protocol_handler_plugin`.
`register()` writes the current user's `HKCU\Software\Classes\<scheme>` entry;
no administrator rights are required. Register again when the installed executable
path changes.

### Windows (MSIX)

Keep the runner forwarding helper above. Declare the scheme in the package
manifest instead of writing runtime registration. With the `msix` packaging tool:

```yaml
msix_config:
  protocol_activation: myprotocol
```

The generated application manifest must include a `uap:Extension` with
`Category="windows.protocol"` and `<uap:Protocol Name="myprotocol" />`.
See Microsoft's [protocol manifest reference](https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/uapmanifestschema/element-uap-protocol).
`register()` returns **false inside an MSIX package**, even when manifest activation
is correctly configured. Do not treat that return value as a reason to disable URL
listeners. Validate the installed package's activation separately from an unpackaged
debug build.

## Initial URL, incoming events and cleanup

The [example](example/lib/main.dart) demonstrates registration, initial URL reads,
incoming events, listener inspection and removal in `dispose()`. For stream-based
code, retain and cancel the subscription:

```dart
import 'dart:async';
import 'package:protocol_handler/protocol_handler.dart';

class LinkSession {
  StreamSubscription<String?>? _subscription;

  Future<void> start(void Function(String) receive) async {
    await protocolHandler.register('myprotocol');
    // Subscribe before reading, so a late launch URL cannot be missed.
    _subscription = protocolHandler.onUrlReceived.listen((url) {
      if (url != null) receive(url);
    });
    final initial = await protocolHandler.getInitialUrl();
    if (initial != null) receive(initial);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
```

Call `start` once per session. Make navigation idempotent if your application reads
the initial URL again: it remains available for the process lifetime. Normally the
initial URL is read explicitly, not repeated as an event. If an initial read returned
null before the OS delivered the launch URL, the later URL is both stored as the
initial value and emitted as an event. Do not globally deduplicate all identical
strings: opening the same URL twice while running represents two activations.

With no stream subscribers or listeners, the core queues up to 32 URLs, dropping
the oldest on overflow; the first subscriber receives them in order. `listeners`
is a snapshot, so clearing it does not unsubscribe anything. Use `removeListener`
and cancel stream subscriptions. Stream subscribers and `ProtocolListener` objects
share one native subscription.

## Limits and verification

Android, iOS, macOS and Windows are supported. Linux, web and OpenHarmony are not
supported by this plugin. There is no unregister API, matching 0.2.x; Windows
registry cleanup belongs to your installer. Android restores after process death
require application-specific lifecycle testing; reopening an ordinary recent task
is filtered to avoid replaying the original launch intent.

The workspace keeps [repeatable OS-delivery tests and per-platform results](https://github.com/libnativeapi/nativeapi/blob/main/tools/gui/protocol_handler_verification.md).
These distinguish simulator coverage, desktop runs and packaged activation coverage.
