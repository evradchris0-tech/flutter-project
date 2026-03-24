// Page profil avec gestion des préférences utilisateur.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_provider.dart';

// provider de langue, persisté dans SharedPreferences
class LanguageNotifier extends StateNotifier<String> {
  static const _kKey = 'app_language';

  LanguageNotifier() : super('Français') {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_kKey) ?? 'Français';
  }

  Future<void> setLanguage(String lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, lang);
  }
}

final languageProvider = StateNotifierProvider<LanguageNotifier, String>(
  (ref) => LanguageNotifier(),
);

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF141416) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Profil',
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: false,
        backgroundColor: isDark ? const Color(0xFF1E1E20) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 0.5,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // section invitation à se connecter
            Container(
              color: isDark ? const Color(0xFF1E1E20) : Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Accédez à votre réservation depuis n'importe quel appareil",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Inscrivez-vous, importez vos réservations existantes, ajoutez des activités à vos favoris et passez commande plus rapidement.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => context.push('/auth'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A7EFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "S'inscrire ou se connecter",
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _sectionTitle('Préférences', isDark),
            _sectionBox(isDark, children: [
              _optionRow('Devise', value: 'FCFA', isDark: isDark),
              _divider(isDark),
              // langue : ouvre un bottom sheet pour choisir
              _optionRowTappable(
                'Langue',
                value: currentLang,
                isDark: isDark,
                onTap: () => _showLanguagePicker(context, ref, currentLang),
              ),
              _divider(isDark),
              _themeToggle(isDark, ref),
              _divider(isDark),
              _optionRow('Notifications', isDark: isDark),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Aide', isDark),
            _sectionBox(isDark, children: [
              _optionRow('À propos de Discover Cameroon', isDark: isDark),
              _divider(isDark),
              _optionRow("Accéder au Centre d'aide", isDark: isDark),
              _divider(isDark),
              _optionRow('Démarrer un chat', isDark: isDark),
            ]),

            const SizedBox(height: 16),

            _sectionTitle('Informations juridiques', isDark),
            _sectionBox(isDark, children: [
              _optionRow("Conditions générales d'utilisation", isDark: isDark),
              _divider(isDark),
              _optionRow('Mentions légales', isDark: isDark),
              _divider(isDark),
              _optionRow('Confidentialité', isDark: isDark),
              _divider(isDark),
              _optionRow('Politique de confidentialité', isDark: isDark),
              _divider(isDark),
              _optionRow('Bibliothèques open source', isDark: isDark),
            ]),

            Padding(
              padding: const EdgeInsets.only(left: 20, top: 20, bottom: 40),
              child: Text(
                'Version 1.0.1',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[600] : Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
    );
  }

  Widget _sectionBox(bool isDark, {required List<Widget> children}) {
    return Container(
      color: isDark ? const Color(0xFF1E1E20) : Colors.white,
      child: Column(children: children),
    );
  }

  Widget _divider(bool isDark) {
    return Divider(
      height: 0.5, indent: 20, thickness: 0.5,
      color: isDark ? Colors.white10 : Colors.black12,
    );
  }

  Widget _optionRow(String title, {String? value, required bool isDark}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          if (value != null) ...[
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? Colors.white38 : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 6),
          ],
          Icon(Icons.arrow_forward_ios,
              size: 13, color: isDark ? Colors.white24 : Colors.black26),
        ],
      ),
    );
  }

  Widget _optionRowTappable(
    String title, {
    String? value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(onTap: onTap, child: _optionRow(title, value: value, isDark: isDark));
  }

  // switch pour basculer entre mode clair et sombre
  Widget _themeToggle(bool isDark, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Mode sombre',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Switch.adaptive(
            value: isDark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
            activeColor: const Color(0xFF1A7EFF),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref, String current) {
    const languages = ['Français', 'English', 'Fulfuldé'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
            Text('Choisir la langue',
                style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...languages.map((lang) => ListTile(
                  title: Text(lang,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: lang == current ? FontWeight.w700 : FontWeight.w400)),
                  trailing: lang == current
                      ? const Icon(Icons.check, color: Color(0xFF1A7EFF))
                      : null,
                  onTap: () {
                    ref.read(languageProvider.notifier).setLanguage(lang);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
