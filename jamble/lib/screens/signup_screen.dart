import 'package:flutter/cupertino.dart';
import 'package:frontend/services/spotify.dart'; // Import SpotifyService
import 'package:frontend/services/register.dart'; // Import RegisterService
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
  bool isSignUpLoading = false;
  bool isSpotifyLoading = false;
  bool isSignUpButtonPressed = false;
  bool isSpotifyButtonPressed = false;
  
  final SpotifyService spotifyService = SpotifyService();
  final RegisterService registerService = RegisterService();

  @override
  void initState() {
    super.initState();
    _verifyTokenAndNavigate(); // Check for existing Spotify token and navigate if available
  }

  @override
  void dispose() {
    spotifyService.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check if a Spotify token exists and navigate to the main page
  Future<void> _verifyTokenAndNavigate() async {
    setState(() {
      isLoading = true;
    });

    await spotifyService.checkExistingToken(context); // Pass the context here

    setState(() {
      isLoading = false;
    });
  }

  // Register user through custom registration process
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
      isSignUpLoading = true;
      errorMessage = '';
    });

    try {
      final token = await registerService.registerUser(
        username: username,
        email: email,
        password: password,
      );

      if (token != null) {
        _verifyTokenAndNavigate(); // After registration, verify token and navigate
      } else {
        setState(() {
          errorMessage = 'Registration failed: Unable to get token';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
        isSignUpLoading = false;
      });
    }
  }

  // Spotify login integration
  Future<void> _loginWithSpotify() async {
    setState(() {
      isLoading = true;
      isSpotifyLoading = true;
      errorMessage = '';
    });
    try {
      await spotifyService.loginWithSpotify(context); // Pass the context here for navigation
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

  void _onSignUpButtonPressed(bool isPressed) {
    setState(() {
      isSignUpButtonPressed = isPressed;
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
                    _buildTextField("Username", _usernameController),
                    SizedBox(height: 20),
                    _buildTextField("Email Address", _emailController),
                    SizedBox(height: 20),
                    _buildPasswordTextField("Password", _passwordController),
                    SizedBox(height: 30),
                    AnimatedOpacity(
                      opacity: errorMessage.isNotEmpty ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 300),
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildSignUpButton(),
                    SizedBox(height: 20),
                    _buildDividerWithText(),
                    SizedBox(height: 20),
                    _buildSpotifyLoginButton(),
                    SizedBox(height: 30),
                    _buildAlreadyHaveAccount(),
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
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: darkRed,
          ),
        ),
        CupertinoTextField(
          controller: controller,
          placeholder: "Enter $label",
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
      ],
    );
  }

  Widget _buildPasswordTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: darkRed,
          ),
        ),
        CupertinoTextField(
          controller: controller,
          placeholder: label,
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
      ],
    );
  }

  Widget _buildSignUpButton() {
    return GestureDetector(
      onTapDown: (_) => _onSignUpButtonPressed(true),
      onTapUp: (_) => _onSignUpButtonPressed(false),
      onTapCancel: () => _onSignUpButtonPressed(false),
      onTap: _registerUser, // Register the user when button is pressed
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSignUpButtonPressed ? peach.withOpacity(0.8) : peach,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: peach.withOpacity(0.8),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: isSignUpLoading
              ? CupertinoActivityIndicator()
              : Text(
                  "Sign Up",
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
    );
  }

  Widget _buildSpotifyLoginButton() {
    return GestureDetector(
      onTapDown: (_) => _onSpotifyButtonPressed(true),
      onTapUp: (_) => _onSpotifyButtonPressed(false),
      onTapCancel: () => _onSpotifyButtonPressed(false),
      onTap: _loginWithSpotify, // Trigger Spotify login on button press
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSpotifyButtonPressed
              ? const Color.fromARGB(215, 255, 255, 255)
              : white100,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: grey.withOpacity(0.7),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
        child: Center(
          child: isSpotifyLoading
              ? CupertinoActivityIndicator()
              : Row(
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
        ),
      ),
    );
  }

  Widget _buildAlreadyHaveAccount() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/login'); // Navigate to login screen
        },
        child: RichText(
          text: TextSpan(
            text: "Already have an account? ",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: darkRed.withOpacity(0.6),
            ),
            children: [
              TextSpan(
                text: "Sign in!",
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
