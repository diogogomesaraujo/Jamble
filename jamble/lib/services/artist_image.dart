import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Artist {
  final String id; // Unique Spotify Artist ID
  final String name;
  final List<String> imageUrls; // List of image URLs

  Artist({
    required this.id,
    required this.name,
    required this.imageUrls,
  });

  // Static method for an empty artist state
  static Artist empty() {
    return Artist(
      id: 'empty',
      name: 'No artist selected',
      imageUrls: ['default_image_url'], // Placeholder image
    );
  }

  // Factory constructor to create an Artist instance from JSON
  factory Artist.fromJson(Map<String, dynamic> json) {
    List<String> images = (json['images'] as List)
        .map((image) => image['url'] as String)
        .toList();

    return Artist(
      id: json['id'],
      name: json['name'],
      imageUrls: images.isNotEmpty ? images : ['default_image_url'],
    );
  }
}

class FavouriteArtistsService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String clientId = '57db907bd46a4dbeb7eb97febf77b611'; // Add your Spotify Client ID
  static const String clientSecret = 'dce5159fa0ff43ceb28004254e8c7090'; // Add your Spotify Client Secret

  // Key to store the user's selected artist ID in secure storage
  static const String userAvatarKey = 'user_avatar_artist_id';

  // Function to get an access token using Spotify's client credentials flow
  Future<String> getAccessToken() async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> tokenData = jsonDecode(response.body);
      return tokenData['access_token'];
    } else {
      throw Exception(
          'Failed to obtain access token: ${response.statusCode} ${response.body}');
    }
  }

  // Function to search for artists using the Spotify API
  Future<List<Artist>> searchArtists(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final token = await getAccessToken();

    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$encodedQuery&type=artist&limit=10'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<Artist> artists = (data['artists']['items'] as List)
          .map((artistJson) => Artist.fromJson(artistJson))
          .toList();
      return artists;
    } else {
      throw Exception(
          'Failed to load artists: ${response.statusCode} ${response.body}');
    }
  }

  // Function to save the selected artist ID as the user's avatar
  Future<void> saveUserAvatarArtistId(String artistId) async {
    await _secureStorage.write(key: userAvatarKey, value: artistId);
  }

  // Function to get the artist image URL using the stored artist ID
  Future<String> getUserAvatarImage() async {
    final artistId = await _secureStorage.read(key: userAvatarKey);
    if (artistId == null || artistId.isEmpty) {
      return 'default_image_url'; // Return a default image URL if no artist ID is stored
    }

    return getArtistImageFromId(artistId);
  }

  // Function to get the artist image URL from Spotify using the artist ID
  Future<String> getArtistImageFromId(String artistId) async {
    final token = await getAccessToken();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists/$artistId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> artistData = jsonDecode(response.body);
      List<dynamic> images = artistData['images'];

      if (images.isNotEmpty) {
        return images[0]['url']; // Return the first image URL
      } else {
        return 'default_image_url'; // Fallback if no images are available
      }
    } else {
      throw Exception('Failed to load artist image: ${response.statusCode} ${response.body}');
    }
  }

  // Function to clear the user's avatar artist ID
  Future<void> clearUserAvatar() async {
    await _secureStorage.delete(key: userAvatarKey);
  }
}
