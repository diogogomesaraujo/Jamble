import 'package:flutter/cupertino.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';

class SpotifyService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String errorMessage = '';

  Future<void> loginWithSpotify() async {
    final backendUrl = await getBackendUrl();
    final spotifyAuthUrl = '$backendUrl/api/auth/spotify';
    final callbackUrlScheme = 'myapp';

    try {
      final result = await FlutterWebAuth.authenticate(
        url: spotifyAuthUrl,
        callbackUrlScheme: callbackUrlScheme,
      );

      final Uri uri = Uri.parse(result);
      final String? token = uri.queryParameters['token'];

      if (token != null) {
        // Store the token securely
        await secureStorage.write(key: 'user_token', value: token);

        // Retrieve and store user information from the backend
        await sendTokenToBackend(token);
      } else {
        throw Exception('Failed to retrieve token from the Spotify OAuth callback.');
      }
    } on SocketException {
      errorMessage = 'Network error. Please check your connection and try again.';
    } catch (e) {
      errorMessage = 'Error during Spotify login: $e';
    }
  }

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
        final responseData = jsonDecode(response.body);
        final Map<String, dynamic>? user = responseData['data']['user'];

        if (user != null) {
          // Store user information securely
          await secureStorage.write(key: 'user_id', value: user['id']);
          await secureStorage.write(key: 'user_email', value: user['email']);
          await secureStorage.write(key: 'user_username', value: user['username'] ?? '');
          await secureStorage.write(key: 'user_spotify_id', value: user['spotify_id'] ?? '');
          await secureStorage.write(key: 'user_small_description', value: user['small_description'] ?? '');
          await secureStorage.write(key: 'user_image', value: user['user_image'] ?? '');
          await secureStorage.write(key: 'user_wallpaper', value: user['user_wallpaper'] ?? '');
          await secureStorage.write(key: 'user_favorite_albums', value: (user['favorite_albums'] as List<dynamic>?)?.join(',') ?? '');
        } else {
          errorMessage = 'Failed to retrieve user information from the backend.';
        }
      } else {
        errorMessage = 'Backend error: ${response.body}';
      }
    } catch (e) {
      errorMessage = 'Error syncing with backend: $e';
    }
  }

  Future<bool> checkExistingToken() async {
    try {
      final token = await secureStorage.read(key: 'user_token');
      return token != null;
    } catch (e) {
      errorMessage = 'Error checking token: $e';
      return false;
    }
  }

  Future<String> getBackendUrl() async {
    const backendUrl = 'http://127.0.0.1:3000';
    return backendUrl;
  }

  void dispose() {}
}
