import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserService {
  final storage = FlutterSecureStorage();

  // Function to get user info from the backend
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      // Retrieve the token from secure storage
      String? token = await storage.read(key: 'user_token');

      if (token == null) {
        throw Exception('No token found');
      }

      // Define the request headers, including the token
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Make the GET request to the '/user' endpoint
      final response = await http.get(
        Uri.parse('http://127.0.0.1:3000/api/users/user'), // Replace with your backend URL
        headers: headers,
      );

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Parse the response body
        final Map<String, dynamic> userData = jsonDecode(response.body);

        // Store user data securely
        await storage.write(key: 'user_id', value: userData['id']);
        await storage.write(key: 'user_email', value: userData['email']);
        await storage.write(key: 'user_username', value: userData['username'] ?? '');
        await storage.write(key: 'user_spotify_id', value: userData['spotify_id'] ?? '');
        await storage.write(key: 'user_small_description', value: userData['small_description'] ?? '');
        await storage.write(key: 'user_image', value: userData['user_image'] ?? '');
        await storage.write(key: 'user_wallpaper', value: userData['user_wallpaper'] ?? '');

        // Handle favorite albums: check if albums are stored, if not, initialize empty albums
        final favoriteAlbums = (userData['favorite_albums'] as List<dynamic>?)?.join('|') ?? '';  // Join with pipe separator for storage
        await storage.write(
          key: 'user_favorite_albums',
          value: favoriteAlbums.isNotEmpty ? favoriteAlbums : 'empty|empty|empty|empty|empty',
        );

        // Store Spotify tokens if available
        if (userData.containsKey('spotify_access_token') && userData.containsKey('spotify_refresh_token')) {
          await storage.write(key: 'spotify_access_token', value: userData['spotify_access_token'] ?? '');
          await storage.write(key: 'spotify_refresh_token', value: userData['spotify_refresh_token'] ?? '');
        }

        return userData;
      } else {
        throw Exception('Failed to load user info. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching user info: $error');
      return null;
    }
  }
}
