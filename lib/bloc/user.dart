// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user.dart' as my;

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

class UserState {
  final my.User? user;
  final bool isAdmin;
  final bool isFamily;
  final bool isAuthenticated;

  UserState({
    this.user,
    this.isAuthenticated = false,
    this.isAdmin = false,
    this.isFamily = false,
  });

  Map<String, dynamic> toMap() => {
    'user': user?.toMap(),
    'isAdmin': isAdmin,
    'isFamily': isFamily,
    'isAuthenticated': isAuthenticated,
  };

  factory UserState.fromMap(Map<String, dynamic> map) => UserState(
    user:
        map['user'] != null
            ? my.User.fromMap(Map<String, dynamic>.from(map['user']))
            : null,
    isAdmin: map['isAdmin'] ?? false,
    isFamily: map['isFamily'] ?? false,
    isAuthenticated: map['isAuthenticated'] ?? false,
  );
}

abstract class UserEvent {}

class UserSignInRequested extends UserEvent {}

class UserSignOutRequested extends UserEvent {}

class UserBloc extends HydratedBloc<UserEvent, UserState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserBloc() : super(UserState()) {
    on<UserSignInRequested>(_onSignInRequested);
    on<UserSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onSignInRequested(
    UserSignInRequested event,
    Emitter<UserState> emit,
  ) async {
    try {
      // Google sign-in with popup (web only)
      final googleProvider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(googleProvider);
      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final email = firebaseUser.email ?? '';
        final isAdmin = admins.contains(email);
        final isFamily = family.contains(email);
        final user = my.User(
          uid: firebaseUser.uid,
          email: email,
          displayName: firebaseUser.displayName ?? '',
          isAuthenticated: true,
          isAdmin: isAdmin,
          isFamily: isFamily,
        );
        emit(UserState(user: user, isAdmin: isAdmin, isFamily: isFamily));
      }
    } catch (e) {
      emit(UserState());
    }
  }

  Future<void> _onSignOutRequested(
    UserSignOutRequested event,
    Emitter<UserState> emit,
  ) async {
    await _auth.signOut();
    emit(UserState());
  }

  @override
  UserState? fromJson(Map<String, dynamic> json) {
    return UserState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(UserState state) {
    return state.toMap();
  }
}
