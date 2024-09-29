import 'package:flutter/cupertino.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/signup_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts for Poppins

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
          primaryColor: Color(0xFF3E111B),
          textStyle: GoogleFonts.poppins(), // Use Poppins font globally
        ),
      ),
      home: SignUpScreen(),
    );
  }
}
