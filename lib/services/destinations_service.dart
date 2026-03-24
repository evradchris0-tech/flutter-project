// NOTE : Service de chargement des destinations — stratégie offline-first en 3 niveaux.
// Concept mis en avant : async/await + gestion d'erreurs pour implémenter le pattern
// « API HTTP → cache SharedPreferences → asset embarqué ».
//
// Niveau 1 — API HTTP    : récupère la dernière version en ligne et met en cache.
// Niveau 2 — Cache local : réutilise le JSON stocké dans SharedPreferences (< 24 h).
// Niveau 3 — Asset       : repli garanti — le JSON embarqué dans l'APK est toujours dispo.

import 'dart:convert';
import 'package:flutter/services.dart';

import '../features/destinations/data/dto/destination_dto.dart';
import '../models/destination.dart';
import 'cache_service.dart';

class DestinationsService {
  // ── Point d'entrée public ────────────────────────────────────────────────
  /// Renvoie la liste des destinations en suivant la cascade :
  ///   cache SharedPreferences → asset embarqué
  ///
  /// Note: l'appel réseau est désormais géré par [DestinationRepositoryImpl].
  /// Ce service est conservé pour compatibilité avec les anciens providers.
  static Future<List<Destination>> load() async {
    // 1. Tenter le cache SharedPreferences
    final cached = await CacheService.loadDestinations();
    if (cached != null) {
      return _parseJson(cached);
    }

    // 2. Repli asset — toujours disponible, même sans réseau ni cache.
    return loadFromAsset();
  }

  // ── Lecture directe de l'asset (utilisée par les providers de test) ──────
  static Future<List<Destination>> loadFromAsset() async {
    final jsonString =
        await rootBundle.loadString('assets/data/destinations.json');
    return _parseJson(jsonString);
  }

  // ── Parsing commun ───────────────────────────────────────────────────────
  static List<Destination> _parseJson(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => DestinationDto.fromJson(e as Map<String, dynamic>).toEntity())
        .toList();
  }
}
