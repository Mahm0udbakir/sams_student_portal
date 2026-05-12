import '../entities/auth_result.dart';
import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthResult<AuthUser>> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? studentId,
    String? department,
  });

  Future<AuthResult<AuthUser>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AuthResult<void>> sendOtp({
    required String email,
    required String name,
    required String purpose,
  });

  Future<AuthResult<AuthUser>> verifyOtp({
    required String verificationId,
    required String otp,
    String? purposeHint,
  });

  Future<AuthResult<AuthUser>> createUserDocument({
    required String uid,
    required String email,
    required String name,
    String? firstName,
    String? lastName,
    String? studentId,
    String? department,
    bool emailVerified = false,
  });

  Future<AuthUser?> getCurrentUser();

  Future<void> signOut();
}
