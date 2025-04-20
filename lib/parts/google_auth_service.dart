import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with Google using signInWithPopup
  Future<User?> signInWithGoogle() async {
    try {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      UserCredential userCredential = await _auth.signInWithPopup(authProvider);
      // User(
      //   displayName: 'Milan Andrejevic',
      //   email: 'milan.andrejevic@gmail.com',
      //   isEmailVerified: true,
      //   isAnonymous: false,
      //   metadata: UserMetadata(
      //     creationTime: '2023-11-16 15:26:11.000Z',
      //     lastSignInTime: '2025-04-20 08:24:37.000Z',
      //   ),
      //   phoneNumber: null,
      //   photoURL: null,
      //   providerData,
      //   [
      //     UserInfo(
      //       displayName: 'Milan Andrejevic',
      //       email: 'milan.andrejevic@gmail.com',
      //       phoneNumber: null,
      //       photoURL: null,
      //       providerId: 'google.com',
      //       uid: 0403391717443495006467896640057566925458,
      //     ),
      //   ],
      //   refreshToken:
      //       'eyJfQXV0aEVtdWxhdG9yUmVmcmVzaFRva2VuIjoiRE8gTk9UIE1PRElGWSIsImxvY2FsSWQiOiJlMm5QeEtOdDFrQ0g2NGt5Zk9SR2U0YnZsM0NxIiwicHJvdmlkZXIiOiJnb29nbGUuY29tIiwiZXh0cmFDbGFpbXMiOnt9LCJwcm9qZWN0SWQiOiJhbmRyZWpldmljaSJ9',
      //   tenantId: null,
      //   uid: 'e2nPxKNt1kCH64kyfORGe4bvl3Cq',
      // );
      // print(userCredential.user);
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
