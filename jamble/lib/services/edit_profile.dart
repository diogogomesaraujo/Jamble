import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';

class EditProfileService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  /// Update the user profile and save changes to secure storage
  Future<void> editUserProfile({
    required String username,
    required String email,
    required String password,
    required String description,
    required String userImage,
    required String userWallpaper,
    List<String>? favoriteAlbums, // Allows null to handle empty lists gracefully
  }) async {
    try {
      // Retrieve the stored token from secure storage
      String? token = await secureStorage.read(key: 'user_token');
      if (token == null) {
        throw Exception('Token not found. Please login again.');
      }

      // Prepare the request body for profile update, managing empty album list if needed
      Map<String, dynamic> requestBody = {
        'username': username,
        'email': email,
        'password': password,
        'small_description': description,
        'user_image': userImage,
        'user_wallpaper': userWallpaper,
        'favorite_albums': favoriteAlbums ?? [], // Sends an empty list if no albums provided
      };

      print("Sending Request Body: ${jsonEncode(requestBody)}");

      // Perform HTTP PUT request to update the user profile on the server
      final response = await http.put(
        Uri.parse('http://127.0.0.1:3000/api/users/edit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      // Check if the response status indicates success (status code 200)
      if (response.statusCode == 200) {
        print('User profile updated successfully');

        // Update secure storage with the new profile data to keep it locally available
        await secureStorage.write(key: 'user_username', value: username);
        await secureStorage.write(key: 'user_email', value: email);
        await secureStorage.write(key: 'user_small_description', value: description);
        await secureStorage.write(key: 'user_image', value: userImage);
        await secureStorage.write(key: 'user_wallpaper', value: userWallpaper);
        await secureStorage.write(key: 'user_favorite_albums', value: favoriteAlbums?.join('|') ?? '');
      } else {
        // Log and throw an exception if the profile update request fails
        print('Failed to update profile: ${response.body}');
        throw Exception('Failed to update profile: ${response.body}');
      }
    } on SocketException {
      // Handle network-related errors specifically for a better user experience
      throw Exception('Network error. Please check your internet connection and try again.');
    } catch (e) {
      // Catch and rethrow other types of errors for broader error coverage
      throw Exception('An error occurred while updating the profile: $e');
    }
  }
}
