// Écran de destinations filtrées par région.
// Affiché quand l'utilisateur clique sur un cercle région dans l'accueil.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';
import '../models/destination.dart';
import '../navigation/app_page_route.dart';
import '../providers/destinations_provider.dart';
import '../providers/view_counter_provider.dart';
import '../widgets/destination_card.dart';
import '../widgets/shimmer_card.dart';
import 'detail_screen.dart';

class RegionScreen extends ConsumerStatefulWidget {
  final String name;
  final String filterKey;
  const RegionScreen({super.key, required this.name, required this.filterKey});

  @override
  ConsumerState<RegionScreen> createState() => _RegionScreenState();
}

class _RegionScreenState extends ConsumerState<RegionScreen> {
  String _cityFilter = '';

  void _navigateToDetail(Destination destination) {
    ref.read(viewCounterProvider.notifier).increment(destination.id);
    Navigator.push(
      context,
      SlideRightRoute(page: DetailScreen(destination: destination)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(destinationsProvider);
    final isDark   = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: GoogleFonts.montserrat(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: allAsync.when(
        loading: () => const ShimmerList(count: 6),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (all) {
          // Destinations de cette région (comparaison exacte avec filterKey)
          final regionDests = all
              .where((d) => d.region == widget.filterKey)
              .toList();

          // Villes disponibles dans la région pour le filtre secondaire
          final cities = regionDests.map((d) => d.name).toSet().toList()
            ..sort();

          // Filtre par ville si sélectionné
          final filtered = _cityFilter.isEmpty
              ? regionDests
              : regionDests
                  .where((d) =>
                      d.name.toLowerCase().contains(_cityFilter.toLowerCase()))
                  .toList();

          if (regionDests.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore_off_rounded,
                        size: 64,
                        color: AppColors.gold.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun séjour disponible\ndans la région ${widget.name}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => context.push('/all-destinations'),
                      child: const Text('Explorer toutes les destinations'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec compteur
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A3C34), Color(0xFF2D6A4F)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Text(
                  '${regionDests.length} séjour${regionDests.length > 1 ? 's' : ''} dans la région ${widget.name}',
                  style: GoogleFonts.lato(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ),

              // Filtre par ville (chips scrollables)
              if (cities.length > 1) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Chip "Toutes"
                      _FilterChip(
                        label: 'Toutes',
                        isSelected: _cityFilter.isEmpty,
                        onTap: () => setState(() => _cityFilter = ''),
                        isDark: isDark,
                      ),
                      ...cities.map((city) => _FilterChip(
                            label: city,
                            isSelected: _cityFilter == city,
                            onTap: () => setState(() =>
                                _cityFilter = _cityFilter == city ? '' : city),
                            isDark: isDark,
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
              ] else
                const SizedBox(height: 8),

              // Liste des destinations
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun résultat',
                          style: GoogleFonts.lato(
                              color: Colors.grey, fontSize: 15),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final dest = filtered[index];
                          final views =
                              ref.watch(viewCounterProvider)[dest.id] ?? 0;
                          return DestinationCard(
                            destination: dest,
                            viewCount: views,
                            onTap: _navigateToDetail,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF2A2F3D) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white12 : const Color(0xFFE0DDD6)),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}
