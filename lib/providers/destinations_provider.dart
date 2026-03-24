/// Ré-exporte les providers de destinations depuis la nouvelle architecture
/// Clean Architecture pour maintenir la compatibilité avec les screens existants.
///
/// Avant : FutureProvider<List<Destination>> (DestinationsService)
/// Après  : StateNotifier + AsyncResult + UseCase + Repository + Dio
///
/// Les screens n'ont PAS besoin de changer leurs imports.
export '../features/destinations/presentation/providers/destinations_provider.dart'
    show
        destinationsProvider,
        destinationsNotifierProvider,
        selectedCategoryProvider,
        searchQueryProvider,
        filteredDestinationsProvider,
        favoritesNotifierProvider,
        isFavoriteProvider,
        ratingsNotifierProvider,
        destinationRatingProvider,
        destinationByIdProvider;
