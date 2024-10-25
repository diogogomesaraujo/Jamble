import 'dart:convert';
import 'package:http/http.dart' as http;

class Album {
  final String id; // Unique Spotify Album ID
  final String name;
  final String artist;
  final String imageUrl;
  final String spotifyUrl;

  Album({
    required this.id, // Add Spotify Album ID
    required this.name,
    required this.artist,
    required this.imageUrl,
    required this.spotifyUrl,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    // Check if the images array is not empty to avoid potential issues
    String imageUrl = json['images'] != null && json['images'].isNotEmpty
        ? json['images'][0]['url']
        : 'default_image_url'; // Fallback URL if no image

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
  static const String baseUrl = 'https://api.spotify.com/v1/search';
  
  // Function to get the Spotify Access Token using the client credentials
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
      throw Exception('Failed to obtain access token: ${response.statusCode} ${response.body}');
    }
  }

  // Function to search for albums using the Spotify API
  Future<List<Album>> searchAlbums(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final token = await getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl?q=$encodedQuery&type=album&limit=10'),
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
      throw Exception('Failed to load albums: ${response.statusCode} ${response.body}');
    }
  }

  // Logic to add an album to a user's favorite list in the backend (example POST request)
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
      throw Exception('Failed to add album to favorites: ${response.statusCode} ${response.body}');
    }
  }
}
