// NOTE : Point d'entrée — ProviderScope active Riverpod, NotificationService s'initialise.
// Concepts mis en avant :
//   • ConsumerWidget pour DiscoverCameroonApp : lit themeProvider (mode sombre).
//   • darkTheme : second jeu de couleurs pour le mode sombre Material 3.
//   • NotificationService.init() : init asynchrone du plugin avant runApp().

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/di/injection.dart';
import 'providers/theme_provider.dart';
import 'screens/profile_screen.dart' show languageProvider;
import 'services/notification_service.dart';
import 'navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Dependency Injection (GetIt) ──────────────────────────────────────────
  await configureDependencies();

  // Initialise le service de notifications avant le premier frame.
  await NotificationService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ProviderScope(child: DiscoverCameroonApp()));
}

// ─── Palette de couleurs claires ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const primary          = Color(0xFF1A3C34);
  static const primaryLight     = Color(0xFF2D6A4F);
  static const gold             = Color(0xFFC8973A);
  static const background       = Color(0xFFF5F1EA);
  static const surface          = Color(0xFFFFFFFF);
  static const textDark         = Color(0xFF1A1A2E);
  static const textMedium       = Color(0xFF5A6470);
  static const textLight        = Color(0xFF9BA3AF);
  static const primaryContainer = Color(0xFFD0E8DC);
  static const goldContainer    = Color(0xFFFFF3E0);
}

// ─── Palette de couleurs sombres ──────────────────────────────────────────────
class DarkColors {
  DarkColors._();

  static const primary          = Color(0xFF5AB98C);
  static const gold             = Color(0xFFFFCC70);
  static const background       = Color(0xFF0F1714);
  static const surface          = Color(0xFF16221D);
  static const primaryContainer = Color(0xFF1E332A);
  static const goldContainer    = Color(0xFF33270A);
}

// ConsumerWidget : lit themeProvider pour choisir le mode clair/sombre.
class DiscoverCameroonApp extends ConsumerWidget {
  const DiscoverCameroonApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode   = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

    final locale = switch (currentLang) {
      'English'  => const Locale('en'),
      'Fulfuldé' => const Locale('ff'),
      _          => const Locale('fr'),
    };

    return MaterialApp.router(
      title: 'Camer Tour',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      locale: locale,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      routerConfig: appRouter,
    );
  }
}

// ─── Thème clair ─────────────────────────────────────────────────────────────
ThemeData _buildLightTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.gold,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.goldContainer,
      onSecondaryContainer: Color(0xFF7A5A1A),
      surface: AppColors.surface,
      onSurface: AppColors.textDark,
      outline: Color(0xFFE0DDD6),
      shadow: Color(0x1A000000),
    ),
    textTheme: _buildTextTheme(AppColors.textDark, AppColors.textMedium, AppColors.textLight),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: Colors.white, letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: _elevatedButtonTheme(AppColors.primary),
    chipTheme: _chipTheme(AppColors.primary, AppColors.surface, AppColors.textDark),
    cardTheme: _cardTheme(AppColors.surface, const Color(0xFFF0EDE6)),
    inputDecorationTheme: _inputTheme(Colors.white, AppColors.textLight, AppColors.primaryLight),
    dividerTheme: const DividerThemeData(color: Color(0xFFF0EDE6), thickness: 1, space: 0),
  );
}

// ─── Thème sombre ─────────────────────────────────────────────────────────────
ThemeData _buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: DarkColors.background,
    colorScheme: ColorScheme.dark(
      primary: DarkColors.primary,
      onPrimary: Colors.black,
      primaryContainer: DarkColors.primaryContainer,
      onPrimaryContainer: DarkColors.primary,
      secondary: DarkColors.gold,
      onSecondary: Colors.black,
      secondaryContainer: DarkColors.goldContainer,
      onSecondaryContainer: DarkColors.gold,
      surface: DarkColors.surface,
      onSurface: Colors.white.withOpacity(0.87),
      outline: const Color(0xFF3A3A3A),
      shadow: const Color(0x40000000),
    ),
    textTheme: _buildTextTheme(
      Colors.white.withOpacity(0.87),
      Colors.white.withOpacity(0.60),
      Colors.white.withOpacity(0.38),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: Colors.white, letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: _elevatedButtonTheme(DarkColors.primary),
    chipTheme: _chipTheme(DarkColors.primary, DarkColors.surface, Colors.white.withOpacity(0.87)),
    cardTheme: _cardTheme(DarkColors.surface, const Color(0xFF3A3A3A)),
    inputDecorationTheme: _inputTheme(
      const Color(0xFF2C2C2C),
      Colors.white.withValues(alpha: 0.38),
      DarkColors.primary,
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFF3A3A3A), thickness: 1, space: 0),
  );
}

// ─── Helpers partagés pour les deux thèmes ───────────────────────────────────
TextTheme _buildTextTheme(Color dark, Color medium, Color light) {
  return GoogleFonts.montserratTextTheme().copyWith(
    bodyLarge:   GoogleFonts.lato(fontSize: 15, height: 1.6, color: dark),
    bodyMedium:  GoogleFonts.lato(fontSize: 14, height: 1.5, color: medium),
    bodySmall:   GoogleFonts.lato(fontSize: 12, color: light),
    labelMedium: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
  );
}

ElevatedButtonThemeData _elevatedButtonTheme(Color primary) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.3),
    ),
  );
}

ChipThemeData _chipTheme(Color primary, Color surface, Color textColor) {
  return ChipThemeData(
    backgroundColor: surface,
    selectedColor: primary,
    labelStyle: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
    secondaryLabelStyle: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
    side: const BorderSide(color: Color(0xFFE0DDD6)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  );
}

CardThemeData _cardTheme(Color surface, Color borderColor) {
  return CardThemeData(
    elevation: 0,
    color: surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: borderColor, width: 1),
    ),
    margin: EdgeInsets.zero,
  );
}

InputDecorationTheme _inputTheme(Color fill, Color hint, Color focused) {
  return InputDecorationTheme(
    filled: true,
    fillColor: fill,
    hintStyle: GoogleFonts.lato(color: hint, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: focused, width: 1.5),
    ),
  );
}
