import 'package:flutter/cupertino.dart';
import 'package:frontend/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFFF4A261),
        textTheme: CupertinoTextThemeData(
          primaryColor: Color(0xFF4A2F25),
          textStyle: TextStyle(
            fontFamily: 'Inter',
          ),
        ),
      ),
      home: LoginPage(),
    );
  }
}
