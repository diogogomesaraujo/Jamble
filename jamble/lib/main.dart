import 'package:flutter/cupertino.dart';
import 'package:frontend/screens/edit_profile_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/signup_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts for Poppins

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFFEA57D),
        textTheme: CupertinoTextThemeData(
          primaryColor: const Color(0xFF3E111B),
          textStyle: GoogleFonts.poppins(), // Use Poppins font globally
        ),
      ),
      home: SignUpScreen(),
    );
  }
}
