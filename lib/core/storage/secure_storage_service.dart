import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gère le stockage sécurisé des tokens JWT.
///
/// Utilise [FlutterSecureStorage] qui exploite :
///   - **Android** : EncryptedSharedPreferences (AES-256 via Android Keystore)
///   - **iOS**     : Keychain Services
///
/// Toutes les lectures/écritures sont asynchrones pour ne pas bloquer le thread UI.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService(this._storage);

  // ── Clés internes ─────────────────────────────────────────────────────────

  static const _accessTokenKey  = 'jwt_access_token';
  static const _refreshTokenKey = 'jwt_refresh_token';
  static const _userIdKey       = 'authenticated_user_id';

  // ── Tokens ────────────────────────────────────────────────────────────────

  /// Persiste le token d'accès et optionnellement le token de refresh.
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? userId,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId);
    }
  }

  /// Retourne le token d'accès, ou null s'il n'existe pas.
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  /// Retourne le token de refresh, ou null s'il n'existe pas.
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  /// Retourne l'ID de l'utilisateur connecté, ou null.
  Future<String?> getUserId() => _storage.read(key: _userIdKey);

  /// Indique si un token d'accès valide est stocké.
  Future<bool> get hasToken async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Nettoyage ─────────────────────────────────────────────────────────────

  /// Supprime tous les tokens (déconnexion).
  Future<void> clearAll() => _storage.deleteAll();

  /// Supprime uniquement le token d'accès (ex. expiration, à rafraîchir).
  Future<void> clearAccessToken() => _storage.delete(key: _accessTokenKey);
}
