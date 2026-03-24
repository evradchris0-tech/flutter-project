/// Ré-exporte les providers de favoris depuis la nouvelle architecture Clean.
///
/// Avant : StateNotifierProvider avec SharedPreferences direct
/// Après  : FavoritesNotifier → ToggleFavoriteUseCase → Repository → LocalDataSource
///
/// Les screens n'ont PAS besoin de changer leurs imports.
export '../features/destinations/presentation/providers/destinations_provider.dart'
    show
        FavoritesNotifier,
        favoritesNotifierProvider,
        favoritesProvider,
        isFavoriteProvider,
        favoriteDestinationsProvider;
