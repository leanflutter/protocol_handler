import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:preference_list/preference_list.dart';
import 'package:protocol_handler/protocol_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with ProtocolListener {
  final List<String> _receivedUrlList = [];

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

  Widget _buildBody(BuildContext context) {
    return PreferenceList(
      children: <Widget>[
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
    String log = 'Url received: $url)';
    BotToast.showText(text: log);

    setState(() {
      _receivedUrlList.add(url);
    });
  }
}
