import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/result/async_result.dart';
import '../../../../enums/destination_category.dart';
import '../../domain/entities/destination.dart';
import '../../domain/usecases/get_destinations_usecase.dart';
import '../../domain/usecases/get_destination_by_id_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';
import '../../domain/usecases/rate_destination_usecase.dart';

// ── Destinations list ──────────────────────────────────────────────────────────

/// Notifier principal qui charge la liste de destinations.
class DestinationsNotifier
    extends StateNotifier<AsyncResult<List<Destination>>> {
  final GetDestinationsUseCase _getDestinations;

  DestinationsNotifier(this._getDestinations) : super(const Idle()) {
    load();
  }

  Future<void> load({bool forceRefresh = false}) async {
    state = const Loading();
    final result = await _getDestinations(forceRefresh: forceRefresh);
    state = result;
  }

  /// Pull-to-refresh : force l'appel réseau.
  Future<void> refresh() => load(forceRefresh: true);
}

final destinationsNotifierProvider = StateNotifierProvider<
    DestinationsNotifier, AsyncResult<List<Destination>>>((ref) {
  return DestinationsNotifier(sl<GetDestinationsUseCase>());
});

// ── Compatibility bridge → AsyncValue ──────────────────────────────────────────

/// Traduit [AsyncResult<List<Destination>>] vers [AsyncValue<List<Destination>>]
/// pour une rétrocompatibilité parfaite avec les screens existants.
final destinationsProvider = Provider<AsyncValue<List<Destination>>>((ref) {
  final state = ref.watch(destinationsNotifierProvider);
  return switch (state) {
    Idle()              => const AsyncValue.loading(),
    Loading()           => const AsyncValue.loading(),
    Success(:final data) => AsyncValue.data(data),
    Failure(:final failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
  };
});

// ── Single destination ─────────────────────────────────────────────────────────

final destinationByIdProvider =
    FutureProvider.family<Destination?, String>((ref, id) async {
  final useCase = sl<GetDestinationByIdUseCase>();
  final result  = await useCase(id);
  return result.dataOrNull;
});

// ── Filter ─────────────────────────────────────────────────────────────────────

final selectedCategoryProvider =
    StateProvider<DestinationCategory?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

/// Retourne [AsyncValue<List<Destination>>] filtré — compatible avec sort_provider.
final filteredDestinationsProvider =
    Provider<AsyncValue<List<Destination>>>((ref) {
  final asyncValue = ref.watch(destinationsProvider);
  final category   = ref.watch(selectedCategoryProvider);
  final query      = ref.watch(searchQueryProvider).toLowerCase().trim();

  return asyncValue.whenData((list) => list.where((d) {
        final matchesCategory = category == null || d.category == category;
        final matchesQuery    = query.isEmpty ||
            d.name.toLowerCase().contains(query) ||
            d.region.toLowerCase().contains(query) ||
            d.description.toLowerCase().contains(query);
        return matchesCategory && matchesQuery;
      }).toList());
});

// ── Favorites ──────────────────────────────────────────────────────────────────

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final ToggleFavoriteUseCase _toggle;

  FavoritesNotifier(this._toggle) : super(const {}) {
    _load();
  }

  Future<void> _load() async {
    final favorites = await _toggle.getFavorites();
    state = favorites;
  }

  Future<void> toggle(String destinationId) async {
    final updated = await _toggle(destinationId);
    state = updated;
  }

  bool isFavorite(String id) => state.contains(id);
}

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier(sl<ToggleFavoriteUseCase>());
});

/// Provider de commodité : retourne true si [id] est dans les favoris.
final isFavoriteProvider = Provider.family<bool, String>((ref, id) {
  return ref.watch(favoritesNotifierProvider).contains(id);
});

// ── Ratings ────────────────────────────────────────────────────────────────────

class RatingsNotifier extends StateNotifier<Map<String, int>> {
  final RateDestinationUseCase _rate;

  RatingsNotifier(this._rate) : super(const {}) {
    _load();
  }

  Future<void> _load() async {
    final ratings = await _rate.getAllRatings();
    state = ratings;
  }

  Future<void> rate(String destinationId, int stars) async {
    if (stars == 0) {
      // Désélection : retire l'entrée
      state = Map.from(state)..remove(destinationId);
      return;
    }
    final updated = await _rate(destinationId: destinationId, stars: stars);
    state = updated;
  }

  int? getRating(String id) => state[id];

  // ── Backward-compat API ─────────────────────────────────────────────────────

  /// Alias de [rate] avec signature [setRating(id, stars)] (ancienne API).
  Future<void> setRating(String destinationId, int stars) =>
      rate(destinationId, stars);
}

final ratingsNotifierProvider =
    StateNotifierProvider<RatingsNotifier, Map<String, int>>((ref) {
  return RatingsNotifier(sl<RateDestinationUseCase>());
});

/// Provider de commodité : retourne la note (1-5) ou null.
final destinationRatingProvider = Provider.family<int?, String>((ref, id) {
  return ref.watch(ratingsNotifierProvider)[id];
});

// ── Backward-compat aliases ────────────────────────────────────────────────────
// Les screens existants utilisent les anciens noms. Ces alias permettent
// de continuer à utiliser les anciens imports sans modification.

/// Alias rétrocompatible de [favoritesNotifierProvider].
/// Écoute le même état, délègue au même notifier.
final favoritesProvider = favoritesNotifierProvider;

/// Alias rétrocompatible de [ratingsNotifierProvider].
final ratingsProvider = ratingsNotifierProvider;

/// Destinations favorites filtrées (combinaison favoris + liste).
final favoriteDestinationsProvider =
    Provider<AsyncValue<List<Destination>>>((ref) {
  final destinationsAsync = ref.watch(destinationsProvider);
  final favoriteIds       = ref.watch(favoritesNotifierProvider);

  return destinationsAsync.whenData(
    (destinations) =>
        destinations.where((d) => favoriteIds.contains(d.id)).toList(),
  );
});
