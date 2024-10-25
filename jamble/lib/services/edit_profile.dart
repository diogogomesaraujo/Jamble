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

      // Ensure favoriteAlbums contains valid album IDs
      if (favoriteAlbums.isEmpty) {
        throw Exception('Favorite albums cannot be empty.');
      }

      // Prepare the request body
      Map<String, dynamic> requestBody = {
        'username': username,
        'email': email,
        'password': password,
        'small_description': description,
        'user_image': userImage,
        'user_wallpaper': userWallpaper,
        'favorite_albums': favoriteAlbums, // Send album IDs as array of strings
      };

      print("Sending Request Body: ${jsonEncode(requestBody)}");

      // Make the HTTP PUT request to update the user profile
      final response = await http.put(
        Uri.parse('http://127.0.0.1:3000/api/users/edit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      // Check the response status
      if (response.statusCode == 200) {
        print('User profile updated successfully');
      } else {
        // Print the full response for debugging
        print('Failed to update profile: ${response.body}');
        throw Exception('Failed to update profile: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your internet connection and try again.');
    } catch (e) {
      // Catch and throw other errors
      throw Exception('An error occurred while updating the profile: $e');
    }
  }
}
