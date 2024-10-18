// services/login.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  /// Get the backend URL. This method can be modified to fetch from a config file or environment variable.
  Future<String> getBackendUrl() async {
    const backendUrl = 'http://127.0.0.1:3000'; // Ensure this is always updated
    debugPrint("Using backend URL: $backendUrl");
    return backendUrl;
  }

  Future<String?> loginUser(String emailOrUsername, String password) async {
    if (emailOrUsername.isEmpty || password.isEmpty) {
      return 'Please fill all fields';
    }

    try {
      final backendUrl = await getBackendUrl();
      var response = await http.post(
        Uri.parse('$backendUrl/api/users/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'emailOrUsername': emailOrUsername,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String? token = responseData['data']['token'];
        final Map<String, dynamic>? user = responseData['data']['user'];

        if (token != null && user != null) {
          // Store the token and user information securely
          await secureStorage.write(key: 'user_token', value: token);
          await secureStorage.write(key: 'user_id', value: user['id']);
          await secureStorage.write(key: 'user_email', value: user['email']);
          await secureStorage.write(key: 'user_username', value: user['username'] ?? '');
          await secureStorage.write(key: 'user_spotify_id', value: user['spotify_id'] ?? '');
          await secureStorage.write(key: 'user_small_description', value: user['small_description'] ?? '');
          await secureStorage.write(key: 'user_image', value: user['user_image'] ?? '');
          await secureStorage.write(key: 'user_wallpaper', value: user['user_wallpaper'] ?? '');
          await secureStorage.write(key: 'user_favorite_albums', value: (user['favorite_albums'] as List<dynamic>?)?.join(',') ?? '');

          return null; // Indicate no error message
        } else {
          return 'Failed to retrieve token or user information.';
        }
      } else {
        return 'Login failed: ${response.body}';
      }
    } on SocketException {
      return 'Network error. Please try again.';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }
}
