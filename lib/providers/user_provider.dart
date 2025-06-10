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

class UserCubit extends HydratedCubit<Map<String, dynamic>?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserCubit() : super(null);

  Future<void> login() async {
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
          'isAuthenticated': true,
          'isAdmin': admins.contains(user.email),
          'isFamily': family.contains(user.email),
        });
      } else {
        emit(null);
      }
    } catch (e) {
      emit(null);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    emit(null);
  }

  @override
  Map<String, dynamic>? fromJson(Map<String, dynamic> json) {
    if (json['user'] == null) return null;
    final user = json['user'] as Map<String, dynamic>;
    return {
      'displayName': user['displayName'],
      'email': user['email'],
      'uid': user['uid'],
      'isAuthenticated': user['isAuthenticated'] ?? false,
      'isAdmin': user['isAdmin'] ?? false,
      'isFamily': user['isFamily'] ?? false,
    };
  }

  @override
  Map<String, dynamic>? toJson(Map<String, dynamic>? state) {
    if (state == null) return null;
    return {
      'user': {
        'displayName': state['displayName'],
        'email': state['email'],
        'uid': state['uid'],
        'isAuthenticated': state['isAuthenticated'],
        'isAdmin': state['isAdmin'],
        'isFamily': state['isFamily'],
      },
    };
  }
}
