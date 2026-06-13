import 'auth_error.dart';

sealed class AuthResult<T> {
  const AuthResult();
}

final class AuthSuccess<T> extends AuthResult<T> {
  const AuthSuccess(this.data);

  final T data;
}

final class AuthFailure<T> extends AuthResult<T> {
  const AuthFailure({required this.type, required this.message});

  final AuthErrorType type;
  final String message;
}

final class AuthOtpChallenge<T> extends AuthResult<T> {
  const AuthOtpChallenge({
    required this.verificationId,
    required this.email,
    required this.name,
    required this.expiresAt,
    required this.attemptsRemaining,
    this.debugOtp,
  });

  final String verificationId;
  final String email;
  final String name;
  final DateTime expiresAt;
  final int attemptsRemaining;
  final String? debugOtp;
}
