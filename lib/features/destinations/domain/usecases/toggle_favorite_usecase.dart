import '../repositories/i_destination_repository.dart';

/// UseCase : bascule le statut favori d'une destination.
/// Expose aussi [getFavorites] pour l'initialisation du notifier.
class ToggleFavoriteUseCase {
  final IDestinationRepository _repository;

  const ToggleFavoriteUseCase(this._repository);

  /// Bascule et retourne le nouvel ensemble d'IDs favoris.
  Future<Set<String>> call(String destinationId) async {
    await _repository.toggleFavorite(destinationId);
    return _repository.getFavoriteIds();
  }

  /// Charge l'ensemble des favoris persistés (appel initial).
  Future<Set<String>> getFavorites() => _repository.getFavoriteIds();
}
