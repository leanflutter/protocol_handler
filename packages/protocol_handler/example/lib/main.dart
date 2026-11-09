import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:protocol_handler/protocol_handler.dart';

/// The scheme the example declares in its Info.plist files and Android
/// manifest, and registers on Windows.
const kScheme = 'myprotocol';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Writes the registration on Windows; elsewhere it reports whether the app
  // package declares the scheme.
  await protocolHandler.register(kScheme);
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'protocol_handler example',
      theme: ThemeData(colorSchemeSeed: const Color(0xff416ff4)),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ProtocolListener {
  bool? _isRegistered;
  String? _initialUrl;
  final List<String> _receivedUrls = [];

  @override
  void initState() {
    super.initState();
    protocolHandler.addListener(this);
    _init();
  }

  @override
  void dispose() {
    // Listener cleanup: a removed listener is never called again.
    protocolHandler.removeListener(this);
    super.dispose();
  }

  Future<void> _init() async {
    final isRegistered = await protocolHandler.register(kScheme);
    final initialUrl = await protocolHandler.getInitialUrl();
    if (!mounted) return;
    setState(() {
      _isRegistered = isRegistered;
      _initialUrl = initialUrl;
    });
  }

  @override
  void onProtocolUrlReceived(String url) {
    // A launch URL the system delivered after _init read it arrives here too.
    protocolHandler.getInitialUrl().then((initialUrl) {
      if (mounted) setState(() => _initialUrl = initialUrl);
    });
    setState(() => _receivedUrls.insert(0, url));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Url received: $url')));
  }

  void _setListening(bool isListening) {
    if (isListening) {
      // URLs that arrived while no listener was registered are delivered now.
      protocolHandler.addListener(this);
    } else {
      protocolHandler.removeListener(this);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('protocol_handler example')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('register'),
            subtitle: Text('$kScheme → ${_isRegistered ?? '…'}'),
          ),
          ListTile(
            title: const Text('getInitialUrl'),
            subtitle: Text(_initialUrl ?? '(none)'),
            onTap: _init,
          ),
          SwitchListTile(
            title: const Text('Listening'),
            subtitle: Text(
              protocolHandler.hasListeners
                  ? '${protocolHandler.listeners.length} listener(s)'
                  : 'URLs are queued until a listener is added',
            ),
            value: protocolHandler.listeners.contains(this),
            onChanged: _setListening,
          ),
          const _SectionTitle('Test commands (tap to copy)'),
          for (final command in _testCommands())
            ListTile(
              dense: true,
              title: Text(
                command,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
              onTap: () {
                Clipboard.setData(ClipboardData(text: command));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Copied to clipboard')),
                );
              },
            ),
          const _SectionTitle('Received urls'),
          for (final url in _receivedUrls) ListTile(title: Text(url)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

/// Commands that open a URL of [kScheme] on the current platform.
List<String> _testCommands() {
  var prefix = '';
  var suffix = '';
  if (Platform.isIOS) {
    prefix = 'xcrun simctl openurl booted';
  } else if (Platform.isAndroid) {
    prefix =
        "adb shell 'am start -a android.intent.action.VIEW"
        ' -c android.intent.category.BROWSABLE -d';
    suffix = "'";
  } else if (Platform.isMacOS) {
    prefix = 'open';
  } else if (Platform.isWindows) {
    prefix = 'start ""';
  } else {
    return const [];
  }
  const urls = [
    '$kScheme://host/path/subpath',
    '$kScheme://example.com/path/portion/?uid=123&token=abc',
    '$kScheme://example.com/?addr=1%20Nowhere%20Rd&emoji=%F0%9F%98%82',
  ];
  return [for (final url in urls) '$prefix "$url"$suffix'];
}
