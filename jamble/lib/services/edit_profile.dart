import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../services/get_user.dart';

class EditProfileService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  final UserService userService;

  EditProfileService({UserService? userService})
      : userService = userService ?? UserService();

  /// Update the user profile and fetch updated data to store in secure storage
  Future<void> editUserProfile({
    required String username,
    required String email,
    required String password,
    required String description,
    required String userImage,
    required String userWallpaper,
    List<String>? favoriteAlbums,
  }) async {
    try {
      // Retrieve the stored token from secure storage
      String? token = await secureStorage.read(key: 'user_token');
      if (token == null) {
        throw Exception('Token not found. Please login again.');
      }

      // Prepare the request body with explicit empty strings if fields are empty
      Map<String, dynamic> requestBody = {
        'username': username,
        'email': email,
        'password': password,
        'small_description': description,
        'user_image': userImage.isNotEmpty ? userImage : "", // Empty if no image
        'user_wallpaper': userWallpaper.isNotEmpty ? userWallpaper : "", // Empty if no wallpaper
        'favorite_albums': favoriteAlbums ?? [], // Empty list if no albums provided
      };

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

        // Fetch updated user info and save it to secure storage
        await fetchUserInformation(token);
      } else {
        // Log and throw an exception if the profile update request fails
        throw Exception('Failed to update profile: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please check your internet connection and try again.');
    } catch (e) {
      throw Exception('An error occurred while updating the profile: $e');
    }
  }

  /// Fetch updated user information and store in secure storage
  Future<void> fetchUserInformation(String token) async {
    final userInfoUrl = 'http://127.0.0.1:3000/api/users/user';

    try {
      final response = await http.get(
        Uri.parse(userInfoUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final Map<String, dynamic>? user = responseData['data'];

        if (user != null) {
          // Store user information in secure storage
          await secureStorage.write(key: 'user_id', value: user['user_id']);
          await secureStorage.write(key: 'user_email', value: user['email']);
          await secureStorage.write(key: 'user_username', value: user['username'] ?? '');
          await secureStorage.write(key: 'user_spotify_id', value: user['spotify_id'] ?? '');
          await secureStorage.write(key: 'user_small_description', value: user['small_description'] ?? '');
          await secureStorage.write(key: 'user_image', value: user['user_image'] ?? '');
          await secureStorage.write(key: 'user_wallpaper', value: user['user_wallpaper'] ?? '');

          // Handle favorite albums: store as a pipe-separated string
          final favoriteAlbums = (user['favorite_albums'] as List<dynamic>?)?.join('|') ?? 'empty|empty|empty|empty|empty';
          await secureStorage.write(key: 'user_favorite_albums', value: favoriteAlbums);

          // Store Spotify tokens if available
          if (user.containsKey('spotify_access_token') && user.containsKey('spotify_refresh_token')) {
            await secureStorage.write(key: 'spotify_access_token', value: user['spotify_access_token'] ?? '');
            await secureStorage.write(key: 'spotify_refresh_token', value: user['spotify_refresh_token'] ?? '');
          }

          print("User information stored successfully after profile update.");
        } else {
          throw Exception('Failed to retrieve user information from the backend.');
        }
      } else {
        throw Exception('Failed to fetch user information: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error retrieving user information: $e');
    }
  }
}
