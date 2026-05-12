import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth;

  static final AuthService instance = AuthService();

  final FirebaseAuth? _firebaseAuth;

  bool get isFirebaseInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  FirebaseAuth get _auth => _firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser {
    if (!isFirebaseInitialized) {
      return null;
    }

    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  bool get isSignedIn => currentUser != null;
}
