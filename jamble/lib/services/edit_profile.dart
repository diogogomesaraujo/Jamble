import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';

class EditProfileService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  /// Update the user profile
  Future<void> editUserProfile({
    required String username,
    required String email,
    required String password,
    required String description,
    required String userImage,
    required String userWallpaper,
    required List<String> favoriteAlbums,
  }) async {
    try {
      // Retrieve the stored token
      String? token = await secureStorage.read(key: 'user_token');
      if (token == null) {
        throw Exception('Token not found. Please login again.');
      }

      final response = await http.put(
        Uri.parse('http://127.0.0.1:3000/api/users/edit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'small_description': description,
          'user_image': userImage,
          'user_wallpaper': userWallpaper,
          'favorite_albums': favoriteAlbums,
        }),
      );

      if (response.statusCode == 200) {
        print('User updated successfully');
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please try again.');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
