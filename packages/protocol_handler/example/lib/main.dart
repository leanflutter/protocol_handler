import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:protocol_handler_example/pages/home.dart';
import 'package:uni_platform/uni_platform.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UniPlatform.call<Future<void>>(
    desktop: () async {
      await windowManager.ensureInitialized();
      const windowOptions = WindowOptions(
        size: Size(1024, 768),
        center: true,
      );
      windowManager.waitUntilReadyToShow(
        windowOptions,
        () {
          windowManager.show();
        },
      );
      // Register a custom protocol
      await protocolHandler.register('myprotocol');
    },
    otherwise: () => Future.value(),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xff416ff4),
        canvasColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xffF7F9FB),
        dividerColor: Colors.grey.withOpacity(0.3),
      ),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      home: const HomePage(),
    );
  }
}
