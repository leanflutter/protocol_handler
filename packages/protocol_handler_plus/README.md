# protocol_handler_plus

[![pub version][pub-image]][pub-url]

[pub-image]: https://img.shields.io/pub/v/protocol_handler_plus.svg
[pub-url]: https://pub.dev/packages/protocol_handler_plus

This (PLUS) plugin allows Flutter apps to register and handle custom protocols (i.e. deep linking).

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Platform Support](#platform-support)
- [Quick Start](#quick-start)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Android](#android)
    - [iOS](#ios)
    - [macOS](#macos)
    - [Windows](#windows)
  - [Listening events](#listening-events)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Android | iOS | Linux | macOS | Windows |
| :-----: | :-: | :---: | :---: | :-----: |
|   ✔️    | ✔️  |  ➖   |  ✔️   |   ✔️    |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  protocol_handler_plus: ^`<LATEST_VERSION>`
```

### Usage

##### Android

Change the file `android/app/src/main/AndroidManifest.xml` as follows:

```diff
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="dev.stan_at_work.plugins.protocol_handler_plus_example">

    <application
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:label="protocol_handler_plus_example">
        <activity
            android:name=".MainActivity"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:exported="true"
            android:hardwareAccelerated="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
+            <intent-filter>
+                <action android:name="android.intent.action.VIEW" />
+
+                <category android:name="android.intent.category.DEFAULT" />
+                <category android:name="android.intent.category.BROWSABLE" />
+                <!-- Accepts URIs that begin with YOUR_SCHEME://YOUR_HOST -->
+                <data android:scheme="myprotocol" />
+            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

##### iOS

Change the file `ios/Runner/Info.plist` as follows:

```diff
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>Protocol Handler Plus</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>protocol_handler_plus_example</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>$(FLUTTER_BUILD_NAME)</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>CFBundleVersion</key>
	<string>$(FLUTTER_BUILD_NUMBER)</string>
	<key>LSRequiresIPhoneOS</key>
	<true/>
	<key>UILaunchStoryboardName</key>
	<string>LaunchScreen</string>
	<key>UIMainStoryboardFile</key>
	<string>Main</string>
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
	<key>UISupportedInterfaceOrientations</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UISupportedInterfaceOrientations~ipad</key>
	<array>
		<string>UIInterfaceOrientationPortrait</string>
		<string>UIInterfaceOrientationPortraitUpsideDown</string>
		<string>UIInterfaceOrientationLandscapeLeft</string>
		<string>UIInterfaceOrientationLandscapeRight</string>
	</array>
	<key>UIViewControllerBasedStatusBarAppearance</key>
	<false/>
</dict>
</plist>

```

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
```

##### Windows

Change the file `windows/runner/main.cpp` as follows:

```diff
#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include "flutter_window.h"
#include "utils.h"

+#include <protocol_handler_plus_windows/protocol_handler_plus_windows_plugin_c_api.h>

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
+  // Replace protocol_handler_plus_example with your_window_title.
+  HWND hwnd = ::FindWindow(L"FLUTTER_RUNNER_WIN32_WINDOW", L"protocol_handler_plus_example");
+  if (hwnd != NULL) {
+    DispatchToProtocolHandlerPlus(hwnd);
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
  if (!window.CreateAndShow(L"protocol_handler_plus_example", origin, size)) {
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

If you use `MSIX` to package your application, you need to add `protocol_activation` configuration in `msix_config`:

```yaml
msix_config:
  protocol_activation: myprotocol
```

> See this issue for details: [YehudaKremer/msix#187](https://github.com/YehudaKremer/msix/issues/187)

```dart
import 'package:protocol_handler_plus/protocol_handler_plus.dart';

void main() async {
  // Must add this line.
  WidgetsFlutterBinding.ensureInitialized();

  // Register a custom protocol
  // For macOS platform needs to declare the scheme in ios/Runner/Info.plist
  //
  // example:    myprotocol://
  await protocolHandlerPlus.register('myprotocol');

  runApp(MyApp());
}
```

### Listening events

```dart
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ProtocolListener {
  @override
  void initState() {
    protocolHandlerPlus.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    protocolHandlerPlus.removeListener(this);
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

## License

[MIT](./LICENSE)
