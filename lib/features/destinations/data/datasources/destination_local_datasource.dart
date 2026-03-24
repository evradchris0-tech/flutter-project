import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dto/destination_dto.dart';

/// Contrat de la source de données locale.
abstract interface class IDestinationLocalDataSource {
  /// Retourne le cache si non expiré, sinon null.
  Future<List<DestinationDto>?> getCachedDestinations();

  /// Persiste les destinations en cache avec un timestamp.
  Future<void> cacheDestinations(List<DestinationDto> destinations);

  /// Invalide le cache (pull-to-refresh, forceRefresh).
  Future<void> clearCache();

  /// Charge les destinations depuis l'asset embarqué dans l'APK/IPA.
  Future<List<DestinationDto>> getFromAsset();

  // ── Favoris ───────────────────────────────────────────────────────────────
  Future<Set<String>> getFavoriteIds();
  Future<void> saveFavoriteIds(Set<String> ids);

  // ── Notes ─────────────────────────────────────────────────────────────────
  Future<Map<String, int>> getRatings();
  Future<void> saveRating(String destinationId, int stars);
}

/// Implémentation SharedPreferences — stockage JSON clé/valeur local.
///
/// Stratégie de cache : TTL de 24 h.
/// Après expiration, le repository tente de rafraîchir depuis l'API.
class DestinationLocalDataSource implements IDestinationLocalDataSource {
  final SharedPreferences _prefs;

  const DestinationLocalDataSource(this._prefs);

  // ── Clés internes (versionnées pour éviter les conflits lors de migrations) ─
  static const _cacheKey          = 'dc_v2_destinations_json';
  static const _cacheTimestampKey = 'dc_v2_destinations_ts';
  static const _favoritesKey      = 'dc_v2_favorites_ids';
  static const _ratingsPrefix     = 'dc_v2_rating_';
  static const _cacheMaxAge       = Duration(hours: 24);

  // ── Cache destinations ────────────────────────────────────────────────────

  @override
  Future<List<DestinationDto>?> getCachedDestinations() async {
    final ts = _prefs.getInt(_cacheTimestampKey);
    if (ts == null) return null;

    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ts),
    );
    if (age > _cacheMaxAge) return null; // Cache expiré

    final jsonStr = _prefs.getString(_cacheKey);
    if (jsonStr == null) return null;

    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(DestinationDto.fromJson)
        .toList();
  }

  @override
  Future<void> cacheDestinations(List<DestinationDto> destinations) async {
    final jsonStr = jsonEncode(
      destinations.map((d) => d.toJson()).toList(),
    );
    await _prefs.setString(_cacheKey, jsonStr);
    await _prefs.setInt(
      _cacheTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_cacheKey);
    await _prefs.remove(_cacheTimestampKey);
  }

  @override
  Future<List<DestinationDto>> getFromAsset() async {
    final jsonStr =
        await rootBundle.loadString('assets/data/destinations.json');
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .cast<Map<String, dynamic>>()
        .map(DestinationDto.fromJson)
        .toList();
  }

  // ── Favoris ───────────────────────────────────────────────────────────────

  @override
  Future<Set<String>> getFavoriteIds() async {
    return (_prefs.getStringList(_favoritesKey) ?? []).toSet();
  }

  @override
  Future<void> saveFavoriteIds(Set<String> ids) {
    return _prefs.setStringList(_favoritesKey, ids.toList());
  }

  // ── Notes ─────────────────────────────────────────────────────────────────

  @override
  Future<Map<String, int>> getRatings() async {
    final ratings = <String, int>{};
    for (final key in _prefs.getKeys()) {
      if (key.startsWith(_ratingsPrefix)) {
        final id = key.substring(_ratingsPrefix.length);
        ratings[id] = _prefs.getInt(key) ?? 0;
      }
    }
    return ratings;
  }

  @override
  Future<void> saveRating(String destinationId, int stars) {
    return _prefs.setInt('$_ratingsPrefix$destinationId', stars);
  }
}
