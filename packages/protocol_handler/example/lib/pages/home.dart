import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:window_manager/window_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ProtocolListener {
  bool _isAlwaysOnTop = false;

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
    _initialUrl = await protocolHandler.getInitialUrl();
    setState(() {});
  }

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
        PreferenceListSection(
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
