import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';

class RegisterService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  /// Register a new user and store the token and user information if successful
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
        print('Response data: $responseData'); // Log the full response
        final String? token = responseData['data']['token'];
        final Map<String, dynamic>? user = responseData['data']['user'];

        if (token != null && user != null) {
          // Store the token and user information securely
          print('Token to store: $token'); // Log the token before storage
          await secureStorage.write(key: 'user_token', value: token);

          // Store user information
          await secureStorage.write(key: 'user_id', value: user['id']);
          await secureStorage.write(key: 'user_email', value: user['email']);
          await secureStorage.write(key: 'user_username', value: user['username'] ?? '');
          await secureStorage.write(key: 'user_small_description', value: user['small_description'] ?? '');
          await secureStorage.write(key: 'user_image', value: user['user_image'] ?? '');
          await secureStorage.write(key: 'user_wallpaper', value: user['user_wallpaper'] ?? '');
          await secureStorage.write(key: 'user_favorite_albums', value: (user['favorite_albums'] as List<dynamic>?)?.join(',') ?? '');

          // Spotify-specific information (only if available)
          if (user['spotify_id'] != null) {
            await secureStorage.write(key: 'spotify_id', value: user['spotify_id']);
            await secureStorage.write(key: 'spotify_access_token', value: user['spotify_access_token'] ?? '');
            await secureStorage.write(key: 'spotify_refresh_token', value: user['spotify_refresh_token'] ?? '');
            print('Spotify information stored successfully');
          }

          print('User information and token stored successfully');
          return token;
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
