import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Post {
  final String id;
  final String content;
  final String type;
  final String referenceId;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.content,
    required this.type,
    required this.referenceId,
    required this.createdAt,
  });

  // Factory constructor to create a Post object from a JSON map
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      referenceId: json['reference_id'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class PostService {
  final String apiUrl = "http://127.0.0.1:3000/api/posts"; // Replace with your backend URL
  final storage = FlutterSecureStorage();

  // Function to retrieve all posts for the authenticated user
  Future<List<Post>> getPosts() async {
    try {
      // Retrieve the user's access token from secure storage
      String? token = await storage.read(key: "user_token");

      // If token doesn't exist, throw an error
      if (token == null) {
        throw Exception("Authentication details missing.");
      }

      // Prepare headers with Authorization
      final headers = {
        "Authorization": "Bearer $token",
      };

      // Make the GET request to retrieve posts
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      // If the response is successful (status code 200)
      if (response.statusCode == 200) {
        final List<dynamic> postsJson = jsonDecode(response.body);
        // Convert each post JSON into a Post object
        final posts = postsJson.map((postJson) => Post.fromJson(postJson)).toList();
        return posts.cast<Post>();
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized access. Please log in again.");
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Error retrieving posts');
      }
    } catch (e) {
      print("Error retrieving posts: $e");
      throw Exception("Error retrieving posts: $e");
    }
  }

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
        throw Exception("Authentication details missing.");
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
        Uri.parse("$apiUrl/create"),
        headers: headers,
        body: body,
      );

      // If the response is successful (status code 201)
      if (response.statusCode == 201) {
        print("Post created successfully");
        return true; // Return true on successful post creation
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Error creating post');
      }
    } catch (e) {
      print("Error creating post: $e");
      throw Exception("Error creating post: $e");
    }
  }
}
