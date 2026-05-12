import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class ResendOtpParams {
  const ResendOtpParams({
    required this.email,
    required this.name,
    required this.purpose,
  });

  final String email;
  final String name;
  final String purpose;
}

class ResendOtpUseCase {
  const ResendOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthResult<void>> call(ResendOtpParams params) {
    return _repository.sendOtp(
      email: params.email,
      name: params.name,
      purpose: params.purpose,
    );
  }
}
