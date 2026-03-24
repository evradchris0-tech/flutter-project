import '../../../../core/result/async_result.dart';
import '../entities/destination.dart';
import '../repositories/i_destination_repository.dart';

/// UseCase : récupère les détails d'une destination par son ID.
class GetDestinationByIdUseCase {
  final IDestinationRepository _repository;

  const GetDestinationByIdUseCase(this._repository);

  Future<AsyncResult<Destination>> call(String id) {
    return _repository.getDestinationById(id);
  }
}
