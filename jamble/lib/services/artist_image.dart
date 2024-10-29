import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class FavouriteArtistsService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String clientId = '57db907bd46a4dbeb7eb97febf77b611';
  static const String clientSecret = 'dce5159fa0ff43ceb28004254e8c7090';
  static const String userAvatarKey = 'user_avatar_artist_id';

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
      final tokenData = jsonDecode(response.body);
      return tokenData['access_token'];
    } else {
      throw Exception(
          'Failed to obtain access token: ${response.statusCode} ${response.body}');
    }
  }

  Future<List<Artist>> searchArtists(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final token = await getAccessToken();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$encodedQuery&type=artist&limit=10'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Artist> artists = (data['artists']['items'] as List)
          .map((artistJson) => Artist.fromJson(artistJson))
          .toList();
      return artists;
    } else {
      throw Exception(
          'Failed to load artists: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> saveUserAvatarArtistId(String artistId) async {
    await _secureStorage.write(key: userAvatarKey, value: artistId);
  }

  Future<String> getUserAvatarImage() async {
    final artistId = await _secureStorage.read(key: userAvatarKey);
    if (artistId == null || artistId.isEmpty) {
      return 'default_image_url';
    }
    return getArtistImageFromId(artistId);
  }

  Future<String> getArtistImageFromId(String artistId) async {
    final token = await getAccessToken();
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists/$artistId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final artistData = jsonDecode(response.body);
      List<dynamic> images = artistData['images'];

      return images.isNotEmpty ? images[0]['url'] : 'default_image_url';
    } else {
      throw Exception('Failed to load artist image: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> clearUserAvatar() async {
    await _secureStorage.delete(key: userAvatarKey);
  }
}

// Artist model class
class Artist {
  final String id;
  final String name;
  final List<String> imageUrls;

  Artist({
    required this.id,
    required this.name,
    required this.imageUrls,
  });

  static Artist empty() {
    return Artist(
      id: 'empty',
      name: 'No artist selected',
      imageUrls: ['default_image_url'],
    );
  }

  factory Artist.fromJson(Map<String, dynamic> json) {
    List<String> images = (json['images'] as List)
        .map((image) => image['url'] as String)
        .toList();

    return Artist(
      id: json['id'],
      name: json['name'],
      imageUrls: images.isNotEmpty ? images : [],
    );
  }
}
