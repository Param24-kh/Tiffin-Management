import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _baseWebUrl = 'http://localhost:3000/api';
  static const String _baseAndroidUrl = 'http://10.0.2.2:3000/api';
  static const String _baseIOSUrl = 'http://127.0.0.1:3000/api';

  String get baseUrl {
    if (kIsWeb) return _baseWebUrl;
    if (Platform.isAndroid) return _baseAndroidUrl;
    if (Platform.isIOS) return _baseIOSUrl;
    return _baseWebUrl;
  }

  Future<AuthResult> login(String email, String passkey) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'passkey': passkey}),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Connection timed out'),
          );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResult(
            token: responseData['token'],
            data: responseData['data'],
            message: responseData['message']);
      } else {
        throw HttpException(responseData['message'] ?? 'Login failed');
      }
    } on SocketException {
      throw HttpException('No Internet connection');
    } on TimeoutException {
      throw HttpException('Connection timed out');
    } catch (e) {
      throw HttpException('Login error: ${e.toString()}');
    }
  }

  Future<AuthResult> signup(Map<String, dynamic> signupData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/signup'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(signupData),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Connection timed out'),
          );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return AuthResult(
            token: responseData['token'],
            data: responseData['data'],
            message: responseData['message']);
      } else {
        throw HttpException(responseData['message'] ?? 'Signup failed');
      }
    } on SocketException {
      throw HttpException('No internet connection');
    } on TimeoutException {
      throw HttpException('Connection timed out');
    } catch (e) {
      throw HttpException('Signup error: ${e.toString()}');
    }
  }
}

class AuthResult {
  final String? token;
  final dynamic data;
  final String? message;

  AuthResult({this.token, this.data, this.message});
}
