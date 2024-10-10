import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/services/spotify.dart'; // Import SpotifyService
import 'package:frontend/services/login.dart'; // Import LoginService
import 'dart:async';
import 'dart:io';

const Color darkRed = Color(0xFF3E111B);
const Color grey = Color(0xFFDDDDDD);
const Color peach = Color(0xFFFEA57D);
const Color white100 = Color(0xFFFFFFFF);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final TextEditingController _emailOrUsernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  bool isSpotifyLoading = false;
  bool isLoginButtonPressed = false;
  bool isSpotifyButtonPressed = false;
  final SpotifyService spotifyService = SpotifyService();
  final LoginService loginService = LoginService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _verifyTokenAndNavigate(); // Centralized token verification
    _initSpotifyService();
  }

  @override
  void dispose() {
    spotifyService.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      spotifyService.initDeepLinkHandlers(_handleDeepLink);
    }
  }

  void _initSpotifyService() {
    spotifyService.initDeepLinkHandlers(_handleDeepLink);
  }

  void _handleDeepLink(String url) async {
    await spotifyService.handleDeepLink(url, () {
      _verifyTokenAndNavigate(); // Use centralized verification after handling deep link
    });
  }

  Future<void> _verifyTokenAndNavigate() async {
    setState(() {
      isLoading = true;
    });

    final tokenExists = await spotifyService.checkExistingToken();
    if (tokenExists) {
      _navigateToMainPage();
    }

    setState(() {
      isLoading = false;
    });
  }

  void _navigateToMainPage() {
    //Navigator.pushReplacementNamed(context, '/');
    print("Navigating to main page");
  }

  Future<void> _loginUser() async {
    String emailOrUsername = _emailOrUsernameController.text;
    String password = _passwordController.text;

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final result = await loginService.loginUser(emailOrUsername, password);

      if (result == null) {
        _verifyTokenAndNavigate(); // Use the centralized method if login is successful
      } else {
        setState(() {
          errorMessage = result; // Display the error message if login failed
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loginWithSpotify() async {
    setState(() {
      isLoading = true;
      isSpotifyLoading = true;
      errorMessage = '';
    });
    try {
      await spotifyService.loginWithSpotify();
      _verifyTokenAndNavigate(); // Use the centralized method
    } catch (e) {
      setState(() {
        errorMessage = 'Error launching Spotify login: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
        isSpotifyLoading = false;
      });
    }
  }

  void _onLoginButtonPressed(bool isPressed) {
    setState(() {
      isLoginButtonPressed = isPressed;
    });
  }

  void _onSpotifyButtonPressed(bool isPressed) {
    setState(() {
      isSpotifyButtonPressed = isPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: isLoading
          ? Center(child: CupertinoActivityIndicator())
          : Center(
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
                    _buildTextField("Username or Email", _emailOrUsernameController),
                    const SizedBox(height: 20),
                    _buildPasswordTextField("Password", _passwordController),
                    const SizedBox(height: 30),
                    AnimatedOpacity(
                      opacity: errorMessage.isNotEmpty ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        errorMessage,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildLoginButton(),
                    const SizedBox(height: 20),
                    _buildDividerWithText(),
                    const SizedBox(height: 20),
                    _buildSpotifyLoginButton(),
                    const SizedBox(height: 30),
                    _buildSignUpPrompt(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: darkRed,
          ),
        ),
        CupertinoTextField(
          controller: controller,
          placeholder: "Enter $label",
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
      ],
    );
  }

  Widget _buildPasswordTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: darkRed,
          ),
        ),
        CupertinoTextField(
          controller: controller,
          placeholder: label,
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
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTapDown: (_) => _onLoginButtonPressed(true),
      onTapUp: (_) => _onLoginButtonPressed(false),
      onTapCancel: () => _onLoginButtonPressed(false),
      onTap: _loginUser,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isLoginButtonPressed ? peach.withOpacity(0.8) : peach,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: peach.withOpacity(0.8),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: isLoading
              ? CupertinoActivityIndicator()
              : const Text(
                  "Login",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: white100,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDividerWithText() {
    return Row(
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
            style: const TextStyle(
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
    );
  }

  Widget _buildSpotifyLoginButton() {
    return GestureDetector(
      onTapDown: (_) => _onSpotifyButtonPressed(true),
      onTapUp: (_) => _onSpotifyButtonPressed(false),
      onTapCancel: () => _onSpotifyButtonPressed(false),
      onTap: _loginWithSpotify,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSpotifyButtonPressed ? const Color.fromARGB(215, 255, 255, 255) : white100,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: grey.withOpacity(0.7),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
        child: Center(
          child: isSpotifyLoading
              ? CupertinoActivityIndicator()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const FaIcon(FontAwesomeIcons.spotify, color: CupertinoColors.activeGreen),
                    const SizedBox(width: 10),
                    const Text(
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
    );
  }

  Widget _buildSignUpPrompt() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/signup'); // Navigate to signup screen
        },
        child: RichText(
          text: TextSpan(
            text: "Don't have an account yet? ",
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
    );
  }
}
