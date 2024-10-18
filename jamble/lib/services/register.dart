// services/register.dart

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:io';

class RegisterService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  /// Register a new user and store the token if successful
  Future<String?> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:3000/api/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('Response data: $responseData'); // Add this to see the full response
        final String? token = responseData['data']['token'];

        if (token != null) {
          // Store the token securely
          print('Token to store: $token'); // Log the token before storage
          await secureStorage.write(key: 'user_token', value: token);
          print('Token stored successfully'); // Confirm after storage    
          return token;
        } else {
          throw Exception('Failed to retrieve token.');
        }
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } on SocketException {
      throw Exception('Network error. Please try again.');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
