// Widget DestinationCard — badge catégorie sorti de l'image, placé au-dessus du titre.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../enums/destination_category.dart';
import '../models/destination.dart';
import 'shimmer_card.dart';

class DestinationCard extends StatefulWidget {
  final Destination destination;
  final void Function(Destination) onTap;
  final int viewCount;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.viewCount = 0,
  });

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  bool _isExpanded = false;
  bool _isHovered  = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme  = Theme.of(context).colorScheme;
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final hasActivities = widget.destination.activities.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit:  (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.015 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.12),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Material(
              color: colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: _isHovered
                      ? colorScheme.primary.withOpacity(0.3)
                      : const Color(0xFFF0EDE6),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Contenu principal ──────────────────────────────────
                    InkWell(
                      onTap: () => widget.onTap(widget.destination),
                      hoverColor: colorScheme.primary.withValues(alpha: 0.04),
                      child: SizedBox(
                        height: 148,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Image à gauche (sans badge)
                            _DestinationThumbnail(
                              destination: widget.destination,
                              heroTag: 'hero-${widget.destination.id}',
                            ),
                            // Infos à droite : badge catégorie + titre + durée + prix
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Badge catégorie au-dessus du titre
                                    _CategoryBadge(
                                        destination: widget.destination),
                                    const SizedBox(height: 6),
                                    // Titre
                                    AnimatedDefaultTextStyle(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        height: 1.3,
                                        color: _isHovered
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                      ),
                                      child: Text(
                                        widget.destination.titreAccroche,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Spacer(),
                                    // Durée
                                    Row(
                                      children: [
                                        Icon(Icons.access_time_rounded,
                                            size: 13,
                                            color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          widget.destination.duree,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    // Prix
                                    RichText(
                                      text: TextSpan(
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                        ),
                                        children: [
                                          const TextSpan(text: 'À partir de '),
                                          TextSpan(
                                            text:
                                                '${widget.destination.prixAppel} FCFA',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Bouton Activités ───────────────────────────────────
                    if (hasActivities) ...[
                      Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white12
                              : const Color(0xFFF0EDE6)),
                      InkWell(
                        onTap: () =>
                            setState(() => _isExpanded = !_isExpanded),
                        hoverColor:
                            colorScheme.primary.withValues(alpha: 0.06),
                        child: Container(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFF8F8F6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.local_activity_outlined,
                                  size: 14, color: colorScheme.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Activités',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const Spacer(),
                              AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOutCubic,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // ── Activités expandables ──────────────────────────────
                    AnimatedSize(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOutCubic,
                      child: _isExpanded
                          ? Container(
                              width: double.infinity,
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : const Color(0xFFF8F8F6),
                              padding:
                                  const EdgeInsets.fromLTRB(14, 4, 14, 14),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: widget.destination.activities
                                    .map((a) => _ActivityChip(label: a))
                                    .toList(),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Miniature (image sans badge) ────────────────────────────────────────────
class _DestinationThumbnail extends StatelessWidget {
  final Destination destination;
  final String heroTag;

  const _DestinationThumbnail(
      {required this.destination, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: heroTag,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: destination.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const ShimmerBox(width: 120, height: 148),
                errorWidget: (context, url, error) => Container(
                  color:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.landscape,
                      color:
                          Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ),
          // Gradient bas pour lisibilité du nom
          Positioned(
            left: 0, right: 0, bottom: 0,
            height: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Nom de la destination en bas
          Positioned(
            bottom: 7, left: 8, right: 8,
            child: Text(
              destination.name,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badge catégorie (au-dessus du titre) ────────────────────────────────────
class _CategoryBadge extends StatelessWidget {
  final Destination destination;
  const _CategoryBadge({required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(destination.category.icon,
              size: 10,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            destination.category.label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chip d'activité ─────────────────────────────────────────────────────────
class _ActivityChip extends StatelessWidget {
  final String label;
  const _ActivityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border:
            isDark ? Border.all(color: Colors.white10, width: 0.5) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark
              ? Colors.white70
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
