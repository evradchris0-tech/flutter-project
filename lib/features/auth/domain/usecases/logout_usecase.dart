import '../repositories/i_auth_repository.dart';

class LogoutUseCase {
  final IAuthRepository _repository;
  const LogoutUseCase(this._repository);

  Future<void> call() => _repository.logout();
}
