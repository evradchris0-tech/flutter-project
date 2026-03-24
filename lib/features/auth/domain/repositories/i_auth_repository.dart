import '../../../../core/result/async_result.dart';
import '../entities/user.dart';

/// Contrat du Repository Auth (couche domaine).
abstract interface class IAuthRepository {
  /// Authentifie l'utilisateur et persiste le token JWT.
  Future<AsyncResult<User>> login({
    required String email,
    required String password,
  });

  /// Crée un compte et authentifie l'utilisateur.
  Future<AsyncResult<User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  /// Déconnecte l'utilisateur et supprime le token local.
  Future<void> logout();

  /// Retourne l'utilisateur courant depuis l'API (vérifie le token).
  /// Retourne null si non authentifié ou token invalide.
  Future<User?> getCurrentUser();

  /// Indique si un token d'accès valide est stocké localement.
  Future<bool> get isAuthenticated;
}
