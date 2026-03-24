// NOTE : Provider Riverpod comptant les vues par destination.
// Concept mis en avant : StateNotifier<Map<String,int>> avec chargement asynchrone
// au démarrage + persistance incrémentale dans SharedPreferences.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewCounterNotifier extends StateNotifier<Map<String, int>> {
  static const _prefix = 'views_';

  ViewCounterNotifier() : super(const {}) {
    _load();
  }

  // Lit toutes les clés views_* depuis SharedPreferences au démarrage.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    final map = <String, int>{};
    for (final key in keys) {
      final id = key.substring(_prefix.length);
      map[id] = prefs.getInt(key) ?? 0;
    }
    // spread operator : copie l'état courant en ajoutant les valeurs chargées.
    state = {...state, ...map};
  }

  /// Incrémente le compteur pour une destination et persiste la nouvelle valeur.
  Future<void> increment(String destinationId) async {
    final current = state[destinationId] ?? 0;
    // Nouvelle map immuable : spread + mise à jour de la clé.
    state = {...state, destinationId: current + 1};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefix$destinationId', current + 1);
  }

  /// Retourne le nombre de vues pour une destination (0 si jamais visitée).
  int getCount(String id) => state[id] ?? 0;
}

final viewCounterProvider =
    StateNotifierProvider<ViewCounterNotifier, Map<String, int>>(
  (ref) => ViewCounterNotifier(),
);
