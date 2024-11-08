import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PostService {
  final String apiUrl = "http://127.0.0.1:3000/api/posts"; // Replace with your backend URL
  final storage = FlutterSecureStorage();

  // Function to create a post
  Future<bool> createPost({
    required String content,
    required String type,
    required String referenceId,
  }) async {
    try {
      // Retrieve the user's access token from secure storage
      String? token = await storage.read(key: "user_token");

      // If token doesn't exist, throw an error
      if (token == null) {
        throw Exception("No access token found.");
      }

      // Prepare headers with Authorization
      final headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      };

      // Prepare the body with post data
      final body = jsonEncode({
        "content": content,
        "type": type,
        "reference_id": referenceId,
      });

      // Make the POST request to create the post
      final response = await http.post(
        Uri.parse("$apiUrl/create"), // Assuming your endpoint is /create
        headers: headers,
        body: body,
      );

      // If the response is successful (status code 201)
      if (response.statusCode == 201) {
        return true; // Return true on successful post creation
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Error creating post');
      }
    } catch (e) {
      throw Exception("Error creating post: $e");
    }
  }

  // Function to retrieve all posts
  Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      // Retrieve the user's access token from secure storage
      String? token = await storage.read(key: "user_token");

      // If token doesn't exist, throw an error
      if (token == null) {
        throw Exception("No access token found.");
      }

      // Prepare headers with Authorization
      final headers = {
        "Authorization": "Bearer $token",
      };

      // Make the GET request to retrieve posts
      final response = await http.get(
        Uri.parse("$apiUrl"),
        headers: headers,
      );

      // If the response is successful (status code 200)
      if (response.statusCode == 200) {
        final List<dynamic> posts = jsonDecode(response.body);
        // Return the list of posts as a list of maps
        return posts.cast<Map<String, dynamic>>();
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Error retrieving posts');
      }
    } catch (e) {
      throw Exception("Error retrieving posts: $e");
    }
  }

  // Optional function to dispose of the service (if needed)
  void dispose() {
    // Clean up any resources here if necessary
  }
}
