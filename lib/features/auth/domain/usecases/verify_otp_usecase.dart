import '../entities/auth_result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams {
  const VerifyOtpParams({
    required this.verificationId,
    required this.otp,
  });

  final String verificationId;
  final String otp;
}

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthResult<AuthUser>> call(VerifyOtpParams params) {
    return _repository.verifyOtp(
      verificationId: params.verificationId,
      otp: params.otp,
    );
  }
}
