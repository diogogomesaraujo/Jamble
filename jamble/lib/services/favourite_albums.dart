import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Album {
  final String id; // Unique Spotify Album ID
  final String name;
  final String artist;
  final String imageUrl;
  final String spotifyUrl;

  Album({
    required this.id,
    required this.name,
    required this.artist,
    required this.imageUrl,
    required this.spotifyUrl,
  });

  // Static method for an empty album state
  static Album empty() {
    return Album(
      id: 'empty',
      name: 'No album selected',
      artist: '',
      imageUrl: 'default_image_url', // Placeholder or default image URL
      spotifyUrl: '',
    );
  }

  factory Album.fromJson(Map<String, dynamic> json) {
    String imageUrl = json['images']?.isNotEmpty ?? false
        ? json['images'][0]['url']
        : 'default_image_url'; // Fallback URL if no image is present

    return Album(
      id: json['id'], // Assign the Spotify Album ID
      name: json['name'],
      artist: (json['artists'] as List<dynamic>)
          .map((artist) => artist['name'])
          .join(', '),
      imageUrl: imageUrl,
      spotifyUrl: json['external_urls']['spotify'],
    );
  }
}

class FavouriteAlbumsService {
  static const String clientId = '57db907bd46a4dbeb7eb97febf77b611';
  static const String clientSecret = 'dce5159fa0ff43ceb28004254e8c7090';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Function to obtain the Spotify Access Token using client credentials
  Future<String> getAccessToken() async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('$clientId:$clientSecret'))}',
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

  // Function to search for albums using the Spotify API
  Future<List<Album>> searchAlbums(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final token = await getAccessToken();

    final response = await http.get(
      Uri.parse(
          'https://api.spotify.com/v1/search?q=$encodedQuery&type=album&limit=10'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      List<Album> albums = (data['albums']['items'] as List)
          .map((albumJson) => Album.fromJson(albumJson))
          .toList();
      return albums;
    } else {
      throw Exception(
          'Failed to load albums: ${response.statusCode} ${response.body}');
    }
  }

  // Add an album to a user's favorite list in the backend (example POST request)
  Future<void> addAlbumToFavorites(String userId, Album album) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:3000/api/favorite-albums/add'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': userId,
        'album': {
          'id': album.id,
          'name': album.name,
          'artist': album.artist,
          'imageUrl': album.imageUrl,
          'spotifyUrl': album.spotifyUrl,
        }
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Failed to add album to favorites: ${response.statusCode} ${response.body}');
    }
  }

  // Fetch favorite albums by reading album IDs from secure storage and getting album details from Spotify
  Future<List<Album>> getFavoriteAlbums() async {
    final albumIdsString = await _secureStorage.read(key: 'user_favorite_albums');

    // If no album IDs are stored or it's an empty string, return 5 empty album slots
    if (albumIdsString == null || albumIdsString.isEmpty) {
      return List.generate(5, (_) => Album.empty());
    }

    // Split the IDs and filter out any 'empty' or invalid IDs
    final albumIds = albumIdsString.split('|').where((id) => id != 'empty' && id.isNotEmpty).toList();

    // If no valid album IDs exist, return 5 empty album slots
    if (albumIds.isEmpty) {
      return List.generate(5, (_) => Album.empty());
    }

    final token = await getAccessToken();

    // Construct the API request with valid album IDs
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/albums?ids=${albumIds.join(",")}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Album> albums = (data['albums'] as List)
          .map((albumJson) => Album.fromJson(albumJson))
          .toList();
      
      // Ensure the list always contains 5 album slots, filling with empty albums if needed
      return albums.length < 5
          ? [...albums, ...List.generate(5 - albums.length, (_) => Album.empty())]
          : albums;
    } else {
      throw Exception('Failed to load favorite albums: ${response.statusCode} ${response.body}');
    }
  }
}
