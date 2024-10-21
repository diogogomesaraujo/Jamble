import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CompleteProfileService {
  final String apiUrl = "http://127.0.0.1:3000/api/users/complete-profile"; // Replace with your backend URL
  final storage = FlutterSecureStorage();

  // Function to complete the profile
  Future<bool> completeProfile({required String username}) async {
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
        "Authorization": "Bearer $token", // Attach the token in the Authorization header
      };

      // Prepare the body with the username
      final body = jsonEncode({
        "username": username,
      });

      // Make the POST request to the backend API
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      // If the response is successful (status code 200)
      if (response.statusCode == 200) {
        // Store the username in secure storage after a successful response
        await storage.write(key: "user_username", value: username);
        return true; // Return true on successful profile completion
      } else {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        throw Exception(responseBody['message'] ?? 'Error completing profile');
      }
    } catch (e) {
      throw Exception("Error completing profile: $e");
    }
  }

  // Function to dispose of the service (if needed)
  void dispose() {
    // You can clean up any resources here if necessary
  }
}
