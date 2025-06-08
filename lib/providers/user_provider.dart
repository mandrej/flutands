// import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

final List<String> admins = [
  'milan.andrejevic@gmail.com',
  'mihailo.genije@gmail.com',
];
final List<String> family = [
  'milan.andrejevic@gmail.com',
  'mihailo.genije@gmail.com',
  'ana.devic@gmail.com',
  'dannytaboo@gmail.com',
  'svetlana.andrejevic@gmail.com',
  '011.nina@gmail.com',
  'bogdan.andrejevic16@gmail.com',
  'zile.zikson@gmail.com',
];

sealed class UserEvent {}

final class UserLogin extends UserEvent {}

final class UserLogout extends UserEvent {}

class UserBloc extends HydratedBloc<UserEvent, Map<String, dynamic>?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserBloc() : super(null) {
    on<UserLogin>((event, emit) async {
      try {
        final GoogleAuthProvider authProvider = GoogleAuthProvider();
        final UserCredential userCredential = await _auth.signInWithPopup(
          authProvider,
        );
        final user = userCredential.user;
        if (user != null) {
          emit({
            'displayName': user.displayName,
            'email': user.email,
            'uid': user.uid,
          });
        } else {
          emit(null);
        }
      } catch (e) {
        emit(null);
      }
    });

    on<UserLogout>((event, emit) async {
      await _auth.signOut();
      emit(null);
    });
  }

  get isAuthenticated => state != null;
  get isAdmin => admins.contains(state!['email']);
  get isFamily => family.contains(state!['email']);

  @override
  Map<String, dynamic>? fromJson(Map<String, dynamic> json) {
    return json;
  }

  @override
  Map<String, dynamic>? toJson(Map<String, dynamic>? state) {
    return state;
  }
}

// class UserProvider with ChangeNotifier {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   bool _isAuthenticated = false;
//   Map<String, dynamic>? _user;

//   Map<String, dynamic>? get user => _user;
//   String? get userName => _user?['displayName'];
//   String? get userEmail => _user?['email'];
//   bool get isAuthenticated => _isAuthenticated;
//   bool get isAdmin =>
//       _isAuthenticated ? admins.contains(_user!['email']) : false;
//   bool get isFamily =>
//       _isAuthenticated ? family.contains(_user!['email']) : false;

//   UserProvider() {
//     _auth.authStateChanges().listen((User? googleUser) {
//       if (googleUser == null) {
//         _isAuthenticated = false;
//         _user = null;
//         notifyListeners();
//         // print('User is currently signed out!');
//       } else {
//         _isAuthenticated = true;
//         _user = {
//           'displayName': googleUser.displayName,
//           'email': googleUser.email,
//           'uid': googleUser.uid,
//         };
//         notifyListeners();
//       }
//     });
//   }

//   Future<void> signInWithGoogle() async {
//     try {
//       GoogleAuthProvider authProvider = GoogleAuthProvider();
//       UserCredential userCredential = await _auth.signInWithPopup(authProvider);
//       final googleUser = userCredential.user;
//       _user = {
//         'displayName': googleUser?.displayName,
//         'email': googleUser?.email,
//         'uid': googleUser?.uid,
//       };
//       _isAuthenticated = true;
//       print(_user);
//       notifyListeners();
//     } catch (e) {
//       print(e);
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await _auth.signOut();
//     _isAuthenticated = false;
//     _user = null;
//     notifyListeners();
//   }
// }
