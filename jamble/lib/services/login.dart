// services/login.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

class LoginService {
  Future<String> getBackendUrl() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (!androidInfo.isPhysicalDevice) {
        return 'http://10.0.2.2:3000'; // Android emulator
      } else {
        return 'http://your-local-ip:3000'; // Android physical device
      }
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      if (!iosInfo.isPhysicalDevice) {
        return 'http://localhost:3000'; // iOS simulator
      } else {
        return 'http://your-local-ip:3000'; // iOS physical device
      }
    } else {
      return 'http://your-local-ip:3000'; // Fallback for unknown platforms
    }
  }

  Future<String?> loginUser(String emailOrUsername, String password) async {
    if (emailOrUsername.isEmpty || password.isEmpty) {
      return 'Please fill all fields';
    }

    try {
      final backendUrl = await getBackendUrl();
      var response = await http.post(
        Uri.parse('$backendUrl/api/users/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'emailOrUsername': emailOrUsername,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Successfully logged in
        return null; // Indicate no error message
      } else {
        return 'Login failed: ${response.body}';
      }
    } on SocketException {
      return 'Network error. Please try again.';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }
}
