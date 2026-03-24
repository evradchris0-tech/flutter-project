import '../repositories/i_destination_repository.dart';

/// UseCase : enregistre ou met à jour la note étoiles d'une destination.
/// Expose aussi [getAllRatings] pour l'initialisation du notifier.
class RateDestinationUseCase {
  final IDestinationRepository _repository;

  const RateDestinationUseCase(this._repository);

  /// Persiste la note et retourne la map complète des notes mises à jour.
  Future<Map<String, int>> call({
    required String destinationId,
    required int    stars,
  }) async {
    assert(stars >= 1 && stars <= 5, 'La note doit être entre 1 et 5.');
    await _repository.rateDestination(destinationId, stars);
    return _repository.getRatings();
  }

  /// Charge toutes les notes persistées (appel initial).
  Future<Map<String, int>> getAllRatings() => _repository.getRatings();
}
