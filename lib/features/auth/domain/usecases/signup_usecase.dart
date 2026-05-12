import '../entities/auth_result.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignupParams {
  const SignupParams({
    required this.name,
    required this.email,
    required this.password,
    this.studentId,
    this.department,
  });

  final String name;
  final String email;
  final String password;
  final String? studentId;
  final String? department;
}

class SignupUseCase {
  const SignupUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthResult<AuthUser>> call(SignupParams params) {
    return _repository.signUpWithEmailAndPassword(
      name: params.name,
      email: params.email,
      password: params.password,
      studentId: params.studentId,
      department: params.department,
    );
  }
}
