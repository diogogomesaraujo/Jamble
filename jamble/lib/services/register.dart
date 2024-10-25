import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RegisterService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final String? token = responseData['data']['token'];
        final Map<String, dynamic>? user = responseData['data']['user'];

        if (token != null && user != null) {
          // Store token and user information
          await secureStorage.write(key: 'user_token', value: token);
          await secureStorage.write(key: 'user_id', value: user['id']);
          await secureStorage.write(key: 'user_email', value: user['email']);
          await secureStorage.write(key: 'user_username', value: user['username'] ?? '');
          await secureStorage.write(key: 'user_small_description', value: user['small_description'] ?? '');
          await secureStorage.write(key: 'user_image', value: user['user_image'] ?? '');
          await secureStorage.write(key: 'user_wallpaper', value: user['user_wallpaper'] ?? '');

          // Initialize favorite albums with 5 empty albums on registration
          await secureStorage.write(key: 'user_favorite_albums', value: 'empty|empty|empty|empty|empty');

          // Spotify-specific information
          if (user['spotify_id'] != null) {
            await secureStorage.write(key: 'spotify_id', value: user['spotify_id']);
            await secureStorage.write(key: 'spotify_access_token', value: user['spotify_access_token'] ?? '');
            await secureStorage.write(key: 'spotify_refresh_token', value: user['spotify_refresh_token'] ?? '');
          }

          return token; // Return the token as the success marker
        } else {
          throw Exception('Failed to retrieve token or user information.');
        }
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please try again.');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
