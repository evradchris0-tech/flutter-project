import '../../../../core/result/async_result.dart';
import '../entities/destination.dart';
import '../repositories/i_destination_repository.dart';

/// UseCase : récupère la liste complète des destinations.
///
/// Suivant le principe de Responsabilité Unique (SRP),
/// chaque usecase n'encapsule qu'une seule action du domaine.
/// Ici : orchestrer le chargement des destinations avec refresh optionnel.
class GetDestinationsUseCase {
  final IDestinationRepository _repository;

  const GetDestinationsUseCase(this._repository);

  /// [forceRefresh] : vide le cache et force le rechargement depuis l'API.
  Future<AsyncResult<List<Destination>>> call({bool forceRefresh = false}) {
    return _repository.getDestinations(forceRefresh: forceRefresh);
  }
}
