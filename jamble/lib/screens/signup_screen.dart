import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/screens/blank.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'dart:io';

const Color darkRed = Color(0xFF3E111B);
const Color grey = Color(0xFFDDDDDD);
const Color peach = Color(0xFFFEA57D);
const Color white100 = Color(0xFFFFFFFF);

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with WidgetsBindingObserver {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPlatformSpecificDeepLinkHandler(); // Initialize platform-specific deep link handler
    _initDeepLinkHandlers(); // Start listening for deep links
    _checkExistingToken(); // Check if a token exists
  }

  @override
  void dispose() {
    _linkSubscription?.cancel(); // Cancel the deep link subscription
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("App resumed, checking for deep links.");
      _initUriHandler(); // Recheck for deep links when app resumes
    }
  }

  void _initPlatformSpecificDeepLinkHandler() {
  const MethodChannel _channel = MethodChannel('uni_links/messages');

  _channel.setMethodCallHandler((MethodCall call) async {
    if (call.method == 'onDeepLinkReceived') {
      final String deepLink = call.arguments;
      debugPrint("Deep link received from native code: $deepLink");
      _handleDeepLink(deepLink);
    } else {
      debugPrint("Unknown method called from native: ${call.method}");
    }
  });
}

  // Initialize deep link handlers
  void _initDeepLinkHandlers() {
    debugPrint("Initializing deep link handlers");

    _initUriHandler().then((_) {
      debugPrint("Initial URI handler initialized");
    }).catchError((error) {
      debugPrint("Failed to initialize initial URI handler: $error");
    });

    _listenForDeepLinks();
  }

  /// Handle deep links on cold start or when the app resumes.
  Future<void> _initUriHandler() async {
    try {
      final Uri? initialURI = await getInitialUri(); // Check for the initial URI
      if (initialURI != null) {
        _handleDeepLink(initialURI.toString());
      }
    } catch (e) {
      debugPrint('Failed to receive initial URI: $e');
    }
  }

  /// Listen for real-time deep links during the app’s lifecycle.
  void _listenForDeepLinks() {
    if (_linkSubscription == null) {
      _linkSubscription = uriLinkStream.listen((Uri? link) {
        if (link != null) {
          debugPrint("Incoming deep link received: $link");
          _handleDeepLink(link.toString());
        }
      }, onError: (err) {
        setState(() {
          errorMessage = 'Error receiving deep link: $err';
          debugPrint("Error in deep link stream: $err");
        });
      }, cancelOnError: true); // Automatically cancels on error
    }
  }

  /// Handle the deep link, extract token, and navigate accordingly.
  void _handleDeepLink(String url) async {
    debugPrint("Handling deep link: $url");
    final Uri uri = Uri.parse(url);

    if (uri.scheme == 'myapp' && uri.host == 'callback') {
      final String? token = uri.queryParameters['token'];

      if (token != null) {
        debugPrint("Token found: $token");

        await secureStorage.write(key: 'spotify_token', value: token).then((_) {
          debugPrint("Token successfully stored: $token");
          _sendTokenToBackend(token);
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (context) => BlankScreen()),
          );
        }).catchError((error) {
          setState(() {
            errorMessage = 'Failed to store token: $error';
            debugPrint(errorMessage);
          });
        });
      } else {
        setState(() {
          errorMessage = 'Login failed: Missing token.';
          debugPrint("Login failed: Missing token.");
        });
      }
    } else {
      debugPrint("Unexpected deep link: $url");
    }
  }

  /// Send the token to the backend to complete the authentication process.
  Future<void> _sendTokenToBackend(String accessToken) async {
    final backendUrl = await getBackendUrl();
    final callbackUrl = '$backendUrl/api/auth/spotify/callback';

    try {
      final response = await http.post(
        Uri.parse(callbackUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'access_token': accessToken}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("Successfully synced with backend.");
      } else {
        debugPrint("Failed to sync with backend: ${response.body}");
        setState(() {
          errorMessage = 'Backend error: ${response.body}';
        });
      }
    } catch (e) {
      debugPrint("Error syncing with backend: $e");
      setState(() {
        errorMessage = 'Error syncing with backend: $e';
      });
    }
  }

  /// Check if a Spotify token already exists in secure storage.
  Future<void> _checkExistingToken() async {
    try {
      final token = await secureStorage.read(key: 'spotify_token');
      if (token != null) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error checking token: $e';
        debugPrint(errorMessage);
      });
    }
  }

  /// Initiate the Spotify login flow by launching the Spotify OAuth URL.
  Future<void> _loginWithSpotify() async {
    final backendUrl = await getBackendUrl();
    final spotifyAuthUrl = '$backendUrl/api/auth/spotify';

    try {
      final uri = Uri.parse(spotifyAuthUrl);

      if (await canLaunchUrl(uri)) {
        debugPrint("Launching Spotify auth URL: $spotifyAuthUrl");

        await launchUrl(uri, mode: LaunchMode.externalApplication).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            setState(() {
              errorMessage = 'Spotify login timeout. Please try again.';
            });
            debugPrint("TimeoutException: Spotify login URL timeout");
            throw TimeoutException("Spotify login URL timeout");
          },
        );
      } else {
        setState(() {
          errorMessage = 'Could not launch Spotify login.';
          debugPrint(errorMessage);
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error launching Spotify login: $e';
        debugPrint(errorMessage);
      });
    }
  }

  Future<String> getBackendUrl() async {
    const backendUrl = 'http://127.0.0.1:3000'; // Ensure this is always updated
    debugPrint("Using backend URL: $backendUrl");
    return backendUrl;
  }

  Future<void> _registerUser() async {
    final String username = _usernameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please fill all fields';
        debugPrint(errorMessage);
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
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          isLoading = false;
        });
        debugPrint("User registration successful, navigating to home.");
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          errorMessage = 'Registration failed: ${response.body}';
          isLoading = false;
          debugPrint(errorMessage);
        });
      }
    } on SocketException {
      setState(() {
        errorMessage = 'Network error. Please try again.';
        isLoading = false;
        debugPrint(errorMessage);
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
        debugPrint(errorMessage);
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
              _buildTextField("Username", _usernameController),
              SizedBox(height: 20),
              _buildTextField("Email Address", _emailController),
              SizedBox(height: 20),
              _buildPasswordTextField("Password", _passwordController),
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
    return Center(
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
    );
  }

  Widget _buildAlreadyHaveAccount() {
    return Center(
      child: GestureDetector(
        onTap: () {
          // Handle sign-in navigation
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
