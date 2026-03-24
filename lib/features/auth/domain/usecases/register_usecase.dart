import '../../../../core/result/async_result.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<AsyncResult<User>> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    return _repository.register(
      email:     email,
      password:  password,
      firstName: firstName,
      lastName:  lastName,
    );
  }
}
