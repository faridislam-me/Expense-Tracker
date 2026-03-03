import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/user_service.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;
  bool _isLoading = false;
  StreamSubscription<User?>? _authSubscription;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authSubscription =
        _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      notifyListeners();
      return;
    }

    try {
      _user = await _userService.getUser(firebaseUser.uid);
      if (_user == null) {
        _status = AuthStatus.unauthenticated;
      } else {
        _status = AuthStatus.authenticated;
        _syncPhotoUrl(firebaseUser);
      }
    } catch (e) {
      debugPrint('[AUTH_PROVIDER] _onAuthStateChanged error: $e');
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _syncPhotoUrl(User firebaseUser) async {
    try {
      final authPhoto = firebaseUser.photoURL;
      if (authPhoto == null || authPhoto.isEmpty) return;
      if (_user?.photoUrl != null && _user!.photoUrl!.isNotEmpty) return;

      await _userService.updateUser(firebaseUser.uid, {'photoUrl': authPhoto});
      _user = _user?.copyWith(photoUrl: authPhoto);
      notifyListeners();
    } catch (e) {
      debugPrint('[AUTH] _syncPhotoUrl error: $e');
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email, password);
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.registerWithEmail(email, password);
      final uid = result.user!.uid;
      final newUser = UserModel(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );
      await _userService.createUser(newUser);
      _user = newUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      notifyListeners();
    } catch (e) {
      _error = 'An unexpected error occurred';
      debugPrint('[AUTH_PROVIDER] registerWithEmail error: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithPhone(String phone) async {
    _setLoading(true);
    try {
      final result = await _authService.signInAnonymously();
      final uid = result.user!.uid;
      final newUser = UserModel(
        id: uid,
        name: '',
        email: '',
        phone: phone,
        createdAt: DateTime.now(),
      );
      await _userService.createUser(newUser);
      _user = newUser;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to register with phone';
      notifyListeners();
      debugPrint('[AUTH_PROVIDER] signInWithPhone error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        _error = 'Google sign-in was cancelled';
        notifyListeners();
        return;
      }

      final uid = result.user!.uid;
      final existing = await _userService.getUser(uid);
      if (existing == null) {
        final newUser = UserModel(
          id: uid,
          name: result.user!.displayName ?? '',
          email: result.user!.email ?? '',
          phone: '',
          photoUrl: result.user!.photoURL,
          createdAt: DateTime.now(),
        );
        await _userService.createUser(newUser);
        _user = newUser;
      }
    } catch (e) {
      _error = 'Failed to sign in with Google';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) return;
    try {
      _user = await _userService.getUser(firebaseUser.uid);
      if (_user != null) {
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[AUTH_PROVIDER] refreshUser error: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _error = 'Failed to send password reset email';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } catch (e) {
      _error = 'Failed to sign out';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication failed';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
