// NOTE : Service de cache local utilisant SharedPreferences.
// Concept mis en avant : persistance clé-valeur + expiration par timestamp
// pour implémenter une stratégie offline-first.

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const _kData      = 'cache_destinations_json';
  static const _kTimestamp = 'cache_destinations_ts';
  // Durée de validité du cache : 24 h — au-delà, on retente l'API.
  static const _maxAge     = Duration(hours: 24);

  /// Persiste le JSON reçu de l'API avec l'horodatage courant.
  static Future<void> saveDestinations(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kData, json);
    await prefs.setInt(_kTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  /// Retourne le JSON en cache si non expiré, sinon null.
  static Future<String?> loadDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_kTimestamp);
    if (ts == null) return null;
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ts),
    );
    if (age > _maxAge) return null; // cache expiré
    return prefs.getString(_kData);
  }

  /// Invalide le cache manuellement (ex. bouton "Rafraîchir").
  static Future<void> clearDestinations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kData);
    await prefs.remove(_kTimestamp);
  }
}
