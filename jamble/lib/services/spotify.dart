import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class SpotifyService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String errorMessage = '';

  // Sync function for non-Spotify accounts linking with Spotify
  Future<void> syncSpotifyWithAccount(String userId, BuildContext context) async {
    final backendUrl = await getBackendUrl();
    final spotifyAuthUrl = '$backendUrl/api/auth/spotify/sync';  // Use the sync endpoint

    try {
      // Start the Spotify OAuth flow for account syncing
      final result = await FlutterWebAuth.authenticate(
        url: spotifyAuthUrl,
        callbackUrlScheme: 'myapp',  // Your app's custom scheme
      );

      final Uri uri = Uri.parse(result);
      final String? token = uri.queryParameters['token'];

      if (token != null) {
        // Send token and userId to backend for syncing
        final response = await sendSyncTokenToBackend(token, userId);

        if (response != null && response['status'] == 'success') {
          // Handle successful sync, store token securely
          await secureStorage.write(key: 'user_token', value: token);

          // Fetch and store the complete user information
          await fetchUserInformation(token, context);

          print('Spotify sync successful');

          // Print everything in the secure storage
          await printSecureStorage();
        } else if (response != null && response['status'] == 'email_mismatch') {
          // Handle email mismatch scenario
          errorMessage = 'Email mismatch: Spotify and your account email do not match.';
        } else {
          throw Exception('Sync failed.');
        }
      } else {
        throw Exception('Failed to retrieve token from the Spotify OAuth callback.');
      }
    } catch (e) {
      errorMessage = 'Error during syncing: $e';
    }
  }

  // Function to send sync token and userId to the backend
  Future<Map<String, dynamic>?> sendSyncTokenToBackend(String accessToken, String userId) async {
    final backendUrl = await getBackendUrl();
    final syncUrl = '$backendUrl/api/auth/spotify/sync';  // Sync endpoint in the backend

    try {
      final response = await http.post(
        Uri.parse(syncUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'access_token': accessToken,
          'userId': userId,  // Sending user ID to link the accounts
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData;  // Return the response from the backend
      } else {
        errorMessage = 'Backend error: ${response.body}';
        return null;
      }
    } catch (e) {
      errorMessage = 'Error syncing with backend: $e';
      return null;
    }
  }

  // Login with Spotify using OAuth
  Future<void> loginWithSpotify(BuildContext context) async {
    final backendUrl = await getBackendUrl();
    final spotifyAuthUrl = '$backendUrl/api/auth/spotify';
    final callbackUrlScheme = 'myapp';  // Your app's custom scheme

    try {
      // Start the Spotify OAuth flow for login
      final result = await FlutterWebAuth.authenticate(
        url: spotifyAuthUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      final Uri uri = Uri.parse(result);
      final String? token = uri.queryParameters['token'];

      if (token != null) {
        // Store the token securely
        await secureStorage.write(key: 'user_token', value: token);

        // Fetch and store the complete user information and check for username
        await fetchUserInformation(token, context);

        // Print everything in the secure storage
        await printSecureStorage();
      } else {
        throw Exception('Failed to retrieve token from the Spotify OAuth callback.');
      }
    } on SocketException {
      errorMessage = 'Network error. Please check your connection and try again.';
    } catch (e) {
      errorMessage = 'Error during Spotify login: $e';
    }
  }

  // Function to fetch user info from the backend using the token
  Future<void> fetchUserInformation(String token, BuildContext context) async {
    final backendUrl = await getBackendUrl();
    final userInfoUrl = '$backendUrl/api/users/user';

    try {
      final response = await http.get(
        Uri.parse(userInfoUrl),
        headers: {
          'Authorization': 'Bearer $token',  // Send token in Authorization header
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final Map<String, dynamic>? user = responseData['data'];

        if (user != null) {
          // Store user information securely
          await secureStorage.write(key: 'user_id', value: user['user_id']);
          await secureStorage.write(key: 'user_email', value: user['email']);
          await secureStorage.write(key: 'user_username', value: user['username'] ?? '');
          await secureStorage.write(key: 'user_spotify_id', value: user['spotify_id'] ?? '');
          await secureStorage.write(key: 'user_small_description', value: user['small_description'] ?? '');
          await secureStorage.write(key: 'user_image', value: user['user_image'] ?? '');
          await secureStorage.write(key: 'user_wallpaper', value: user['user_wallpaper'] ?? '');
          await secureStorage.write(key: 'user_favorite_albums', value: (user['favorite_albums'] as List<dynamic>?)?.join(',') ?? '');

          // Store Spotify tokens if they are part of the user information
          await secureStorage.write(key: 'spotify_access_token', value: user['spotify_access_token'] ?? '');
          await secureStorage.write(key: 'spotify_refresh_token', value: user['spotify_refresh_token'] ?? '');

          print("User information stored successfully");

          // Check if the user has a username; if not, navigate to Complete Profile
          if (user['username'] == null || user['username'].isEmpty) {
            Navigator.pushReplacementNamed(context, '/complete-profile');
          } else {
            // Otherwise, proceed to the main page
            Navigator.pushReplacementNamed(context, '/edit-profile');
          }
        } else {
          errorMessage = 'Failed to retrieve user information from the backend.';
        }
      } else {
        errorMessage = 'Backend error: ${response.body}';
      }
    } catch (e) {
      errorMessage = 'Error retrieving user information: $e';
    }
  }

  // Check if an existing token is already stored
  Future<bool> checkExistingToken(BuildContext context) async {
    try {
      final token = await secureStorage.read(key: 'user_token');
      if (token != null) {
        // Fetch user information to check if username exists
        await fetchUserInformation(token, context);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      errorMessage = 'Error checking token: $e';
      return false;
    }
  }

  // Utility function to get the backend URL (can be dynamic if needed)
  Future<String> getBackendUrl() async {
    const backendUrl = 'http://127.0.0.1:3000';  // Replace with your backend URL
    return backendUrl;
  }

  // Function to print everything in the secure storage
  Future<void> printSecureStorage() async {
    final allItems = await secureStorage.readAll();
    print('Secure Storage Contents:');
    allItems.forEach((key, value) {
      print('$key: $value');
    });
  }

  // Cleanup function
  void dispose() {}
}
