import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Define colors based on the provided palette
const Color darkRed = Color(0xFF3E111B);
const Color grey = Color(0xFFDDDDDD);
const Color peach = Color(0xFFFEA57D);
const Color white100 = Color(0xFFFFFFFF);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailOrUsernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<String> getBackendUrl() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (!androidInfo.isPhysicalDevice) {
        return 'http://10.0.2.2:3000'; // Android emulator
      } else {
        return 'http://your-local-ip:3000'; // Android physical device
      }
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        return 'http://localhost:3000'; // iOS simulator
      } else {
        return 'http://your-local-ip:3000'; // iOS physical device
      }
    } else {
      return 'http://your-local-ip:3000'; // Fallback for unknown platforms
    }
  }

  Future<void> _loginUser() async {
    String emailOrUsername = _emailOrUsernameController.text;
    String password = _passwordController.text;

    if (emailOrUsername.isEmpty || password.isEmpty) {
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
      var response = await http.post(
        Uri.parse('$backendUrl/api/users/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'emailOrUsername': emailOrUsername,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        // Handle successful login (e.g., navigate to home screen or store token)
      } else {
        setState(() {
          errorMessage = 'Login failed: ${response.body}';
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

  Future<void> _loginWithSpotify() async {
    final backendUrl = await getBackendUrl();
    final spotifyAuthUrl = '$backendUrl/api/auth/spotify';

    if (await canLaunchUrl(Uri.parse(spotifyAuthUrl))) {
      await launchUrl(Uri.parse(spotifyAuthUrl),
          mode: LaunchMode.externalApplication);
    } else {
      setState(() {
        errorMessage = 'Could not launch Spotify login.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flower SVG aligned on top of the title and resized
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
                    const SizedBox(height: 8),
                    const Text(
                      "Hello again!",
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
              const SizedBox(height: 10),

              Text(
                "The best way to get the most out of our app is to participate actively.",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: darkRed.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 30),

              // Username or Email field
              const Text(
                "Username or Email",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: darkRed,
                ),
              ),
              CupertinoTextField(
                controller: _emailOrUsernameController,
                placeholder: "Sample@domain.com",
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                placeholderStyle: TextStyle(
                  color: darkRed.withOpacity(0.5),
                ),
                style: const TextStyle(color: darkRed),
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 20),

              // Password field
              const Text(
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
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                placeholderStyle: TextStyle(
                  color: darkRed.withOpacity(0.5),
                ),
                style: const TextStyle(color: darkRed),
                decoration: BoxDecoration(
                  border: Border.all(color: grey),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 30),

              // Error message
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

              // Login Button
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
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: CupertinoButton(
                          onPressed: _loginUser,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: white100,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              // Spotify Button
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
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                    onPressed: _loginWithSpotify, // Handle Spotify login here
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(FontAwesomeIcons.spotify, color: CupertinoColors.activeGreen),
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
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
