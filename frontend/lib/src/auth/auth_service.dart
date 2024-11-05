import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Use your actual server address - if running on Android emulator, use 10.0.2.2 instead of localhost
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // Changed from localhost

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> signupData) async {
    try {
      print('Attempting signup with data: $signupData'); // Debug log

      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signupData), // Now passing the complete signup data
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Signup failed');
      }
    } catch (e) {
      print('Signup error: $e'); // Debug log
      throw Exception('Failed to connect to the server: $e');
    }
  }
}
