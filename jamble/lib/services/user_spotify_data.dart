import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SpotifyService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String backendEndpoint = '/api/auth/spotify/top-artists';

  // Method to retrieve the backend URL
  Future<String> getBackendUrl() async {
    const backendUrl = 'http://127.0.0.1:3000'; // Update to the correct backend URL
    debugPrint("Using backend URL: $backendUrl");
    return backendUrl;
  }

  // Fetch user's top artists from the backend and store Spotify user data securely
  Future<List<Artist>> getTopArtistsFromBackend() async {
    final backendUrl = await getBackendUrl();
    final url = Uri.parse('$backendUrl$backendEndpoint');

    // Retrieve the JWT token from secure storage
    String? token = await _secureStorage.read(key: 'user_token');
    if (token == null) {
      debugPrint("Error: User token not found in secure storage.");
      throw Exception("User token not found in storage");
    }

    try {
      // Define request headers with the token
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      // Make the HTTP GET request to the backend with the token
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

        // Store Spotify-specific data securely if available
        if (data.containsKey('spotify_access_token') && data.containsKey('spotify_refresh_token')) {
          await _secureStorage.write(key: 'spotify_access_token', value: data['spotify_access_token'] ?? '');
          await _secureStorage.write(key: 'spotify_refresh_token', value: data['spotify_refresh_token'] ?? '');
        }

        // Return the list of Artist objects
        return items.asMap().entries.map((entry) {
          int rank = entry.key + 1;
          return Artist.fromJson(entry.value, rank: rank);
        }).toList();
      } else {
        // Handle non-200 responses
        debugPrint('Error fetching top artists from backend: ${response.body}');
        throw Exception('Failed to retrieve data from backend: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      // Handle other errors (e.g., network issues)
      debugPrint("Error during fetch: $error");
      throw Exception("Failed to communicate with backend: $error");
    }
  }
}

// Artist model class with rank and optional image fallback
class Artist {
  final String id;
  final String name;
  final List<String> imageUrls;
  final int rank;

  Artist({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.rank,
  });

  static Artist empty() {
    return Artist(
      id: 'empty',
      name: 'No artist selected',
      imageUrls: ['default_image_url'],
      rank: 0,
    );
  }

  factory Artist.fromJson(Map<String, dynamic> json, {required int rank}) {
    List<String> images = (json['images'] as List<dynamic>?)
            ?.map((image) => image['url'] as String)
            .toList() ??
        ['default_image_url'];

    return Artist(
      id: json['id'],
      name: json['name'],
      imageUrls: images,
      rank: rank,
    );
  }
}
