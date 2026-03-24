import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../storage/secure_storage_service.dart';

// ── Features: Destinations ────────────────────────────────────────────────────
import '../../features/destinations/data/datasources/destination_local_datasource.dart';
import '../../features/destinations/data/datasources/destination_remote_datasource.dart';
import '../../features/destinations/data/repositories/destination_repository_impl.dart';
import '../../features/destinations/domain/repositories/i_destination_repository.dart';
import '../../features/destinations/domain/usecases/get_destination_by_id_usecase.dart';
import '../../features/destinations/domain/usecases/get_destinations_usecase.dart';
import '../../features/destinations/domain/usecases/rate_destination_usecase.dart';
import '../../features/destinations/domain/usecases/toggle_favorite_usecase.dart';

// ── Features: Auth ────────────────────────────────────────────────────────────
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';

/// Instance globale du Service Locator (singleton).
///
/// Utilisation dans les providers Riverpod :
/// ```dart
/// final myProvider = Provider((ref) => sl<MyUseCase>());
/// ```
final GetIt sl = GetIt.instance;

/// Configure toutes les dépendances de l'application.
///
/// Doit être appelé dans [main()] **avant** [runApp()].
/// L'ordre d'enregistrement respecte le graphe de dépendances (bottom-up).
Future<void> configureDependencies() async {
  // ── External / Platform ───────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(
      // Android : EncryptedSharedPreferences via Android Keystore (AES-256)
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      // iOS     : Keychain accessible après premier déverrouillage
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    ),
  );

  // ── Core: Storage ─────────────────────────────────────────────────────────
  sl.registerSingleton<SecureStorageService>(
    SecureStorageService(sl<FlutterSecureStorage>()),
  );

  // ── Core: Network ─────────────────────────────────────────────────────────
  sl
    ..registerSingleton<AuthInterceptor>(
      AuthInterceptor(sl<SecureStorageService>()),
    )
    ..registerSingleton<ErrorInterceptor>(ErrorInterceptor())
    ..registerSingleton<Dio>(
      ApiClient.create(
        authInterceptor:  sl<AuthInterceptor>(),
        errorInterceptor: sl<ErrorInterceptor>(),
      ),
    );

  // ── Feature: Destinations — Data Layer ────────────────────────────────────
  sl
    ..registerSingleton<IDestinationRemoteDataSource>(
      DestinationRemoteDataSource(sl<Dio>()),
    )
    ..registerSingleton<IDestinationLocalDataSource>(
      DestinationLocalDataSource(sl<SharedPreferences>()),
    )
    ..registerSingleton<IDestinationRepository>(
      DestinationRepositoryImpl(
        remote: sl<IDestinationRemoteDataSource>(),
        local:  sl<IDestinationLocalDataSource>(),
      ),
    );

  // ── Feature: Destinations — Use Cases ────────────────────────────────────
  sl
    ..registerSingleton<GetDestinationsUseCase>(
      GetDestinationsUseCase(sl<IDestinationRepository>()),
    )
    ..registerSingleton<GetDestinationByIdUseCase>(
      GetDestinationByIdUseCase(sl<IDestinationRepository>()),
    )
    ..registerSingleton<ToggleFavoriteUseCase>(
      ToggleFavoriteUseCase(sl<IDestinationRepository>()),
    )
    ..registerSingleton<RateDestinationUseCase>(
      RateDestinationUseCase(sl<IDestinationRepository>()),
    );

  // ── Feature: Auth — Data Layer ────────────────────────────────────────────
  sl
    ..registerSingleton<IAuthRemoteDataSource>(
      AuthRemoteDataSource(sl<Dio>()),
    )
    ..registerSingleton<IAuthRepository>(
      AuthRepositoryImpl(
        remote:  sl<IAuthRemoteDataSource>(),
        storage: sl<SecureStorageService>(),
      ),
    );

  // ── Feature: Auth — Use Cases ─────────────────────────────────────────────
  sl
    ..registerSingleton<LoginUseCase>(LoginUseCase(sl<IAuthRepository>()))
    ..registerSingleton<RegisterUseCase>(RegisterUseCase(sl<IAuthRepository>()))
    ..registerSingleton<LogoutUseCase>(LogoutUseCase(sl<IAuthRepository>()));
}
