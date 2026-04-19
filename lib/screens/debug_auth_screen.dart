import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DebugAuthScreen extends StatefulWidget {
  const DebugAuthScreen({super.key});

  @override
  State<DebugAuthScreen> createState() => _DebugAuthScreenState();
}

class _DebugAuthScreenState extends State<DebugAuthScreen> {
  String _status = 'Not tested';
  bool _isLoading = false;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing connection...';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'test@example.com',
          'password': 'test123',
          'name': 'Test User',
        }),
      ).timeout(const Duration(seconds: 5));

      setState(() {
        _status = 'Success! Status: ${response.statusCode}\n${response.body}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: ${e.toString()}\n\nMake sure backend server is running:\ncd backend\nnpm install\nnpm start';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Auth Connection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Test Backend Connection'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(_status),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
