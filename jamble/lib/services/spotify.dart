// services/spotify.dart

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SpotifyService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  StreamSubscription? _linkSubscription;
  String errorMessage = '';

  /// Initialize deep link handlers
  Future<void> initDeepLinkHandlers(Function(String) onDeepLinkReceived) async {
    debugPrint("Initializing deep link handlers");
    await _initUriHandler(onDeepLinkReceived).then((_) {
      debugPrint("Initial URI handler initialized");
    }).catchError((error) {
      debugPrint("Failed to initialize initial URI handler: $error");
    });

    _listenForDeepLinks(onDeepLinkReceived);
  }

  /// Handle deep links on cold start or when the app resumes.
  Future<void> _initUriHandler(Function(String) onDeepLinkReceived) async {
    try {
      final Uri? initialURI = await getInitialUri(); // Check for the initial URI
      if (initialURI != null) {
        onDeepLinkReceived(initialURI.toString());
      }
    } catch (e) {
      debugPrint('Failed to receive initial URI: $e');
    }
  }

  /// Listen for real-time deep links during the app’s lifecycle.
  void _listenForDeepLinks(Function(String) onDeepLinkReceived) {
    if (_linkSubscription == null) {
      _linkSubscription = uriLinkStream.listen((Uri? link) {
        if (link != null) {
          debugPrint("Incoming deep link received: $link");
          onDeepLinkReceived(link.toString());
        }
      }, onError: (err) {
        errorMessage = 'Error receiving deep link: $err';
        debugPrint("Error in deep link stream: $err");
      }, cancelOnError: true); // Automatically cancels on error
    }
  }

  /// Handle the deep link, extract token, and navigate accordingly.
  Future<void> handleDeepLink(String url, Function onTokenStored) async {
    debugPrint("Handling deep link: $url");
    final Uri uri = Uri.parse(url);

    if (uri.scheme == 'myapp' && uri.host == 'callback') {
      final String? token = uri.queryParameters['token'];

      if (token != null) {
        debugPrint("Token found: $token");

        await secureStorage.write(key: 'spotify_token', value: token).then((_) {
          debugPrint("Token successfully stored: $token");
          onTokenStored();
        }).catchError((error) {
          errorMessage = 'Failed to store token: $error';
          debugPrint(errorMessage);
        });
      } else {
        errorMessage = 'Login failed: Missing token.';
        debugPrint("Login failed: Missing token.");
      }
    } else {
      debugPrint("Unexpected deep link: $url");
    }
  }

  /// Send the token to the backend to complete the authentication process.
  Future<void> sendTokenToBackend(String accessToken) async {
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
        errorMessage = 'Backend error: ${response.body}';
      }
    } catch (e) {
      debugPrint("Error syncing with backend: $e");
      errorMessage = 'Error syncing with backend: $e';
    }
  }

  /// Check if a Spotify token already exists in secure storage.
  Future<bool> checkExistingToken() async {
    try {
      final token = await secureStorage.read(key: 'spotify_token');
      return token != null;
    } catch (e) {
      errorMessage = 'Error checking token: $e';
      debugPrint(errorMessage);
      return false;
    }
  }

  /// Initiate the Spotify login flow by launching the Spotify OAuth URL.
  Future<void> loginWithSpotify() async {
    final backendUrl = await getBackendUrl();
    final spotifyAuthUrl = '$backendUrl/api/auth/spotify';

    try {
      final uri = Uri.parse(spotifyAuthUrl);

      if (await canLaunchUrl(uri)) {
        debugPrint("Launching Spotify auth URL: $spotifyAuthUrl");

        await launchUrl(uri, mode: LaunchMode.externalApplication).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            errorMessage = 'Spotify login timeout. Please try again.';
            debugPrint("TimeoutException: Spotify login URL timeout");
            throw TimeoutException("Spotify login URL timeout");
          },
        );
      } else {
        errorMessage = 'Could not launch Spotify login.';
        debugPrint(errorMessage);
      }
    } catch (e) {
      errorMessage = 'Error launching Spotify login: $e';
      debugPrint(errorMessage);
    }
  }

  /// Get the backend URL. This method can be modified to fetch from a config file or environment variable.
  Future<String> getBackendUrl() async {
    const backendUrl = 'http://127.0.0.1:3000'; // Ensure this is always updated
    debugPrint("Using backend URL: $backendUrl");
    return backendUrl;
  }

  /// Clean up any active subscriptions when the service is no longer needed.
  void dispose() {
    _linkSubscription?.cancel();
  }
}
