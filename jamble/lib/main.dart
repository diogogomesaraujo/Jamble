import 'package:flutter/cupertino.dart';
import 'package:frontend/screens/blank.dart';
import 'package:frontend/screens/edit_profile_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/signup_screen.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts for Poppins
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import secure storage for token management

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding for async code in main
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Delete any existing Spotify token on app initialization
  await secureStorage.deleteAll();

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
      initialRoute: '/signup', // Set the initial route
      routes: {
        '/signup': (context) => SignUpScreen(), // Sign-up screen
        '/login': (context) => LoginScreen(),   // Login screen
        '/edit-profile': (context) => EditProfileScreen(), // Edit profile screen
        '/': (context) => BlankScreen(), // Home screen
        // Add more routes as needed
      },
    );
  }
}
