import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  UserProvider() {
    _auth.authStateChanges().listen((User? googleUser) {
      if (googleUser == null) {
        _isAuthenticated = false;
        _user = null;
        notifyListeners();
        // print('User is currently signed out!');
      } else {
        _isAuthenticated = true;
        _user = {
          'displayName': googleUser?.displayName,
          'email': googleUser?.email,
          'photoURL': googleUser?.photoURL,
          'uid': googleUser?.uid,
        };
        notifyListeners();
        print('User is signed in!');
      }
    });
  }

  Future<void> signInWithGoogle() async {
    try {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      UserCredential userCredential = await _auth.signInWithPopup(authProvider);
      final googleUser = userCredential.user;
      _user = {
        'displayName': googleUser?.displayName,
        'email': googleUser?.email,
        'photoURL': googleUser?.photoURL,
        'uid': googleUser?.uid,
      };
      _isAuthenticated = true;
      print(_user);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}
