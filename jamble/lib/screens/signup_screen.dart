import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

// Define colors based on the provided palette
const Color darkRed = Color(0xFF3E111B);
const Color grey = Color(0xFFDDDDDD);
const Color peach = Color(0xFFFEA57D);
const Color white100 = Color(0xFFFFFFFF);

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  // Define the MethodChannel to receive URL from AppDelegate
  static const MethodChannel _channel = MethodChannel('app_links');

  @override
  void initState() {
    super.initState();
    _listenForAppLinks();
  }

  // Listen for incoming app links
  void _listenForAppLinks() {
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == "getAppLink") {
        final String url = call.arguments;
        _processAuthCode(Uri.parse(url));
      }
    });
  }

  // Function to process the auth code from Spotify callback URL
  void _processAuthCode(Uri uri) {
    final String? code = uri.queryParameters['code'];
    if (code != null) {
      _exchangeCodeForToken(code);
    } else {
      setState(() {
        errorMessage = 'Spotify login failed: No code in callback.';
      });
    }
  }

  // Function to exchange the auth code for access token
  Future<void> _exchangeCodeForToken(String code) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final backendUrl = await getBackendUrl(); // Your server URL
    final tokenUrl = '$backendUrl/api/auth/spotify/callback';

    try {
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': code}),
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
          errorMessage = 'Spotify login successful!';
        });
        // Handle successful Spotify login (e.g., saving token)
      } else {
        setState(() {
          errorMessage = 'Spotify login failed: ${response.body}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  // Function to launch Spotify login
  Future<void> _loginWithSpotify() async {
    final backendUrl = await getBackendUrl();
    final spotifyAuthUrl = '$backendUrl/api/auth/spotify';

    if (await canLaunchUrl(Uri.parse(spotifyAuthUrl))) {
      await launchUrl(Uri.parse(spotifyAuthUrl), mode: LaunchMode.externalApplication);
    } else {
      setState(() {
        errorMessage = 'Could not launch Spotify login.';
      });
    }
  }

  // Function to get the backend URL based on the platform (local or production)
  Future<String> getBackendUrl() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (!androidInfo.isPhysicalDevice) {
        return 'http://10.0.2.2:3000'; // Android emulator
      } else {
        return 'http://your-local-ip:3000'; // Android physical device
      }
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        return 'http://localhost:3000'; // iOS simulator
      } else {
        return 'http://your-local-ip:3000'; // iOS physical device
      }
    } else {
      return 'http://your-local-ip:3000'; // Fallback for unknown platforms
    }
  }

  Future<void> _registerUser() async {
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please fill all fields';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final backendUrl = await getBackendUrl();
      final response = await http.post(
        Uri.parse('$backendUrl/api/users/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isLoading = false;
        });
        // Handle successful registration
      } else {
        setState(() {
          errorMessage = 'Registration failed: ${response.body}';
          isLoading = false;
        });
      }
    } on SocketException {
      setState(() {
        errorMessage = 'Network error. Please try again.';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      'assets/flower.svg',
                      height: 50,
                      width: 50,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Let’s sign you up!",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        color: darkRed,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Create an account to ramble about your favourite jams with your friends!",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: darkRed.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 30),

              // Username field
              Text(
                "Username",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: darkRed,
                ),
              ),
              CupertinoTextField(
                controller: _usernameController,
                placeholder: "samplename",
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                placeholderStyle: TextStyle(
                  color: darkRed.withOpacity(0.5),
                ),
                style: TextStyle(color: darkRed),
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(height: 20),

              // Email field
              Text(
                "Email Address",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: darkRed,
                ),
              ),
              CupertinoTextField(
                controller: _emailController,
                placeholder: "Sample@domain.com",
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                placeholderStyle: TextStyle(
                  color: darkRed.withOpacity(0.5),
                ),
                style: TextStyle(color: darkRed),
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(height: 20),

              // Password field
              Text(
                "Password",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: darkRed,
                ),
              ),
              CupertinoTextField(
                controller: _passwordController,
                placeholder: "Password",
                obscureText: true,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                placeholderStyle: TextStyle(
                  color: darkRed.withOpacity(0.5),
                ),
                style: TextStyle(color: darkRed),
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(height: 30),

              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: CupertinoColors.systemRed,
                      fontSize: 14,
                    ),
                  ),
                ),

              Center(
                child: isLoading
                    ? CupertinoActivityIndicator()
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: peach,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: peach.withOpacity(0.8),
                              blurRadius: 15,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CupertinoButton(
                          onPressed: _registerUser,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: white100,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          color: null,
                        ),
                      ),
              ),
              SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1.0,
                      color: darkRed.withOpacity(0.2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      "or",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: darkRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1.0,
                      color: darkRed.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: white100,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: grey.withOpacity(0.7),
                        blurRadius: 15,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    onPressed: _loginWithSpotify,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.spotify,
                            color: CupertinoColors.activeGreen),
                        SizedBox(width: 10),
                        Text(
                          "Continue with Spotify",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: darkRed,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    color: null,
                  ),
                ),
              ),
              SizedBox(height: 30),

              Center(
                child: GestureDetector(
                  onTap: () {
                    // Handle sign-in navigation
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "You don’t have an account yet? ",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: darkRed.withOpacity(0.6),
                      ),
                      children: [
                        TextSpan(
                          text: "Sign up!",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: darkRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
