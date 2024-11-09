import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  final String _clientId = "57db907bd46a4dbeb7eb97febf77b611";
  final String _clientSecret = "dce5159fa0ff43ceb28004254e8c7090";
  final String _baseUrl = "https://api.spotify.com/v1";
  String? _accessToken;

  // Function to retrieve access token
  Future<void> _getAccessToken() async {
    final String credentials = base64Encode(utf8.encode("$_clientId:$_clientSecret"));
    final response = await http.post(
      Uri.parse("https://accounts.spotify.com/api/token"),
      headers: {
        "Authorization": "Basic $credentials",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: {"grant_type": "client_credentials"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data["access_token"];
    } else {
      throw Exception("Failed to obtain Spotify access token");
    }
  }

  // Helper function to ensure the access token is available
  Future<void> _ensureAccessToken() async {
    if (_accessToken == null) {
      await _getAccessToken();
    }
  }

  // Function to fetch artist by ID
  Future<dynamic> getArtistById(String id) async {
    await _ensureAccessToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/artists/$id"),
      headers: {"Authorization": "Bearer $_accessToken"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch artist");
    }
  }

  // Function to fetch album by ID
  Future<dynamic> getAlbumById(String id) async {
    await _ensureAccessToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/albums/$id"),
      headers: {"Authorization": "Bearer $_accessToken"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch album");
    }
  }

  // Function to fetch song by ID
  Future<dynamic> getSongById(String id) async {
    await _ensureAccessToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/tracks/$id"),
      headers: {"Authorization": "Bearer $_accessToken"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch song");
    }
  }
}
