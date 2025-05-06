import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skin_disease_app/models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isLoading = false;
  User? _user;
  UserModel? _userModel;
  String? _error;
  bool _isTestMode = false;
  bool _isGuestMode = false;

  // Getters
  bool get isLoading => _isLoading;
  User? get user => _user;
  UserModel? get userModel => _userModel;
  String? get error => _error;
  bool get isTestMode => _isTestMode;
  bool get isGuestMode => _isGuestMode;

  // Constructor
  AuthService() {
    _init();
  }

  // Initialize Auth State
  void _init() {
    _isLoading = true;
    _user = _auth.currentUser;
    
    if (_user != null) {
      _loadUserData();
    } else {
      _isLoading = false;
      notifyListeners();
    }

    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (!_isTestMode && !_isGuestMode) {
        _user = user;
        if (user != null) {
          _loadUserData();
        } else {
          _userModel = null;
          _isLoading = false;
          notifyListeners();
        }
      }
    });
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error loading user data: $e');
      _error = 'Failed to load user data. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign In with Email and Password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      await _loadUserData();
      return true;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          _error = 'No user found with this email.';
          break;
        case 'wrong-password':
          _error = 'Wrong password provided.';
          break;
        case 'invalid-email':
          _error = 'Invalid email format.';
          break;
        case 'user-disabled':
          _error = 'This account has been disabled.';
          break;
        default:
          _error = 'Authentication failed: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Unexpected error during sign in: $e');
      _error = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Guest Login - Allows using the app without authentication
  Future<bool> signInAsGuest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Enable guest mode
      _isGuestMode = true;
      
      // Create a fake User object for guest
      _user = FakeUser(
        uid: 'guest-user-${DateTime.now().millisecondsSinceEpoch}',
        email: 'guest@example.com',
        displayName: 'Guest User',
      );
      
      // Create a basic UserModel for guest
      _userModel = UserModel(
        uid: _user!.uid,
        email: 'guest@example.com',
        name: 'Guest User',
        phoneNumber: '',
        savedArticles: [],
        medicalHistory: [],
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error in guest login: $e');
      _error = 'Failed to login as guest: $e';
      _isGuestMode = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Test Mode Login - Bypasses Firebase Auth for sample accounts
  Future<bool> testModeLogin(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch user data directly from Firestore
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        // Enable test mode
        _isTestMode = true;
        
        // Set user model from Firestore data
        _userModel = UserModel.fromMap(doc.data()!);
        
        // Create a fake User object with minimal data for testing
        // This won't be a real Firebase Auth user, just a placeholder
        _user = FakeUser(
          uid: _userModel!.uid,
          email: _userModel!.email,
          displayName: _userModel!.name,
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Sample user not found. Make sure you\'ve loaded sample data first.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error in test mode login: $e');
      _error = 'Failed to load sample user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register with Email and Password
  Future<bool> registerWithEmailAndPassword(String email, String password, String name, String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      // Create user document in Firestore
      final newUser = UserModel(
        uid: _user!.uid,
        email: email,
        name: name,
        phoneNumber: phoneNumber,
        savedArticles: [],
        medicalHistory: [],
      );

      await _firestore.collection('users').doc(_user!.uid).set(newUser.toMap());
      _userModel = newUser;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('Registration error: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'email-already-in-use':
          _error = 'This email is already registered.';
          break;
        case 'invalid-email':
          _error = 'Invalid email format.';
          break;
        case 'weak-password':
          _error = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'operation-not-allowed':
          _error = 'Email/password accounts are not enabled.';
          break;
        default:
          _error = 'Registration failed: ${e.message}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Unexpected error during registration: $e');
      _error = 'An unexpected error occurred. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (!_isTestMode && !_isGuestMode) {
        await _auth.signOut();
      }
      
      // Reset everything, both for regular, test mode and guest mode
      _isTestMode = false;
      _isGuestMode = false;
      _user = null;
      _userModel = null;
      
    } catch (e) {
      print('Error signing out: $e');
      _error = 'Error signing out: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error resetting password: $e');
      _error = 'Failed to send password reset email. Please check your email address.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update User Profile
  Future<bool> updateUserProfile({
    String? name,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    if (_user == null || _userModel == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _userModel!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        profileImageUrl: profileImageUrl,
      );

      // Only update Firestore for real users, not guests or test users
      if (!_isGuestMode && !_isTestMode) {
        await _firestore.collection('users').doc(_user!.uid).update({
          if (name != null) 'name': name,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        });
      }

      _userModel = updatedUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      _error = 'Failed to update profile. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Save or Unsave Article
  Future<bool> toggleSavedArticle(String articleId) async {
    if (_user == null || _userModel == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<String> savedArticles = _userModel!.savedArticles ?? [];
      
      if (savedArticles.contains(articleId)) {
        savedArticles.remove(articleId);
      } else {
        savedArticles.add(articleId);
      }

      // Only update Firestore for real users, not guests or test users
      if (!_isGuestMode && !_isTestMode) {
        await _firestore.collection('users').doc(_user!.uid).update({
          'savedArticles': savedArticles,
        });
      }

      _userModel = _userModel!.copyWith(savedArticles: savedArticles);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error toggling saved article: $e');
      _error = 'Failed to update saved articles.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Add Medical History
  Future<bool> addMedicalHistory(String historyId) async {
    if (_user == null || _userModel == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      List<String> medicalHistory = _userModel!.medicalHistory ?? [];
      
      if (!medicalHistory.contains(historyId)) {
        medicalHistory.add(historyId);
      }

      // Only update Firestore for real users, not guests or test users
      if (!_isGuestMode && !_isTestMode) {
        await _firestore.collection('users').doc(_user!.uid).update({
          'medicalHistory': medicalHistory,
        });
      }

      _userModel = _userModel!.copyWith(medicalHistory: medicalHistory);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding medical history: $e');
      _error = 'Failed to update medical history.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

// A simple fake User class for test mode that implements the necessary properties
class FakeUser implements User {
  @override
  final String uid;
  
  @override
  final String? email;
  
  @override
  final String? displayName;
  
  FakeUser({
    required this.uid,
    required this.email,
    this.displayName,
  });
  
  // Implement required methods and properties with dummy values for testing
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
