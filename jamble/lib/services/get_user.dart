import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserService {
  final storage = FlutterSecureStorage();

  // Function to get user info from the backend
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      // Retrieve the token from secure storage
      String? token = await storage.read(key: 'jwt_token');

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
