import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_error.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthRepository repository})
    : _repository = repository,
      _signupUseCase = SignupUseCase(repository),
      _loginUseCase = LoginUseCase(repository),
      _verifyOtpUseCase = VerifyOtpUseCase(repository),
      _resendOtpUseCase = ResendOtpUseCase(repository),
      super(const AuthInitial());

  final AuthRepository _repository;
  final SignupUseCase _signupUseCase;
  final LoginUseCase _loginUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final ResendOtpUseCase _resendOtpUseCase;

  String? _pendingVerificationId;
  String? _pendingEmail;
  String? _pendingName;
  String? _pendingPurpose;

  Future<void> bootstrap() async {
    final currentUser = await _repository.getCurrentUser();
    if (currentUser == null) {
      emit(const AuthSignedOut());
      return;
    }

    emit(AuthAuthenticated(user: currentUser));
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading(message: 'Creating your account...'));
    final result = await _signupUseCase(
      SignupParams(
        name: name,
        email: email,
        password: password,
      ),
    );
    if (result is AuthSuccess<AuthUser>) {
      // Auto-login after signup
      emit(AuthAuthenticated(user: result.data));
    } else {
      _emitResult(result, purpose: 'signup');
    }
  }


  Future<void> sendLoginOtp({required String email}) async {
    emit(const AuthLoading(message: 'Sending OTP...'));
    final result = await _repository.sendOtp(
      email: email.trim(),
      name: '',
      purpose: 'login',
    );
    if (result is AuthOtpChallenge<void>) {
      _pendingVerificationId = result.verificationId;
      _pendingEmail = result.email;
      _pendingName = result.name;
      _pendingPurpose = 'login';
      emit(AuthOtpRequired(
        verificationId: result.verificationId,
        email: result.email,
        name: result.name,
        expiresAt: result.expiresAt,
        attemptsRemaining: result.attemptsRemaining,
        purpose: 'login',
      ));
    } else if (result is AuthFailure<void>) {
      emit(AuthError(
        type: result.type,
        message: result.message,
        email: email,
        verificationId: _pendingVerificationId,
        purpose: 'login',
      ));
    }
  }

  Future<void> verifyOtp(String otp) async {
    final verificationId = _pendingVerificationId;
    if (verificationId == null || verificationId.isEmpty) {
      emit(const AuthError(
        type: AuthErrorType.invalidVerificationId,
        message: 'No verification session is active. Please try again.',
      ));
      return;
    }

    emit(const AuthLoading(message: 'Verifying code...'));
    final result = await _verifyOtpUseCase(
      VerifyOtpParams(verificationId: verificationId, otp: otp),
    );

    if (result is AuthSuccess<AuthUser>) {
      _clearPendingOtp();
      emit(AuthAuthenticated(user: result.data));
      return;
    }

    if (result is AuthFailure<AuthUser>) {
      emit(AuthError(
        type: result.type,
        message: result.message,
        email: _pendingEmail,
        name: _pendingName,
        verificationId: _pendingVerificationId,
        purpose: _pendingPurpose,
      ));
    }
  }

  Future<void> resendOtp() async {
    final email = _pendingEmail;
    final name = _pendingName;
    final purpose = _pendingPurpose;

    if (email == null || name == null || purpose == null) {
      emit(const AuthError(
        type: AuthErrorType.invalidVerificationId,
        message: 'No OTP request is available to resend.',
      ));
      return;
    }

    emit(const AuthLoading(message: 'Sending a new code...'));
    final result = await _resendOtpUseCase(
      ResendOtpParams(email: email, name: name, purpose: purpose),
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
      emit(AuthError(
        type: result.type,
        message: result.message,
        email: email,
        name: name,
        verificationId: _pendingVerificationId,
        purpose: purpose,
      ));
    }
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
      emit(AuthError(
        type: result.type,
        message: result.message,
        email: _pendingEmail,
        name: _pendingName,
        verificationId: _pendingVerificationId,
        purpose: purpose,
      ));
    }
  }

  void _clearPendingOtp() {
    _pendingVerificationId = null;
    _pendingEmail = null;
    _pendingName = null;
    _pendingPurpose = null;
  }
}
