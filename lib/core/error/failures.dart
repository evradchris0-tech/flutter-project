/// Hiérarchie scellée des erreurs applicatives — Defense-in-Depth pattern.
///
/// Chaque couche (datasource, repository, usecase) lève ou propage des [AppFailure]
/// typées. La couche présentation les mappe en messages utilisateur lisibles.
///
/// Sealed class = exhaustivité garantie dans les switch expressions (Dart 3+).
sealed class AppFailure {
  final String message;
  final int? statusCode;

  const AppFailure({required this.message, this.statusCode});

  @override
  String toString() => '${runtimeType}(message: $message, statusCode: $statusCode)';
}

// ── Réseau ────────────────────────────────────────────────────────────────────

/// Absence de connexion réseau ou timeout.
class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message = 'Connexion réseau indisponible. Vérifiez votre accès internet.',
    super.statusCode,
  });
}

// ── Serveur ───────────────────────────────────────────────────────────────────

/// Réponse HTTP 5xx ou erreur inattendue du backend.
class ServerFailure extends AppFailure {
  const ServerFailure({
    required super.message,
    super.statusCode,
  });
}

/// HTTP 401 — token absent, expiré ou invalide.
class UnauthorizedFailure extends AppFailure {
  const UnauthorizedFailure({
    super.message = 'Session expirée. Veuillez vous reconnecter.',
    super.statusCode = 401,
  });
}

/// HTTP 403 — authentifié mais non autorisé.
class ForbiddenFailure extends AppFailure {
  const ForbiddenFailure({
    super.message = 'Accès refusé. Vous n\'avez pas les droits nécessaires.',
    super.statusCode = 403,
  });
}

/// HTTP 404 — ressource introuvable.
class NotFoundFailure extends AppFailure {
  const NotFoundFailure({
    super.message = 'Ressource introuvable.',
    super.statusCode = 404,
  });
}

/// HTTP 409 — conflit (email déjà utilisé, etc.).
class ConflictFailure extends AppFailure {
  const ConflictFailure({
    super.message = 'Cette ressource existe déjà.',
    super.statusCode = 409,
  });
}

/// HTTP 422 — données de requête invalides (validation backend).
class ValidationFailure extends AppFailure {
  const ValidationFailure({
    required super.message,
    super.statusCode = 422,
  });
}

// ── Local ─────────────────────────────────────────────────────────────────────

/// Erreur d'accès au cache local (SharedPreferences, Hive, etc.).
class CacheFailure extends AppFailure {
  const CacheFailure({
    super.message = 'Erreur d\'accès aux données locales.',
    super.statusCode,
  });
}

/// Erreur de stockage sécurisé (Keychain / EncryptedSharedPreferences).
class StorageFailure extends AppFailure {
  const StorageFailure({
    super.message = 'Erreur de stockage sécurisé.',
    super.statusCode,
  });
}

// ── Générique ─────────────────────────────────────────────────────────────────

/// Erreur non catégorisée — cas de dernier recours.
class UnknownFailure extends AppFailure {
  const UnknownFailure({
    super.message = 'Une erreur inattendue est survenue.',
    super.statusCode,
  });
}
