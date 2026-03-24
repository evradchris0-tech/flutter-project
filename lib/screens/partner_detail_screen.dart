import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/shimmer_card.dart';

// Données détaillées par partenaire (alignées avec le slider de l'accueil)
class _PartnerData {
  final String name;
  final String heroImageUrl;
  final String badgeLabel;
  final String category;
  final String aboutText;
  final List<_OfferData> offers;
  final String infoLabel1;
  final String infoValue1;
  final String infoLabel2;
  final String infoValue2;

  const _PartnerData({
    required this.name,
    required this.heroImageUrl,
    required this.badgeLabel,
    required this.category,
    required this.aboutText,
    required this.offers,
    required this.infoLabel1,
    required this.infoValue1,
    required this.infoLabel2,
    required this.infoValue2,
  });
}

class _OfferData {
  final String title;
  final String desc;
  final String code;
  const _OfferData({required this.title, required this.desc, required this.code});
}

// Données Elite Voyage affichées par défaut
const _eliteVoyage = _PartnerData(
  name: 'Elite Voyage',
  heroImageUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200',
  badgeLabel: 'PARTENAIRE DIAMANT',
  category: 'Tourisme & Voyages',
  aboutText: 'Elite Voyage est l\'agence de voyages premium de référence au Cameroun. '
      'Spécialisée dans la conception de séjours sur mesure, l\'équipe accompagne '
      'chaque voyageur avec une attention particulière pour les détails : '
      'hébergements d\'exception, expériences locales authentiques, et '
      'programmes romantiques personnalisables à 100%.',
  offers: [
    _OfferData(
      title: 'Séjour Romantique Kribi',
      desc: '3 nuits en lodge vue mer + dîner aux chandelles + spa privatif.',
      code: 'ELITE_KRIBI',
    ),
    _OfferData(
      title: 'Circuit Grands Espaces',
      desc: 'Waza + Rhumsiki + Mont Mandara en 7 jours tout inclus.',
      code: 'ELITE_NORD',
    ),
  ],
  infoLabel1: 'Spécialité',
  infoValue1: 'Séjours Romantiques',
  infoLabel2: 'Options',
  infoValue2: '100% Personnalisable',
);

class PartnerDetailScreen extends StatelessWidget {
  const PartnerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Par défaut on affiche Elite Voyage
    const partner = _eliteVoyage;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar Hero ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: const Color(0xFF1A3C34),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.35),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: partner.heroImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ShimmerBox(
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // Gradient bas
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC000000)],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                  // Contenu en bas du hero
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC8973A).withOpacity(0.92),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            partner.badgeLabel,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          partner.name,
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Tagline principale Elite Voyage
                        Text(
                          'Nous créons des séjours\nromantiques inoubliables,\n100% personnalisables.',
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.88),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Contenu ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info boxes
                  Row(
                    children: [
                      _infoBox(Icons.verified, partner.infoLabel1, partner.infoValue1),
                      const SizedBox(width: 14),
                      _infoBox(Icons.tune_rounded, partner.infoLabel2, partner.infoValue2),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'À propos',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    partner.aboutText,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      height: 1.65,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Offres exclusives',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...partner.offers.map((o) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _offerCard(title: o.title, desc: o.desc, code: o.code),
                  )),

                  const SizedBox(height: 20),

                  // Témoignage
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F1EA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote, color: Color(0xFFC8973A), size: 28),
                        const SizedBox(height: 8),
                        Text(
                          'Grâce à Elite Voyage, notre voyage de noces à Kribi était parfait. '
                          'Chaque détail était pensé pour nous. Une expérience à revivre.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.6,
                            color: Colors.black87,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '— Marie & Jean-Paul, Yaoundé',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3C34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFF1A3C34).withOpacity(0.4),
                      ),
                      child: Text(
                        'Planifier mon séjour',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F1EA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFFC8973A), size: 22),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _offerCard({required String title, required String desc, required String code}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0DDD6)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0E8DC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Code: $code',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A3C34),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
