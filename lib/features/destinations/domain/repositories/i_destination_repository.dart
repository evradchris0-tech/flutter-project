import '../../../../core/result/async_result.dart';
import '../entities/destination.dart';

/// Contrat du Repository Destinations (couche domaine).
///
/// Principe : la couche domaine définit l'interface, la couche data l'implémente.
/// Cela permet de swapper l'implémentation sans toucher à la logique métier.
///
/// Utilisé pour :
///   - Mocker facilement en tests (pas besoin de Dio ou SharedPreferences).
///   - Appliquer le Dependency Inversion Principle (DIP de SOLID).
abstract interface class IDestinationRepository {
  /// Charge les destinations via la cascade : API HTTP → Cache → Asset.
  ///
  /// [forceRefresh] : si true, invalide le cache avant de contacter l'API.
  Future<AsyncResult<List<Destination>>> getDestinations({
    bool forceRefresh = false,
  });

  /// Récupère une destination par son identifiant unique.
  Future<AsyncResult<Destination>> getDestinationById(String id);

  // ── Favoris ───────────────────────────────────────────────────────────────

  /// Charge l'ensemble des IDs de destinations favorites (persisté localement).
  Future<Set<String>> getFavoriteIds();

  /// Ajoute ou supprime une destination des favoris.
  Future<void> toggleFavorite(String id);

  // ── Notes ─────────────────────────────────────────────────────────────────

  /// Charge toutes les notes (id → nombre d'étoiles) depuis le stockage local.
  Future<Map<String, int>> getRatings();

  /// Persiste la note (1–5 étoiles) d'une destination.
  Future<void> rateDestination(String destinationId, int stars);
}
