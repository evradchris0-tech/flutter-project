// Page d'accueil CamerTour — restructurée.
// Ordre : Header vert → Régions (cercles) → Nos recommandations → Séjours populaires (max 10) → Nos sponsors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'dart:math' as math;
import '../main.dart';
import '../models/destination.dart';
import '../providers/connectivity_provider.dart';
import '../providers/destinations_provider.dart';
import '../providers/view_counter_provider.dart';
import '../services/cache_service.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/destination_card.dart';
import '../widgets/destination_of_day_card.dart';
import '../widgets/shimmer_card.dart';

// ─── Données partenaires ──────────────────────────────────────────────────────
class _Partner {
  final String name;
  final String imageUrl;
  final String tagline;
  final String category;
  const _Partner({
    required this.name,
    required this.imageUrl,
    required this.tagline,
    required this.category,
  });
}

const _partners = [
  _Partner(
    name: 'Elites Voyage',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
    tagline: 'Nous créons des séjours romantiques inoubliables, 100% personnalisables.',
    category: 'Tourisme & Voyages',
  ),
  _Partner(
    name: 'Brasseries du Cameroun',
    imageUrl: 'https://images.unsplash.com/photo-1608270586620-248524c67de9?w=800',
    tagline: 'Depuis 1948, la passion du goût camerounais. Castle, Mutzig, 33 Export.',
    category: 'Boissons & Brasserie',
  ),
  _Partner(
    name: 'CRTV',
    imageUrl: 'https://images.unsplash.com/photo-1611532736597-de2d4265fba3?w=800',
    tagline: 'La voix et le regard du Cameroun sur le monde depuis 1985.',
    category: 'Médias & Communication',
  ),
  _Partner(
    name: 'CAA',
    imageUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800',
    tagline: 'Gestionnaire de la dette publique, pilier de la stabilité financière nationale.',
    category: 'Finance & Dette Publique',
  ),
  _Partner(
    name: 'DGI',
    imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800',
    tagline: 'Mobiliser les ressources fiscales pour financer le développement du Cameroun.',
    category: 'Administration & Fiscalité',
  ),
  _Partner(
    name: 'Mont Cameroun Expeditions',
    imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800',
    tagline: 'Atteignez le toit de l\'Afrique de l\'Ouest. Le Mont Cameroun, 4 095 m.',
    category: 'Aventure & Montagne',
  ),
];

// ─── Données régions ──────────────────────────────────────────────────────────
class _Region {
  final String name;
  final String filterKey;
  final String imageUrl;
  const _Region({required this.name, required this.filterKey, required this.imageUrl});
}

const _regions = [
  _Region(
    name: 'Adamaoua',
    filterKey: "Région de l'Adamaoua",
    imageUrl: 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=400',
  ),
  _Region(
    name: 'Centre',
    filterKey: 'Région du Centre',
    imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400',
  ),
  _Region(
    name: 'Est',
    filterKey: "Région de l'Est",
    imageUrl: 'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=400',
  ),
  _Region(
    name: 'Extrême-Nord',
    filterKey: "Région de l'Extrême-Nord",
    imageUrl: 'https://images.unsplash.com/photo-1509316785289-025f5b846b35?w=400',
  ),
  _Region(
    name: 'Littoral',
    filterKey: 'Région du Littoral',
    imageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=400',
  ),
  _Region(
    name: 'Nord',
    filterKey: 'Région du Nord',
    imageUrl: 'https://images.unsplash.com/photo-1541943182-d9e95a5c4e0f?w=400',
  ),
  _Region(
    name: 'Nord-Ouest',
    filterKey: 'Région du Nord-Ouest',
    imageUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=400',
  ),
  _Region(
    name: 'Ouest',
    filterKey: "Région de l'Ouest",
    imageUrl: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=400',
  ),
  _Region(
    name: 'Sud',
    filterKey: 'Région du Sud',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
  ),
  _Region(
    name: 'Sud-Ouest',
    filterKey: 'Région du Sud-Ouest',
    imageUrl: 'https://images.unsplash.com/photo-1608270586620-248524c67de9?w=400',
  ),
];

// ─── Écran principal ──────────────────────────────────────────────────────────
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _navigateToDetail(Destination destination) {
    ref.read(viewCounterProvider.notifier).increment(destination.id);
    context.push('/detail', extra: destination);
  }

  Future<void> _onRefresh() async {
    await CacheService.clearDestinations();
    await ref.read(destinationsNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final allAsync  = ref.watch(destinationsProvider);
    final isOnline  = ref.watch(connectivityProvider).valueOrNull;
    final allDests  = allAsync.valueOrNull ?? [];
    final isDark    = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF141416) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Accueil',
          style: GoogleFonts.montserrat(
            color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            onPressed: () => context.push('/search'),
            tooltip: 'Rechercher',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.gold,
        child: allAsync.when(
          loading: () => _buildSkeleton(),
          error: (e, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Erreur : $e',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              ),
            ),
          ),
          data: (allFiltered) {
            // Max 10 séjours populaires
            final popular = allFiltered.take(10).toList();

            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Bandeau offline
                if (isOnline == false)
                  const SliverToBoxAdapter(
                    child: _OfflineBanner(key: ValueKey('offline')),
                  ),

                // 1. Header vert
                const SliverToBoxAdapter(child: _HomeHeader()),

                // 2. Régions (cercles) — "Découvrir le Cameroun par région"
                SliverToBoxAdapter(
                    child: _RegionsSection(destinations: allDests)),

                // 3. Nos recommandations (carrousel)
                if (allDests.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Nos recommandations',
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: DestinationOfDayCard(
                      destinations: allDests,
                      onTap: _navigateToDetail,
                    ),
                  ),
                ],

                // 4. Séjours populaires (max 10)
                if (allFiltered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64,
                              color: AppColors.gold.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text('Aucune destination trouvée',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, fontWeight: FontWeight.w600,
                                  color: Colors.grey)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _SectionHeader(
                      title: 'Séjours populaires',
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= popular.length) return null;
                        final dest = popular[index];
                        final views = ref.watch(viewCounterProvider)[dest.id] ?? 0;
                        return AnimatedListItem(
                          index: index,
                          key: ValueKey(dest.id),
                          child: DestinationCard(
                            destination: dest,
                            viewCount: views,
                            onTap: _navigateToDetail,
                          ),
                        );
                      },
                      childCount: popular.length,
                    ),
                  ),
                  // Lien "Voir toutes les destinations"
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: OutlinedButton(
                        onPressed: () => context.push('/all-destinations'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          'Explorer toutes les destinations',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ],

                // 5. Nos sponsors (en bas)
                const SliverToBoxAdapter(child: _SponsorsSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A3C34), Color(0xFF2D6A4F)],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 80, height: 10, radius: 5),
                SizedBox(height: 10),
                ShimmerBox(width: 220, height: 20, radius: 6),
                SizedBox(height: 8),
                ShimmerBox(width: 160, height: 20, radius: 6),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: const [
                ShimmerBox(width: 80, height: 80, radius: 40),
                SizedBox(width: 16),
                ShimmerBox(width: 80, height: 80, radius: 40),
                SizedBox(width: 16),
                ShimmerBox(width: 80, height: 80, radius: 40),
                SizedBox(width: 16),
                ShimmerBox(width: 80, height: 80, radius: 40),
              ],
            ),
          ),
          const ShimmerList(count: 5),
        ],
      ),
    );
  }
}

// ─── Slogans rotatifs du header ──────────────────────────────────────────────
const _headerSlogans = [
  (
    sub: 'Partez à la découverte de',
    accent: 'l\'Afrique en miniature',
    end: '\net du Cameroun profond',
  ),
  (
    sub: 'Vivez',
    accent: 'l\'aventure ultime',
    end: '\nau cœur du Cameroun',
  ),
  (
    sub: 'Explorez les',
    accent: 'trésors cachés',
    end: '\nde nos 10 régions',
  ),
  (
    sub: 'Découvrez les',
    accent: 'merveilles authentiques',
    end: '\ndu Cameroun',
  ),
  (
    sub: 'Plongez dans',
    accent: 'une nature hors du commun',
    end: '\nsous nos cieux',
  ),
];

// ─── En-tête de section ───────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            width: 3, height: 18,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 18, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section régions (10 cercles) ────────────────────────────────────────────
class _RegionsSection extends StatelessWidget {
  final List<Destination> destinations;
  const _RegionsSection({required this.destinations});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Compter les destinations par filterKey
    final counts = <String, int>{};
    for (final d in destinations) {
      counts[d.region] = (counts[d.region] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              Container(
                width: 3, height: 18,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Découvrir le Cameroun par région',
                style: GoogleFonts.montserrat(
                  fontSize: 18, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 122,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            itemCount: _regions.length,
            itemBuilder: (context, index) {
              final region = _regions[index];
              final count = counts[region.filterKey] ?? 0;
              return _RegionCircle(region: region, count: count);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _RegionCircle extends StatelessWidget {
  final _Region region;
  final int count;
  const _RegionCircle({super.key, required this.region, required this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/region', extra: {
        'name': region.name,
        'filterKey': region.filterKey,
      }),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.6),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: region.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.primaryContainer,
                        child: const Icon(Icons.landscape,
                            color: AppColors.primary, size: 28),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.primaryContainer,
                        child: const Icon(Icons.landscape,
                            color: AppColors.primary, size: 28),
                      ),
                    ),
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -5,
                    right: -2,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              region.name,
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section sponsors ─────────────────────────────────────────────────────────
class _SponsorsSection extends StatelessWidget {
  const _SponsorsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 3, height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.gold, borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Nos sponsors',
                  style: GoogleFonts.montserrat(
                    fontSize: 18, fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 230,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: _partners.length,
              itemBuilder: (context, index) {
                final partner = _partners[index];
                return GestureDetector(
                  onTap: () => context.push('/partner'),
                  child: Container(
                    width: 260,
                    margin: const EdgeInsets.only(right: 14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                partner.name == 'Elites Voyage'
                                    ? Image.asset(
                                        'assets/images/elite_voyage.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: const Color(0xFFD0E8DC),
                                          child: const Icon(Icons.business,
                                              size: 40, color: Color(0xFF1A3C34)),
                                        ),
                                      )
                                    : CachedNetworkImage(
                                        imageUrl: partner.imageUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => const ShimmerBox(
                                            width: double.infinity,
                                            height: double.infinity),
                                        errorWidget: (_, __, ___) => Container(
                                          color: const Color(0xFFD0E8DC),
                                          child: const Icon(Icons.business,
                                              size: 40, color: Color(0xFF1A3C34)),
                                        ),
                                      ),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Color(0xAA000000),
                                      ],
                                      stops: [0.5, 1.0],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10, left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(partner.category,
                                        style: GoogleFonts.inter(
                                            color: Colors.white, fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.3)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(partner.name,
                            style: GoogleFonts.montserrat(
                                fontSize: 14, fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Text(partner.tagline,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textMedium, height: 1.4),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header vert ─────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  static final _slogan = _headerSlogans[
      math.Random(DateTime.now().millisecondsSinceEpoch ~/ 3600000)
          .nextInt(_headerSlogans.length)];

  static const _taglines = [
    'L\'Afrique en miniature dans ta poche',
    'Ton aventure camerounaise commence ici',
    'Le Cameroun comme tu ne l\'as jamais vu',
    'Explore. Rêve. Vis le Cameroun.',
    '50 destinations, une seule passion',
  ];

  static final _tagline = _taglines[
      math.Random(DateTime.now().millisecondsSinceEpoch ~/ 3600000)
          .nextInt(_taglines.length)];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3C34), Color(0xFF2D6A4F)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40, top: -40,
            child: Container(
              width: 180, height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 4, height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _tagline.toUpperCase(),
                    style: GoogleFonts.lato(
                        color: AppColors.gold, fontSize: 9,
                        fontWeight: FontWeight.w800, letterSpacing: 1.6),
                  ),
                ]),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${_slogan.sub} ',
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontSize: 24,
                            fontWeight: FontWeight.w700, height: 1.3),
                      ),
                      TextSpan(
                        text: _slogan.accent,
                        style: GoogleFonts.montserrat(
                            color: AppColors.gold, fontSize: 24,
                            fontWeight: FontWeight.w700, height: 1.3),
                      ),
                      TextSpan(
                        text: _slogan.end,
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontSize: 24,
                            fontWeight: FontWeight.w700, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bandeau hors-ligne ───────────────────────────────────────────────────────
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF7A5A1A), Color(0xFF9C7722)]),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 15, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode hors-ligne — données en cache',
              style: GoogleFonts.lato(
                  fontSize: 12, color: Colors.white,
                  fontWeight: FontWeight.w600, letterSpacing: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
