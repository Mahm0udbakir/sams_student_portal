import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_error.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository repository})
    : _repository = repository,
      _signupUseCase = SignupUseCase(repository),
      _verifyOtpUseCase = VerifyOtpUseCase(repository),
      _resendOtpUseCase = ResendOtpUseCase(repository),
      super(const AuthInitial());

  final AuthRepository _repository;
  final SignupUseCase _signupUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;

  String? _pendingVerificationId;
  String? _pendingEmail;
  String? _pendingName;
  String? _pendingPurpose;

  Future<void> bootstrap() async {
    try {
      final currentUser = await _repository
          .getCurrentUser()
          .timeout(const Duration(seconds: 12), onTimeout: () => null);
      if (currentUser == null) {
        emit(const AuthSignedOut());
        return;
      }

      emit(AuthAuthenticated(user: currentUser));
    } catch (_) {
      emit(const AuthSignedOut());
    }
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading(message: 'Creating your account...'));
    final name = '${firstName.trim()} ${lastName.trim()}'.trim();
    final result = await _signupUseCase(
      SignupParams(
        name: name.isEmpty ? email.trim().split('@').first : name,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        email: email,
        password: password,
      ),
    );
    _emitResult(result, purpose: 'signup');
  }

  Future<void> sendLoginOtp({required String email}) async {
    final trimmed = email.trim();
    emit(const AuthLoading(message: 'Sending OTP...'));

    final result = await _repository.sendOtp(
      email: trimmed,
      name: '',
      purpose: 'login',
    );
    if (result is AuthOtpChallenge<void>) {
      _pendingVerificationId = result.verificationId;
      _pendingEmail = result.email;
      _pendingName = result.name;
      _pendingPurpose = 'login';
      emit(
        AuthOtpRequired(
          verificationId: result.verificationId,
          email: result.email,
          name: result.name,
          expiresAt: result.expiresAt,
          attemptsRemaining: result.attemptsRemaining,
          purpose: 'login',
        ),
      );
    } else if (result is AuthFailure<void>) {
      emit(
        AuthError(
          type: result.type,
          message: result.message,
          email: trimmed,
          verificationId: _pendingVerificationId,
          purpose: 'login',
        ),
      );
    } else {
      emit(
        AuthError(
          type: AuthErrorType.unknown,
          message: 'Could not send the verification code. Please try again.',
          email: trimmed,
          purpose: 'login',
        ),
      );
    }
  }

  Future<void> verifyOtp(String otp) async {
    final verificationId = _pendingVerificationId;
    if (verificationId == null || verificationId.isEmpty) {
      emit(
        const AuthError(
          type: AuthErrorType.invalidVerificationId,
          message: 'No verification session is active. Please try again.',
        ),
      );
      return;
    }

    emit(const AuthLoading(message: 'Verifying code...'));
    final result = await _verifyOtpUseCase(
      VerifyOtpParams(
        verificationId: verificationId,
        otp: otp,
        purposeHint: _pendingPurpose,
      ),
    );

    if (result is AuthSuccess<AuthUser>) {
      _clearPendingOtp();
      emit(AuthAuthenticated(user: result.data));
      return;
    }

    if (result is AuthFailure<AuthUser>) {
      emit(
        AuthError(
          type: result.type,
          message: result.message,
          email: _pendingEmail,
          name: _pendingName,
          verificationId: _pendingVerificationId,
          purpose: _pendingPurpose,
        ),
      );
      return;
    }

    emit(
      AuthError(
        type: AuthErrorType.unknown,
        message: 'Verification failed. Please try again.',
        email: _pendingEmail,
        name: _pendingName,
        verificationId: _pendingVerificationId,
        purpose: _pendingPurpose,
      ),
    );
  }

  Future<void> resendOtp() async {
    final email = _pendingEmail;
    final name = _pendingName;
    final purpose = _pendingPurpose;

    if (email == null || purpose == null) {
      emit(
        const AuthError(
          type: AuthErrorType.invalidVerificationId,
          message: 'No OTP request is available to resend.',
        ),
      );
      return;
    }

    emit(const AuthLoading(message: 'Sending a new code...'));
    final displayName = (name == null || name.trim().isEmpty) ? 'Student' : name.trim();
    final result = await _resendOtpUseCase(
      ResendOtpParams(email: email, name: displayName, purpose: purpose),
    );

    if (result is AuthOtpChallenge<void>) {
      _pendingVerificationId = result.verificationId;
      emit(
        AuthOtpRequired(
          verificationId: result.verificationId,
          email: result.email,
          name: result.name,
          expiresAt: result.expiresAt,
          attemptsRemaining: result.attemptsRemaining,
          purpose: purpose,
        ),
      );
      return;
    }

    if (result is AuthFailure<void>) {
      emit(
        AuthError(
          type: result.type,
          message: result.message,
          email: email,
          name: displayName,
          verificationId: _pendingVerificationId,
          purpose: purpose,
        ),
      );
      return;
    }

    emit(
      AuthError(
        type: AuthErrorType.unknown,
        message: 'Could not resend the code. Please try again.',
        email: email,
        name: displayName,
        verificationId: _pendingVerificationId,
        purpose: purpose,
      ),
    );
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _clearPendingOtp();
    emit(const AuthSignedOut());
  }

  void _emitResult(
    AuthResult<AuthUser> result, {
    required String purpose,
  }) {
    if (result is AuthSuccess<AuthUser>) {
      _clearPendingOtp();
      emit(AuthAuthenticated(user: result.data));
      return;
    }

    if (result is AuthOtpChallenge<AuthUser>) {
      _pendingVerificationId = result.verificationId;
      _pendingEmail = result.email;
      _pendingName = result.name;
      _pendingPurpose = purpose;

      emit(
        AuthOtpRequired(
          verificationId: result.verificationId,
          email: result.email,
          name: result.name,
          expiresAt: result.expiresAt,
          attemptsRemaining: result.attemptsRemaining,
          purpose: purpose,
        ),
      );
      return;
    }

    if (result is AuthFailure<AuthUser>) {
      emit(
        AuthError(
          type: result.type,
          message: result.message,
          email: _pendingEmail,
          name: _pendingName,
          verificationId: _pendingVerificationId,
          purpose: purpose,
        ),
      );
      return;
    }

    emit(
      AuthError(
        type: AuthErrorType.unknown,
        message: 'Something went wrong. Please try again.',
        email: _pendingEmail,
        name: _pendingName,
        verificationId: _pendingVerificationId,
        purpose: purpose,
      ),
    );
  }

  void _clearPendingOtp() {
    _pendingVerificationId = null;
    _pendingEmail = null;
    _pendingName = null;
    _pendingPurpose = null;
  }
}
