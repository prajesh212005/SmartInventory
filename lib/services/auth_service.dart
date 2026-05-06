import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _agentEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get agentEmail => _agentEmail;

  // Mock Login
  Future<String?> login(String email, String password) async {
    // Basic mock validation
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    
    if (email.isNotEmpty && password.length >= 6) {
      _isAuthenticated = true;
      _agentEmail = email;
      notifyListeners();
      return null;
    }
    return 'Invalid email or password (min 6 chars)';
  }

  // Mock Signup
  Future<String?> signup(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.length >= 6) {
      _isAuthenticated = true;
      _agentEmail = email;
      notifyListeners();
      return null;
    }
    return 'Registration failed (ensure email is valid and password >= 6 chars)';
  }

  // Logout
  Future<void> logout() async {
    _isAuthenticated = false;
    _agentEmail = null;
    notifyListeners();
  }
}
