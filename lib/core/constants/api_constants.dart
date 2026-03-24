/// Centralise toutes les constantes réseau de l'application.
///
/// En développement local :
///   • Android Emulator → 10.0.2.2 redirige vers localhost de la machine hôte
///   • iOS Simulator    → localhost fonctionne directement
///   • Appareil physique → utiliser l'IP de la machine sur le réseau local
///
/// En production : passer via --dart-define=API_BASE_URL=https://api.mondomaine.com/api
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login    = '/auth/login';
  static const String register = '/auth/register';
  static const String profile  = '/auth/profile';
  static const String logout   = '/auth/logout';
  static const String refresh  = '/auth/refresh';

  // ── Destinations ──────────────────────────────────────────────────────────
  static const String destinations = '/destinations';

  // ── Favorites ─────────────────────────────────────────────────────────────
  static const String favorites = '/favorites';

  // ── Ratings ───────────────────────────────────────────────────────────────
  static const String ratings = '/ratings';

  // ── Timeouts ──────────────────────────────────────────────────────────────
  static const connectTimeout = Duration(seconds: 10);
  static const receiveTimeout = Duration(seconds: 15);
  static const sendTimeout    = Duration(seconds: 10);
}
