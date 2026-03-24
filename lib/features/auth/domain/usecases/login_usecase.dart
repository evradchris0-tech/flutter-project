import '../../../../core/result/async_result.dart';
import '../entities/user.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<AsyncResult<User>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
