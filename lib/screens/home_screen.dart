// Page d'accueil avec loader skeleton, infinite scroll (pagination 10 par 10), et vraies données.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../enums/destination_category.dart';
import '../main.dart';
import '../models/destination.dart';
import '../providers/connectivity_provider.dart';
import '../providers/destinations_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/view_counter_provider.dart';
import '../providers/sort_provider.dart';
import '../services/cache_service.dart';
import '../widgets/animated_list_item.dart';
import '../widgets/destination_card.dart';
import '../widgets/destination_of_day_card.dart';
import '../widgets/shimmer_card.dart';

// taille de chaque page chargée
const _kPageSize = 10;

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
    name: 'Elite Voyage',
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

class _FeaturedCity {
  final String name;
  final String imageUrl;
  final String description;
  final String tag;

  const _FeaturedCity({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.tag,
  });
}

const _featuredCities = [
  _FeaturedCity(
    name: 'Kousseri',
    imageUrl: 'https://images.unsplash.com/photo-1541943182-d9e95a5c4e0f?w=800',
    description: 'Aux portes du Tchad, carrefour entre deux pays et deux cultures.',
    tag: 'Extrême-Nord',
  ),
  _FeaturedCity(
    name: 'Maroua',
    imageUrl: 'https://images.unsplash.com/photo-1516026672322-bc52d61a55d5?w=800',
    description: 'Capitale culturelle du Grand Nord, berceau de l\'artisanat.',
    tag: 'Extrême-Nord',
  ),
  _FeaturedCity(
    name: 'Ngaoundéré',
    imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
    description: 'Entre savane et hauts plateaux de l\'Adamaoua.',
    tag: 'Adamaoua',
  ),
  _FeaturedCity(
    name: 'Ebolowa',
    imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
    description: 'Cité du cacao, dans un écrin de forêt équatoriale.',
    tag: 'Sud',
  ),
  _FeaturedCity(
    name: 'Bafoussam',
    imageUrl: 'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800',
    description: 'Cœur économique et culturel de la région de l\'Ouest.',
    tag: 'Ouest',
  ),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  // nombre d'éléments visibles — augmente au scroll
  int _visibleCount = _kPageSize;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // charge la page suivante quand on est à 80% du bas
  void _onScroll() {
    final pos = _scrollController.position;
    final threshold = pos.maxScrollExtent * 0.8;
    if (pos.pixels >= threshold && !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final allDests = ref.read(sortedDestinationsProvider).valueOrNull ?? [];
    if (_visibleCount >= allDests.length) return;

    setState(() => _isLoadingMore = true);
    // simule un léger délai réseau pour montrer le loader
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _visibleCount = (_visibleCount + _kPageSize).clamp(0, allDests.length);
        _isLoadingMore = false;
      });
    }
  }

  void _navigateToDetail(Destination destination) {
    ref.read(viewCounterProvider.notifier).increment(destination.id);
    context.push('/detail', extra: destination);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _visibleCount = _kPageSize;
      _isLoadingMore = false;
    });
    await CacheService.clearDestinations();
    await ref.read(destinationsNotifierProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(sortedDestinationsProvider);
    final totalAsync    = ref.watch(destinationsProvider);
    final isOnline      = ref.watch(connectivityProvider).valueOrNull;
    final isDark        = ref.watch(themeProvider) == ThemeMode.dark;
    final allDests      = totalAsync.valueOrNull ?? [];

    return Scaffold(
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
        child: filteredAsync.when(
          // skeleton loader complet pendant le premier chargement
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
            final visible = allFiltered.take(_visibleCount).toList();
            final hasMore = _visibleCount < allFiltered.length;

            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (isOnline == false)
                  const SliverToBoxAdapter(child: _OfflineBanner(key: ValueKey('offline'))),

                const SliverToBoxAdapter(child: _HomeHeader()),
                const SliverToBoxAdapter(child: _AdSlider()),
                const SliverToBoxAdapter(child: _FeaturedCitiesSection()),

                if (allFiltered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: AppColors.gold.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text('Aucune destination trouvée',
                              style: GoogleFonts.montserrat(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),

                if (allFiltered.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
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
                            'Séjours populaires',
                            style: GoogleFonts.montserrat(
                              fontSize: 18, fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${visible.length} / ${allFiltered.length}',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                if (allDests.isNotEmpty)
                  SliverToBoxAdapter(
                    child: DestinationOfDayCard(
                      destinations: allDests,
                      onTap: _navigateToDetail,
                    ),
                  ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= visible.length) return null;
                      final dest = visible[index];
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
                    childCount: visible.length,
                  ),
                ),

                SliverToBoxAdapter(
                  child: _isLoadingMore
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
                                const SizedBox(height: 8),
                                Text('Chargement…',
                                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        )
                      : hasMore
                          ? const SizedBox(height: 32)
                          : const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text('Toutes les destinations affichées',
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                              ),
                            ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // skeleton complet : header + partenaires + liste de cartes shimmer
  Widget _buildSkeleton() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // skeleton du header
          Container(
            height: 120,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A3C34), Color(0xFF2D6A4F)],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 80, height: 10, radius: 5),
                const SizedBox(height: 10),
                const ShimmerBox(width: 220, height: 20, radius: 6),
                const SizedBox(height: 8),
                const ShimmerBox(width: 160, height: 20, radius: 6),
              ],
            ),
          ),
          // skeleton partenaires (scroll horizontal)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: const [
                ShimmerBox(width: 260, height: 230, radius: 12),
                SizedBox(width: 12),
                ShimmerBox(width: 260, height: 230, radius: 12),
              ],
            ),
          ),
          // skeleton liste destinations
          const ShimmerList(count: 5),
        ],
      ),
    );
  }
}

class _FeaturedCitiesSection extends StatelessWidget {
  const _FeaturedCitiesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 3, height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.gold, borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text('À explorer',
                    style: GoogleFonts.montserrat(
                        fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _featuredCities.length,
              itemBuilder: (context, index) {
                final city = _featuredCities[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: city.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const ShimmerBox(
                              width: double.infinity, height: double.infinity),
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFFD0E8DC),
                            child: const Icon(Icons.location_city,
                                color: Color(0xFF1A3C34), size: 40),
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xDD000000)],
                              stops: [0.4, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10, left: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(city.tag,
                                style: GoogleFonts.inter(
                                    color: Colors.white, fontSize: 9,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                        Positioned(
                          bottom: 10, left: 10, right: 10,
                          child: Text(
                            city.name,
                            style: GoogleFonts.montserrat(
                              color: Colors.white, fontSize: 16,
                              fontWeight: FontWeight.w800, height: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
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

class _AdSlider extends StatelessWidget {
  const _AdSlider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  width: 3, height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.gold, borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text('Nos partenaires privilégiés',
                    style: GoogleFonts.montserrat(
                        fontSize: 18, fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
          const SizedBox(height: 12),
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
                                partner.name == 'Elite Voyage'
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
                                            width: double.infinity, height: double.infinity),
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
                                      colors: [Colors.transparent, Color(0xAA000000)],
                                      stops: [0.5, 1.0],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10, left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(partner.category,
                                        style: GoogleFonts.inter(
                                            color: Colors.white, fontSize: 9,
                                            fontWeight: FontWeight.w700, letterSpacing: 0.3)),
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
                                fontSize: 12, color: AppColors.textMedium, height: 1.4),
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

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
                      color: AppColors.gold, borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('GUIDE TOURISTIQUE OFFICIEL',
                      style: GoogleFonts.lato(
                          color: AppColors.gold, fontSize: 10,
                          fontWeight: FontWeight.w800, letterSpacing: 1.8)),
                ]),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Découvrez les ',
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontSize: 26,
                            fontWeight: FontWeight.w700, height: 1.2),
                      ),
                      TextSpan(
                        text: 'merveilles authentiques',
                        style: GoogleFonts.montserrat(
                            color: AppColors.gold, fontSize: 26,
                            fontWeight: FontWeight.w700, height: 1.2),
                      ),
                      TextSpan(
                        text: '\ndu Cameroun',
                        style: GoogleFonts.montserrat(
                            color: Colors.white, fontSize: 26,
                            fontWeight: FontWeight.w700, height: 1.2),
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

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF7A5A1A), Color(0xFF9C7722)]),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 15, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text('Mode hors-ligne — données en cache',
                style: GoogleFonts.lato(
                    fontSize: 12, color: Colors.white,
                    fontWeight: FontWeight.w600, letterSpacing: 0.2)),
          ),
        ],
      ),
    );
  }
}
