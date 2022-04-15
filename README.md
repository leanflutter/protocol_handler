# protocol_handler

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/protocol_handler.svg
[pub-url]: https://pub.dev/packages/protocol_handler

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

This plugin allows Flutter **desktop** apps to register and handle custom protocols (i.e. deep linking).

---

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [protocol_handler](#protocol_handler)
  - [Platform Support](#platform-support)
    - [Desktop](#desktop)
    - [Mobile](#mobile)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [Usage](#usage)
        - [macOS](#macos)
        - [Windows](#windows)
    - [Listening events](#listening-events)
  - [Who's using it?](#whos-using-it)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

### Desktop

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ➖   |   ✔️   |    ✔️    |

### Mobile

| Android |  iOS  |
| :-----: | :---: |
|    ➖    |   ✔️   |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  protocol_handler: ^0.1.1
```

Or

```yaml
dependencies:
  protocol_handler:
    git:
      url: https://github.com/leanflutter/protocol_handler.git
      ref: main
```

### Usage

##### macOS

Change the file `macos/Runner/Info.plist` as follows:

```diff
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIconFile</key>
	<string></string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>$(FLUTTER_BUILD_NAME)</string>
	<key>CFBundleVersion</key>
	<string>$(FLUTTER_BUILD_NUMBER)</string>
	<key>LSMinimumSystemVersion</key>
	<string>$(MACOSX_DEPLOYMENT_TARGET)</string>
	<key>NSHumanReadableCopyright</key>
	<string>$(PRODUCT_COPYRIGHT)</string>
	<key>NSMainNibFile</key>
	<string>MainMenu</string>
+	<key>CFBundleURLTypes</key>
+	<array>
+		<dict>
+			<key>CFBundleTypeRole</key>
+			<string>Editor</string>
+			<key>CFBundleURLName</key>
+			<string></string>
+			<key>CFBundleURLSchemes</key>
+			<array>
+				<string>myprotocol</string>
+			</array>
+		</dict>
+	</array>
	<key>NSPrincipalClass</key>
	<string>NSApplication</string>
</dict>
</plist>
}
```

##### Windows

Change the file `windows/runner/main.cpp` as follows:

```diff
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

+#include <protocol_handler/protocol_handler_plugin.h>

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
+  HWND hwnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"protocol_handler_example");
+  if (hwnd != NULL) {
+    DispatchToProtocolHandler(hwnd);
+
+    ::ShowWindow(hwnd, SW_NORMAL);
+    ::SetForegroundWindow(hwnd);
+    return EXIT_FAILURE;
+  }

  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.CreateAndShow(L"protocol_handler_example", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
```

```dart
import 'package:protocol_handler/protocol_handler.dart';

void main() async {
  // Must add this line.
  WidgetsFlutterBinding.ensureInitialized();

  // Register a custom protocol
  // For macOS platform needs to declare the scheme in ios/Runner/Info.plist
  await protocolHandler.register('myprotocol');

  runApp(MyApp());
}
```

### Listening events

```dart
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ProtocolListener {
  @override
  void initState() {
    protocolHandler.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    protocolHandler.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ...
  }

  @override
  void onProtocolUrlReceived(String url) {
    String log = 'Url received: $url)';
    print(log);
  }
}
```

> Please see the example app of this plugin for a full example.

## Who's using it?

- [Biyi](https://biyidev.com/) - A convenient translation and dictionary app.

## License

[MIT](./LICENSE)
