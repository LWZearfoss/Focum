import 'package:flutter/material.dart';

import 'package:focum/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF576490),
        canvasColor: Color(0xFFC9CAD9),
        buttonColor: Color(0xFF7184AB),
      ),
      home: LoginPage(),
    );
  }
}
