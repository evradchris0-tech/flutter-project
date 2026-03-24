import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/async_result.dart';
import '../../domain/entities/destination.dart';
import '../../domain/repositories/i_destination_repository.dart';
import '../datasources/destination_local_datasource.dart';
import '../datasources/destination_remote_datasource.dart';

/// Implémentation du Repository Destinations.
///
/// Orchestre la cascade Offline-First :
///   1. API distante (NestJS) → met en cache si succès.
///   2. Cache local (SharedPreferences) → si API indisponible.
///   3. Asset embarqué → fallback garanti, même sans réseau ni cache.
///
/// Cette stratégie garantit que l'app est toujours fonctionnelle,
/// même en avion ou en zone sans réseau.
class DestinationRepositoryImpl implements IDestinationRepository {
  final IDestinationRemoteDataSource _remote;
  final IDestinationLocalDataSource  _local;

  const DestinationRepositoryImpl({
    required IDestinationRemoteDataSource remote,
    required IDestinationLocalDataSource  local,
  })  : _remote = remote,
        _local  = local;

  // ── Destinations ──────────────────────────────────────────────────────────

  @override
  Future<AsyncResult<List<Destination>>> getDestinations({
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      await _local.clearCache();
    }

    // Niveau 1 : API distante
    try {
      final dtos = await _remote.getDestinations();
      await _local.cacheDestinations(dtos); // Mise en cache
      return Success(dtos.map((d) => d.toEntity()).toList());
    } on AppFailure catch (f) {
      debugPrint('📡 Remote unavailable: ${f.message}');
    } catch (e) {
      debugPrint('📡 Unexpected remote error: $e');
    }

    // Niveau 2 : Cache local
    try {
      final cached = await _local.getCachedDestinations();
      if (cached != null) {
        debugPrint('💾 Serving from cache (${cached.length} items)');
        return Success(cached.map((d) => d.toEntity()).toList());
      }
    } catch (e) {
      debugPrint('💾 Cache read error: $e');
    }

    // Niveau 3 : Asset embarqué (fallback ultime)
    try {
      final assets = await _local.getFromAsset();
      debugPrint('📦 Serving from bundled asset (${assets.length} items)');
      return Success(assets.map((d) => d.toEntity()).toList());
    } catch (e) {
      return Failure(
        CacheFailure(
          message: 'Impossible de charger les destinations : $e',
        ),
      );
    }
  }

  @override
  Future<AsyncResult<Destination>> getDestinationById(String id) async {
    try {
      final dto = await _remote.getDestinationById(id);
      return Success(dto.toEntity());
    } on AppFailure catch (f) {
      return Failure(f);
    } catch (e) {
      return const Failure(NetworkFailure());
    }
  }

  // ── Favoris ───────────────────────────────────────────────────────────────

  @override
  Future<Set<String>> getFavoriteIds() => _local.getFavoriteIds();

  @override
  Future<void> toggleFavorite(String id) async {
    final ids = await _local.getFavoriteIds();
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    await _local.saveFavoriteIds(ids);
  }

  // ── Notes ─────────────────────────────────────────────────────────────────

  @override
  Future<Map<String, int>> getRatings() => _local.getRatings();

  @override
  Future<void> rateDestination(String destinationId, int stars) {
    return _local.saveRating(destinationId, stars);
  }
}
