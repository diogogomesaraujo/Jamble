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
        await secureStorage.write(key: 'spotify_token', value: token);
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        errorMessage = 'Backend error: ${response.body}';
      }
    } catch (e) {
      errorMessage = 'Error syncing with backend: $e';
    }
  }

  Future<bool> checkExistingToken() async {
    try {
      final token = await secureStorage.read(key: 'spotify_token');
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

  void dispose() {
  }
}