import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api/auth';
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _storage.write(key: 'auth_token', value: data['token']);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Signup failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _storage.write(key: 'auth_token', value: data['token']);
        return {
          'success': true,
          'user': data['user'],
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> verifyToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      
      if (token == null) {
        return {'success': false, 'error': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        await _storage.delete(key: 'auth_token');
        return {
          'success': false,
          'error': data['error'] ?? 'Token verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: ${e.toString()}',
      };
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
