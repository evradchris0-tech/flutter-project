// NOTE : Carte "Destination du Jour" — sélection déterministe basée sur le jour de l'année.
// Concepts mis en avant :
//   • Pas de random pur : même destination toute la journée, change à minuit.
//   • TweenAnimationBuilder : slide-up + fade-in à la construction du widget.
//   • Hero partagé avec DetailScreen via le tag 'hero-${dest.id}'.
//   • Gradient overlay sur l'image pour lisibilité du texte.
//   • CachedNetworkImage pour le chargement différé de l'image.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../enums/destination_category.dart';
import '../models/destination.dart';

class DestinationOfDayCard extends StatelessWidget {
  final List<Destination> destinations;
  final void Function(Destination) onTap;

  const DestinationOfDayCard({
    super.key,
    required this.destinations,
    required this.onTap,
  });

  /// Choisit la destination du jour de façon déterministe :
  /// même résultat pour toutes les instances pendant 24 h.
  Destination _pick() {
    final now = DateTime.now();
    // Numéro du jour dans l'année (1..366)
    final dayOfYear = int.parse(
      now.difference(DateTime(now.year)).inDays.toString(),
    ) + 1;
    return destinations[dayOfYear % destinations.length];
  }

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) return const SizedBox.shrink();

    final dest = _pick();
    final colorScheme = Theme.of(context).colorScheme;

    // TweenAnimationBuilder : le widget slide de bas en haut + fade in.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => onTap(dest),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image de fond avec Hero pour la transition vers DetailScreen.
                Hero(
                  tag: 'hero-${dest.id}',
                  child: CachedNetworkImage(
                    imageUrl: dest.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: colorScheme.primaryContainer,
                    ),
                    errorWidget: (_, __, ___) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primaryContainer,
                            colorScheme.primary.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                      child: Icon(Icons.landscape,
                          size: 60, color: colorScheme.primary),
                    ),
                  ),
                ),

                // Gradient sombre en bas pour le texte.
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xCC000000),
                      ],
                      stops: [0.4, 1.0],
                    ),
                  ),
                ),

                // Badge "Destination du Jour" en haut à gauche.
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC8973A),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wb_sunny_outlined,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          'Destination du Jour',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Texte en bas (nom + région + catégorie).
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dest.name,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text(
                            dest.region,
                            style: GoogleFonts.lato(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              dest.category.label,
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Flèche "explorer" en bas à droite.
                Positioned(
                  bottom: 16,
                  right: 14,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
