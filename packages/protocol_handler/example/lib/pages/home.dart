import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preference_list/preference_list.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:uni_platform/uni_platform.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ProtocolListener {
  bool _isAlwaysOnTop = false;
  List<String> _testCmds = [];

  String? _initialUrl = '';
  final List<String> _receivedUrlList = [];

  @override
  void initState() {
    protocolHandler.addListener(this);
    super.initState();

    _init();
  }

  @override
  void dispose() {
    protocolHandler.removeListener(this);
    super.dispose();
  }

  Future<void> _init() async {
    _testCmds = _getTestCmds() ?? [];
    if (kDebugMode) {
      print('Test commands:');
      for (String testCmd in _testCmds) {
        print(testCmd);
      }
    }
    _initialUrl = await protocolHandler.getInitialUrl();
    setState(() {});
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        UniPlatform.select<Widget>(
          desktop: PreferenceListSection(
            children: [
              PreferenceListSwitchItem(
                title: const Text('setAlwaysOnTop'),
                value: _isAlwaysOnTop,
                onChanged: (newValue) async {
                  _isAlwaysOnTop = newValue;
                  await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
                  setState(() {});
                },
              ),
            ],
          ),
          otherwise: Container(),
        ),
        PreferenceListSection(
          title: const Text('Test cmds'),
          children: [
            if (_testCmds.isNotEmpty)
              for (String testCmd in _testCmds)
                PreferenceListItem(
                  padding: const EdgeInsets.all(12),
                  title: Text(testCmd),
                  accessoryView: Container(),
                  onTap: () async {
                    Clipboard.setData(
                      ClipboardData(text: testCmd),
                    );
                    BotToast.showText(text: 'Copied to clipboard');
                  },
                ),
          ],
        ),
        PreferenceListSection(
          title: const Text('initialUrl'),
          children: [
            PreferenceListItem(
              padding: const EdgeInsets.all(12),
              title: Text('$_initialUrl'),
              accessoryView: Container(),
              onTap: () async {
                _initialUrl = await protocolHandler.getInitialUrl();
                setState(() {});
              },
            ),
          ],
        ),
        PreferenceListSection(
          title: const Text('Received urls'),
          children: [
            for (String url in _receivedUrlList)
              PreferenceListItem(
                padding: const EdgeInsets.all(12),
                title: Text(url),
                accessoryView: Container(),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
      ),
      body: _buildBody(context),
    );
  }

  @override
  void onProtocolUrlReceived(String url) {
    String log = 'Url received: $url';
    BotToast.showText(text: log);

    setState(() {
      _receivedUrlList.add(url);
    });
  }
}

/// Returns a list of test commands to be displayed in the UI.
List<String>? _getTestCmds() {
  late final String cmd;
  var cmdSuffix = '';

  const plainPath = 'path/subpath';
  const args = 'path/portion/?uid=123&token=abc';
  const emojiArgs =
      '?arr%5b%5d=123&arr%5b%5d=abc&addr=1%20Nowhere%20Rd&addr=Rand%20City%F0%9F%98%82';

  if (UniPlatform.isWeb) {
    return [plainPath, args, emojiArgs];
  }

  if (UniPlatform.isIOS) {
    cmd = '/usr/bin/xcrun simctl openurl booted';
  } else if (UniPlatform.isAndroid) {
    cmd = '\$ANDROID_HOME/platform-tools/adb shell \'am start'
        ' -a android.intent.action.VIEW'
        ' -c android.intent.category.BROWSABLE -d';
    cmdSuffix = "'";
  } else if (UniPlatform.isMacOS) {
    cmd = 'open';
  } else if (UniPlatform.isWindows) {
    cmd = 'start';
  } else {
    return null;
  }

  return [
    '$cmd "myprotocol://host/$plainPath"$cmdSuffix',
    '$cmd "myprotocol://example.com/$args"$cmdSuffix',
    '$cmd "myprotocol://example.com/$emojiArgs"$cmdSuffix',
    '$cmd "myprotocol://@@malformed.invalid.url/path?"$cmdSuffix',
  ];
}
