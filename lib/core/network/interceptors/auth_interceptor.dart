import 'package:dio/dio.dart';
import '../../storage/secure_storage_service.dart';

/// Injecte automatiquement le Bearer token dans chaque requête sortante.
///
/// Pattern : Request Interceptor
///   1. Lit le token depuis [SecureStorageService].
///   2. Si présent → ajoute le header `Authorization: Bearer <token>`.
///   3. Sinon → laisse passer la requête sans header (routes publiques).
///
/// NOTE : ne gère pas le refresh automatique ici pour rester simple.
/// Pour un refresh automatique, utiliser un QueuedInterceptorsWrapper.
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
