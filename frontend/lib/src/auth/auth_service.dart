import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;

class AuthService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.1.2:3000/api';
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  Future<Map<String, dynamic>> login(String email, String passkey) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'passkey': passkey, // Changed from password to passkey
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out. Please try again.');
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw HttpException(responseData['message'] ?? 'Login failed');
      }
    } on SocketException {
      throw const HttpException(
          'Unable to connect to server. Please check your internet connection.');
    } on TimeoutException {
      throw const HttpException(
          'Connection timed out. Please check your internet connection.');
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw HttpException('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> signupData) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(signupData),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timed out. Please try again.');
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return responseData;
      } else {
        throw HttpException(responseData['message'] ?? 'Signup failed');
      }
    } on SocketException {
      throw const HttpException(
          'Unable to connect to server. Please check your internet connection.');
    } on TimeoutException {
      throw const HttpException(
          'Connection timed out. Please check your internet connection.');
    } on HttpException catch (e) {
      throw HttpException(e.message);
    } catch (e) {
      throw HttpException('An unexpected error occurred: $e');
    }
  }
}
