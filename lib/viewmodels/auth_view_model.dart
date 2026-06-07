import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  User? _user;
  bool _isLoading = false;
  StreamSubscription<User?>? _authSubscription;

  AuthViewModel(this._authService) {
    _user = _authService.currentUser;
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<bool> login() async {
    _setLoading(true);
    try {
      final credential = await _authService.signInWithGoogle();
      _setLoading(false);
      return credential != null;
    } catch (e) {
      _setLoading(false);
      rethrow;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
