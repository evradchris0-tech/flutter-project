// NOTE : Page de détail enrichie avec galerie, activités, carte, notation et notification.
// Concepts mis en avant :
//   • ConsumerWidget Riverpod : écoute favoritesProvider + ratingsProvider + viewCounterProvider.
//   • StarRatingWidget (T3) : noter une destination avec persistance SharedPreferences.
//   • NotificationService : planifier une visite → notification locale immédiate.
//   • flutter_map + Clipboard pour la carte et le partage.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../enums/destination_category.dart';
import '../models/destination.dart';
import '../navigation/app_page_route.dart';
import '../providers/destinations_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/ratings_provider.dart';
import '../providers/view_counter_provider.dart';
import '../services/notification_service.dart';
import '../widgets/checklist_bottom_sheet.dart';
import 'compare_screen.dart';
import '../widgets/confetti_overlay.dart';
import '../widgets/image_gallery.dart';
import '../widgets/like_button.dart';
import '../widgets/star_rating_widget.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final Destination destination;

  const DetailScreen({super.key, required this.destination});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final _confettiKey = GlobalKey<ConfettiOverlayState>();

  void _copyToClipboard(BuildContext context) {
    final text =
        '📍 ${widget.destination.name} — ${widget.destination.region}\n\n'
        '${widget.destination.description}\n\n'
        'Découvert via Discover Cameroon 🇨🇲';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copié dans le presse-papiers ✓'),
        backgroundColor: const Color(0xFF1A3C34),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Envoie une notification immédiate et affiche une confirmation à l'utilisateur.
  Future<void> _planVisit(BuildContext context) async {
    await NotificationService.showVisitReminder(
      id: widget.destination.id.hashCode.abs(),
      destinationName: widget.destination.name,
      region: widget.destination.region,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '🗺️ Visite à ${widget.destination.name} planifiée ! Notification envoyée.'),
        backgroundColor: const Color(0xFF2D6A4F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final isFavorite  = ref.watch(favoritesProvider).contains(destination.id);
    final viewCount   = ref.watch(viewCounterProvider)[destination.id] ?? 0;
    final allDests    = ref.watch(destinationsProvider).valueOrNull ?? [];
    final colorScheme = Theme.of(context).colorScheme;

    return ConfettiOverlay(
      key: _confettiKey,
      child: Scaffold(
      appBar: AppBar(
        title: Text(destination.name),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white, size: 16),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(context),
            tooltip: 'Copier les infos',
          ),
          IconButton(
            icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              // Déclenche les confettis uniquement lors de l'ajout.
              if (!isFavorite) _confettiKey.currentState?.burst();
              ref.read(favoritesProvider.notifier).toggle(destination.id);
            },
            tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Galerie d'images réseau avec Hero sur le premier élément.
            ImageGallery(
              imageUrls: destination.imageUrls,
              heroTag: 'hero-${destination.id}',
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom + Badge catégorie
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          destination.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _CategoryBadge(destination: destination),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(children: [
                    Icon(Icons.location_on, size: 15, color: colorScheme.secondary),
                    const SizedBox(width: 4),
                    Text(
                      destination.region,
                      style: GoogleFonts.lato(
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500),
                    ),
                    // Compteur de vues
                    if (viewCount > 0) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.visibility_outlined,
                          size: 13, color: colorScheme.onSurface.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                      Text(
                        '$viewCount vue${viewCount > 1 ? 's' : ''}',
                        style: GoogleFonts.lato(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.4)),
                      ),
                    ],
                  ]),

                  if (destination.altitude != null) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.terrain, size: 15, color: colorScheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'Altitude : ${destination.altitude!.toInt()} m',
                        style: GoogleFonts.lato(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500),
                      ),
                    ]),
                  ],

                  const SizedBox(height: 20),

                  Container(
                    width: 40, height: 3,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text('À propos',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface)),
                  const SizedBox(height: 10),
                  Text(
                    destination.description,
                    style: GoogleFonts.lato(
                        fontSize: 14,
                        height: 1.8,
                        color: colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),

                  // ── Section notation par étoiles ─────────────────────────
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFFFE0B2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Votre note',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Builder(builder: (context) {
                          final rating =
                              ref.watch(ratingsProvider)[destination.id] ?? 0;
                          return Text(
                            rating == 0
                                ? 'Tapez une étoile pour noter'
                                : '$rating / 5 — ${_ratingLabel(rating)}',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: const Color(0xFF9BA3AF),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                        StarRatingWidget(destinationId: destination.id, size: 34),
                      ],
                    ),
                  ),

                  // Section Activités
                  if (destination.activities.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Activités',
                        style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: destination.activities
                          .map((a) => _ActivityChip(label: a))
                          .toList(),
                    ),
                  ],

                  // Section Localisation (mini-carte)
                  const SizedBox(height: 24),
                  Text('Localisation',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                              destination.latitude, destination.longitude),
                          initialZoom: 10,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.all,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.example.discover_cameroon',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(destination.latitude,
                                    destination.longitude),
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Color(0xFFC8973A),
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Actions : Like + Planifier visite + Retour ────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the like button
                          children: [
                            LikeButton(
                              initialLikes: 42,
                              destinationId: destination.id,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Bouton "Planifier une visite" → notification locale.
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _planVisit(context),
                            icon: const Icon(Icons.notifications_outlined, size: 18),
                            label: const Text('Planifier une visite', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Bouton checklist de voyage.
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => showChecklistSheet(
                              context,
                              destination.id,
                              destination.name,
                            ),
                            icon: const Icon(Icons.checklist_outlined, size: 18),
                            label: const Text('Checklist de voyage'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.secondary,
                              side: BorderSide(
                                  color: colorScheme.secondary
                                      .withValues(alpha: 0.6)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        if (allDests.length >= 2) ...[
                          const SizedBox(height: 8),
                          // Bouton comparateur de destinations.
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.push(
                                context,
                                SlideUpRoute(
                                  page: CompareScreen(
                                    destinations: allDests,
                                    preselected: destination,
                                  ),
                                ),
                              ),
                              icon: const Icon(Icons.compare_arrows, size: 18),
                              label: const Text('Comparer'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    colorScheme.onSurface.withValues(alpha: 0.7),
                                side: BorderSide(
                                    color: colorScheme.outline
                                        .withValues(alpha: 0.4)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    ), // Scaffold
    ); // ConfettiOverlay
  }
}

String _ratingLabel(int rating) {
  switch (rating) {
    case 1: return 'Décevant';
    case 2: return 'Moyen';
    case 3: return 'Bien';
    case 4: return 'Très bien';
    case 5: return 'Exceptionnel !';
    default: return '';
  }
}

class _ActivityChip extends StatelessWidget {
  final String label;
  const _ActivityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD0E8DC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A3C34),
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final Destination destination;
  const _CategoryBadge({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        destination.category.label,
        style: GoogleFonts.lato(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
