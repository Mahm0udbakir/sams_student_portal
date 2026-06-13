import 'package:equatable/equatable.dart';
import '../../domain/entities/auth_error.dart';
import '../../domain/entities/auth_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

final class AuthOtpRequired extends AuthState {
  const AuthOtpRequired({
    required this.verificationId,
    required this.email,
    required this.name,
    required this.expiresAt,
    required this.attemptsRemaining,
    this.purpose = 'signup',
    this.debugOtp,
  });

  final String verificationId;
  final String email;
  final String name;
  final DateTime expiresAt;
  final int attemptsRemaining;
  final String purpose;
  final String? debugOtp;

  @override
  List<Object?> get props => [
    verificationId,
    email,
    name,
    expiresAt,
    attemptsRemaining,
    purpose,
    debugOtp,
  ];
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final AuthUser user;

  bool get needsProfileSetup => user.name.trim().isEmpty || user.studentId.isEmpty;

  @override
  List<Object?> get props => [user];
}

final class AuthError extends AuthState {
  const AuthError({
    required this.type,
    required this.message,
    this.email,
    this.name,
    this.verificationId,
    this.purpose,
  });

  final AuthErrorType type;
  final String message;
  final String? email;
  final String? name;
  final String? verificationId;
  final String? purpose;

  bool get isOtpRelated => verificationId != null;

  @override
  List<Object?> get props => [
    type,
    message,
    email,
    name,
    verificationId,
    purpose,
  ];
}

final class AuthSignedOut extends AuthState {
  const AuthSignedOut();
}
