// NOTE : Écran listant les destinations mises en favoris par l'utilisateur.
// Concepts mis en avant :
//   • ConsumerWidget qui réagit automatiquement au provider de favoris.
//   • Dismissible : glisser vers la gauche pour retirer un favori avec undo SnackBar.
//   • AnimatedList n'est pas nécessaire : Dismissible fournit déjà l'animation de sortie.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../navigation/app_page_route.dart';
import '../providers/favorites_provider.dart';
import '../widgets/destination_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteDestinationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun favori pour l\'instant',
                    style: GoogleFonts.lato(color: Colors.grey, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Appuyez sur 🔖 dans une destination pour la sauvegarder.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final dest = favorites[index];
              // Dismissible : glisser horizontalement pour supprimer.
              return Dismissible(
                key: ValueKey(dest.id),
                direction: DismissDirection.endToStart,
                // Fond rouge avec icône poubelle visible pendant le glissement.
                background: Container(
                  alignment: Alignment.centerRight,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      SizedBox(height: 4),
                      Text(
                        'Retirer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                confirmDismiss: (_) async {
                  // Retire immédiatement et propose un undo.
                  ref.read(favoritesProvider.notifier).toggle(dest.id);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${dest.name} retiré des favoris'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'Annuler',
                        onPressed: () =>
                            ref.read(favoritesProvider.notifier).toggle(dest.id),
                      ),
                    ),
                  );
                  // Retourne true pour que Dismissible anime la sortie.
                  return true;
                },
                child: DestinationCard(
                  destination: dest,
                  onTap: (_) => Navigator.push(
                    context,
                    SlideRightRoute(page: DetailScreen(destination: dest)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
