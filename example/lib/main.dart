import 'package:flutter/material.dart';
import 'package:zpdl_studio_media_plugin_example/scaffold/home/home_scaffold.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: HomeScaffold(),
    );
  }
}
