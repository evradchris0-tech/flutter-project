// NOTE : Provider Riverpod pour le mode sombre — persiste dans SharedPreferences.
// Concept mis en avant : StateNotifier<ThemeMode> + async init pattern.
// L'état ThemeMode est lu depuis les préférences au démarrage, puis mis à jour
// à chaque bascule et immédiatement écrit en SharedPreferences.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const _kKey = 'is_dark_mode';

  // Démarre en mode clair — corrigé dès que _loadSavedTheme() complète.
  ThemeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_kKey) ?? false;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Bascule entre clair et sombre et persiste le choix.
  Future<void> toggle() async {
    final isDark = state == ThemeMode.dark;
    state = isDark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kKey, !isDark);
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);
