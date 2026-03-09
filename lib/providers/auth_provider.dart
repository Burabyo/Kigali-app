import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_profile.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  UserProfile? _userProfile;
  String? _errorMessage;

  AuthProvider(this._authService) {
    _initializeAuth();
  }

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isEmailVerified => _authService.isEmailVerified;

  void _initializeAuth() {
    _authService.authStateChanges.listen((user) async {
      _user = user;
      if (user != null) {
        await _authService.reloadUser();
        _status = AuthStatus.authenticated;
        await _loadUserProfile();
      } else {
        _status = AuthStatus.unauthenticated;
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    _userProfile = await _authService.getUserProfile(_user!.uid);
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendEmailVerification() async {
    await _authService.sendEmailVerification();
  }

  Future<bool> checkEmailVerification() async {
    await _authService.reloadUser();
    final verified = _authService.isEmailVerified;
    notifyListeners();
    return verified;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _authService.updateUserProfile(profile);
    _userProfile = profile;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
