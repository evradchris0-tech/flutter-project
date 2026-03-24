// NOTE : Écran de recherche avec suggestions en temps réel et surbrillance des résultats.
// Concepts mis en avant :
//   • TextField avec autofocus et TextEditingController.
//   • RichText + TextSpan : surligne les caractères correspondant à la requête.
//   • Provider dérivé local (computed) : filtre la liste à chaque frappe.
//   • Hero : partage l'animation de transition avec DetailScreen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../enums/destination_category.dart';
import '../models/destination.dart';
import '../providers/destinations_provider.dart';
import '../providers/view_counter_provider.dart';
import 'detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Filtre la liste par nom, description ou région.
  List<Destination> _filter(List<Destination> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((d) =>
        d.name.toLowerCase().contains(q) ||
        d.region.toLowerCase().contains(q) ||
        d.description.toLowerCase().contains(q) ||
        d.category.label.toLowerCase().contains(q)).toList();
  }

  void _navigateToDetail(Destination dest) {
    ref.read(viewCounterProvider.notifier).increment(dest.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(destination: dest)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinationsAsync = ref.watch(destinationsProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        leading: const BackButton(),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: GoogleFonts.lato(color: Colors.white, fontSize: 16),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: 'Rechercher une destination…',
            hintStyle: GoogleFonts.lato(
                color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70, size: 20),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
      ),
      body: destinationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (all) {
          final results = _filter(all);
          if (_query.isEmpty) {
            return _EmptySearchHint(total: all.length);
          }
          if (results.isEmpty) {
            return _NoResults(query: _query);
          }
          return Column(
            children: [
              _ResultsHeader(count: results.length, query: _query),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: results.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, i) {
                    return _SearchResultTile(
                      destination: results[i],
                      query: _query,
                      onTap: () => _navigateToDetail(results[i]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── En-tête du nombre de résultats ─────────────────────────────────────────
class _ResultsHeader extends StatelessWidget {
  final int count;
  final String query;
  const _ResultsHeader({required this.count, required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        '$count résultat${count > 1 ? 's' : ''} pour « $query »',
        style: GoogleFonts.lato(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ─── Tuile de résultat avec surbrillance + hover ─────────────────────────────
// Concept mis en avant : MouseRegion + _isHovered → AnimatedContainer change
// le fond et translate légèrement l'icône flèche pour signaler l'interactivité.
class _SearchResultTile extends StatefulWidget {
  final Destination destination;
  final String query;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.destination,
    required this.query,
    required this.onTap,
  });

  @override
  State<_SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<_SearchResultTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit:  (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _isHovered
            ? colors.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          hoverColor: Colors.transparent, // géré manuellement via MouseRegion
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icône catégorie — grossit légèrement au hover.
                AnimatedScale(
                  scale: _isHovered ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? colors.primary.withValues(alpha: 0.15)
                          : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_categoryIcon(widget.destination.category.label),
                        color: colors.primary, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HighlightedText(
                        text: widget.destination.name,
                        highlight: widget.query,
                        baseStyle: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface),
                        highlightStyle: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                            backgroundColor: colors.primaryContainer),
                      ),
                      const SizedBox(height: 2),
                      _HighlightedText(
                        text:
                            '${widget.destination.category.label} — ${widget.destination.region}',
                        highlight: widget.query,
                        baseStyle: GoogleFonts.lato(
                            fontSize: 12,
                            color: colors.onSurface.withValues(alpha: 0.5)),
                        highlightStyle: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.primary),
                      ),
                    ],
                  ),
                ),
                // La flèche glisse vers la droite au hover.
                AnimatedSlide(
                  offset: _isHovered ? const Offset(0.3, 0) : Offset.zero,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: _isHovered
                        ? colors.primary
                        : colors.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String label) {
    switch (label) {
      case 'Plage':        return Icons.beach_access;
      case 'Montagne':     return Icons.terrain;
      case 'Ville':        return Icons.location_city;
      case 'Forêt':        return Icons.forest;
      case 'Parc naturel': return Icons.park;
      default:             return Icons.place;
    }
  }
}

// ─── RichText avec surbrillance ───────────────────────────────────────────────
// Concept mis en avant : découpe une chaîne en spans normaux et surlignés.
class _HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle baseStyle;
  final TextStyle highlightStyle;

  const _HighlightedText({
    required this.text,
    required this.highlight,
    required this.baseStyle,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) return Text(text, style: baseStyle);

    final spans = <TextSpan>[];
    final lower = text.toLowerCase();
    final lowerH = highlight.toLowerCase();
    int start = 0;

    while (true) {
      final idx = lower.indexOf(lowerH, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + highlight.length),
        style: highlightStyle,
      ));
      start = idx + highlight.length;
    }

    return RichText(text: TextSpan(children: spans));
  }
}

// ─── Écrans d'état vide ───────────────────────────────────────────────────────
class _EmptySearchHint extends StatelessWidget {
  final int total;
  const _EmptySearchHint({required this.total});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search,
              size: 72,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'Tapez pour rechercher',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$total destinations disponibles',
            style: GoogleFonts.lato(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.explore_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'Aucun résultat pour « $query »',
            style: GoogleFonts.lato(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}
