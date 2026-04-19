import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.verifyToken();
    
    if (result['success'] == true) {
      _user = User.fromJson(result['user']);
      _isAuthenticated = true;
      _errorMessage = null;
    } else {
      _user = null;
      _isAuthenticated = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    if (result['success'] == true) {
      _user = User.fromJson(result['user']);
      _isAuthenticated = true;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['error'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.signup(
      email: email,
      password: password,
      name: name,
    );

    if (result['success'] == true) {
      _user = User.fromJson(result['user']);
      _isAuthenticated = true;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['error'];
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
