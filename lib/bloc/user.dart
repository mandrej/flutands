import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import '../model/user.dart';

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

class UserCubit extends HydratedCubit<User?> {
  UserCubit() : super(null);

  Future<void> login() async {
    try {
      final auth = FirebaseAuth.instance;
      final googleProvider = GoogleAuthProvider();
      final userCredential = await auth.signInWithPopup(googleProvider);
      final user = userCredential.user;
      emit({
        'displayName': user!.displayName,
        'email': user.email,
        'uid': user.uid,
        'isAuthenticated': true,
        'isAdmin': admins.contains(user.email),
        'isFamily': family.contains(user.email),
      });
    } catch (e) {
      emit(null);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      emit(null);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Map<String, dynamic>? toJson(User? state) {
    if (state == null) return null;
    return {
      'displayName': state.displayName,
      'email': state.email,
      'uid': state.uid,
      'isAuthenticated': true,
      'isAdmin': admins.contains(state.email),
      'isFamily': family.contains(state.email),
    };
  }

  @override
  User? fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return null;
    return User(
      displayName: json['displayName'],
      email: json['email'],
      uid: json['uid'],
    );
  }
}
