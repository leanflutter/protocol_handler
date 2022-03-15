import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:protocol_handler/protocol_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Stream<String?> _protocolStream;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    _protocolStream = protocolHandler.register(protocol: 'myprotocol');
    _protocolStream.listen((event) {
      print(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(),
        ),
      ),
    );
  }
}
