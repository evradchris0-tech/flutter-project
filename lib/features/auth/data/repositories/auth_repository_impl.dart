import '../../../../core/error/failures.dart';
import '../../../../core/result/async_result.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../dto/auth_dto.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remote;
  final SecureStorageService  _storage;

  const AuthRepositoryImpl({
    required IAuthRemoteDataSource remote,
    required SecureStorageService  storage,
  })  : _remote  = remote,
        _storage = storage;

  // ── Login ──────────────────────────────────────────────────────────────────

  @override
  Future<AsyncResult<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remote.login(LoginRequestDto(
        email:    email,
        password: password,
      ));
      await _persistTokens(dto);
      return Success(dto.user.toEntity());
    } on AppFailure catch (f) {
      return Failure(f);
    } catch (e) {
      return Failure(UnknownFailure(message: e.toString()));
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────

  @override
  Future<AsyncResult<User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final dto = await _remote.register(RegisterRequestDto(
        email:     email,
        password:  password,
        firstName: firstName,
        lastName:  lastName,
      ));
      await _persistTokens(dto);
      return Success(dto.user.toEntity());
    } on AppFailure catch (f) {
      return Failure(f);
    } catch (e) {
      return Failure(UnknownFailure(message: e.toString()));
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  @override
  Future<void> logout() async {
    await _remote.logout();
    await _storage.clearAll();
  }

  // ── Current user ───────────────────────────────────────────────────────────

  @override
  Future<User?> getCurrentUser() async {
    final hasToken = await _storage.hasToken;
    if (!hasToken) return null;

    try {
      final dto = await _remote.getProfile();
      return dto.toEntity();
    } on AppFailure catch (f) {
      // 401 / 403 → clear stale tokens
      if (f is UnauthorizedFailure || f is ForbiddenFailure) {
        await _storage.clearAll();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── isAuthenticated ────────────────────────────────────────────────────────

  @override
  Future<bool> get isAuthenticated => _storage.hasToken;

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<void> _persistTokens(AuthResponseDto dto) => _storage.saveTokens(
        accessToken:  dto.accessToken,
        refreshToken: dto.refreshToken,
        userId:       dto.user.id,
      );
}
