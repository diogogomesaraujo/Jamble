import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';

class SpotifyService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String errorMessage = '';

  Future<void> syncSpotifyWithAccount(String userId, BuildContext context) async {
    final backendUrl = await getBackendUrl();
    final spotifyAuthUrl = '$backendUrl/api/auth/spotify/sync';  // Use the sync endpoint

    try {
      final result = await FlutterWebAuth.authenticate(
        url: spotifyAuthUrl,
        callbackUrlScheme: 'myapp',
      );

      final Uri uri = Uri.parse(result);
      final String? token = uri.queryParameters['token'];

      if (token != null) {
        final response = await sendSyncTokenToBackend(token, userId);

        if (response != null && response['status'] == 'success') {
          await secureStorage.write(key: 'user_token', value: token);
          await fetchUserInformation(token, context);
          print('Spotify sync successful');
          await printSecureStorage();
        } else if (response != null && response['status'] == 'email_mismatch') {
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

  Future<Map<String, dynamic>?> sendSyncTokenToBackend(String accessToken, String userId) async {
    final backendUrl = await getBackendUrl();
    final syncUrl = '$backendUrl/api/auth/spotify/sync';

    try {
      final response = await http.post(
        Uri.parse(syncUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'access_token': accessToken,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        errorMessage = 'Backend error: ${response.body}';
        return null;
      }
    } catch (e) {
      errorMessage = 'Error syncing with backend: $e';
      return null;
    }
  }

  Future<void> loginWithSpotify(BuildContext context) async {
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
        await secureStorage.write(key: 'user_token', value: token);
        await fetchUserInformation(token, context);
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

  Future<void> fetchUserInformation(String token, BuildContext context) async {
    final backendUrl = await getBackendUrl();
    final userInfoUrl = '$backendUrl/api/users/user';

    try {
      final response = await http.get(
        Uri.parse(userInfoUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final Map<String, dynamic>? user = responseData['data'];

        if (user != null) {
          await secureStorage.write(key: 'user_id', value: user['user_id']);
          await secureStorage.write(key: 'user_email', value: user['email']);
          await secureStorage.write(key: 'user_username', value: user['username'] ?? '');
          await secureStorage.write(key: 'user_spotify_id', value: user['spotify_id'] ?? '');
          await secureStorage.write(key: 'user_small_description', value: user['small_description'] ?? '');
          await secureStorage.write(key: 'user_image', value: user['user_image'] ?? '');
          await secureStorage.write(key: 'user_wallpaper', value: user['user_wallpaper'] ?? '');

          final favoriteAlbums = (user['favorite_albums'] as List<dynamic>?)?.join('|') ?? '';
          await secureStorage.write(
            key: 'user_favorite_albums',
            value: favoriteAlbums.isNotEmpty ? favoriteAlbums : 'empty|empty|empty|empty|empty',
          );

          await secureStorage.write(key: 'spotify_access_token', value: user['spotify_access_token'] ?? '');
          await secureStorage.write(key: 'spotify_refresh_token', value: user['spotify_refresh_token'] ?? '');

          print("User information stored successfully");

          if (user['username'] == null || user['username'].isEmpty) {
            Navigator.pushReplacementNamed(context, '/complete-profile');
          } else {
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

  Future<bool> checkExistingToken(BuildContext context) async {
    try {
      final token = await secureStorage.read(key: 'user_token');
      if (token != null) {
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

  Future<String> getBackendUrl() async {
    const backendUrl = 'http://127.0.0.1:3000';  // Replace with your backend URL
    return backendUrl;
  }

  Future<void> printSecureStorage() async {
    final allItems = await secureStorage.readAll();
    print('Secure Storage Contents:');
    allItems.forEach((key, value) {
      print('$key: $value');
    });
  }

  void dispose() {}
}
