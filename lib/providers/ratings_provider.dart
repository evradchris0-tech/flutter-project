/// Ré-exporte les providers de notes depuis la nouvelle architecture Clean.
///
/// Avant : StateNotifierProvider avec SharedPreferences direct
/// Après  : RatingsNotifier → RateDestinationUseCase → Repository → LocalDataSource
///
/// Les screens n'ont PAS besoin de changer leurs imports.
export '../features/destinations/presentation/providers/destinations_provider.dart'
    show
        RatingsNotifier,
        ratingsNotifierProvider,
        ratingsProvider,
        destinationRatingProvider;
