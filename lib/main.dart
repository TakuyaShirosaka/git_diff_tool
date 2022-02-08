
import 'package:flutter/material.dart';
import 'package:git_diff_tool/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Git DIFF TOOL',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: HomePageWidget(title: 'Git DIFF TOOL'),
    );
  }
}
