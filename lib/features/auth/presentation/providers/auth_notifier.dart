import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/result/async_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/i_auth_repository.dart';

// ── State ──────────────────────────────────────────────────────────────────────

/// Représente l'état d'authentification de l'utilisateur.
///
/// • [Idle]    → état initial avant toute action
/// • [Loading] → opération en cours (login / register / logout)
/// • [Success] → utilisateur connecté (data = User connecté)
/// • [Failure] → erreur (message + statusCode disponibles)
typedef AuthState = AsyncResult<User?>;

// ── Notifier ───────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase    _login;
  final RegisterUseCase _register;
  final LogoutUseCase   _logout;
  final IAuthRepository _repository;

  AuthNotifier({
    required LoginUseCase    login,
    required RegisterUseCase register,
    required LogoutUseCase   logout,
    required IAuthRepository repository,
  })  : _login      = login,
        _register   = register,
        _logout     = logout,
        _repository = repository,
        super(const Idle()) {
    _init();
  }

  // ── Initialisation ─────────────────────────────────────────────────────────

  /// Restaure la session depuis le token stocké au démarrage.
  Future<void> _init() async {
    state = const Loading();
    final user = await _repository.getCurrentUser();
    state = Success(user); // null = visiteur, User = connecté
  }

  // ── Actions publiques ──────────────────────────────────────────────────────

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const Loading();
    final result = await _login(email: email, password: password);
    state = result.map((user) => user as User?);
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = const Loading();
    final result = await _register(
      email:     email,
      password:  password,
      firstName: firstName,
      lastName:  lastName,
    );
    state = result.map((user) => user as User?);
  }

  Future<void> logout() async {
    state = const Loading();
    await _logout();
    state = const Success(null);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  bool get isAuthenticated => switch (state) {
        Success(:final data) => data != null,
        _                    => false,
      };

  User? get currentUser => switch (state) {
        Success(:final data) => data,
        _                    => null,
      };

  /// Réinitialise vers [Idle] (ex: après dismiss d'un dialog d'erreur).
  void resetState() => state = const Idle();
}

// ── Provider ───────────────────────────────────────────────────────────────────

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    login:      sl<LoginUseCase>(),
    register:   sl<RegisterUseCase>(),
    logout:     sl<LogoutUseCase>(),
    repository: sl<IAuthRepository>(),
  );
});

/// Provider de commodité — retourne directement l'utilisateur connecté ou null.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).dataOrNull;
});

/// Provider booléen — vrai si l'utilisateur est authentifié.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(authNotifierProvider);
  return switch (state) {
    Success(:final data) => data != null,
    _                    => false,
  };
});
