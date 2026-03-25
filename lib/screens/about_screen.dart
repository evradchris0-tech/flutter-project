// NOTE : Page À propos avec animation Flutter personnalisée.
// Concepts mis en avant :
//   • TweenAnimationBuilder : anime automatiquement entre deux valeurs sans controller.
//   • AnimationController + CurvedAnimation : contrôle manuel d'une animation loopée.
//   • Transform.rotate / scale : transformation 2D sans AnimatedWidget.
//   • stagger delay via Interval curve : décale les animations des features.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  // Controller pour la rotation continue du logo.
  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(); // boucle infinie
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('À propos')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── Logo animé ──────────────────────────────────────────────────
            const SizedBox(height: 16),
            _AnimatedLogo(rotateController: _rotateController),

            const SizedBox(height: 24),

            // Titre avec TweenAnimationBuilder (fade in + slide up)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              builder: (context, v, child) {
                return Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - v)),
                    child: child,
                  ),
                );
              },
              child: Text(
                'Camer Tour',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Guide touristique interactif 🇨🇲',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Version 1.0.0',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // ── Section fonctionnalités avec stagger ────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Fonctionnalités',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chaque feature apparaît avec un décalage (stagger via Interval).
            ..._features.asMap().entries.map((entry) {
              return _StaggeredFeatureTile(
                feature: entry.value,
                index: entry.key,
              );
            }),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // ── Palette de couleurs animée ───────────────────────────────────
            Text(
              'Palette Cameroun',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            const _ColorPalette(),

            const SizedBox(height: 32),

            // ── Crédits ─────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.school, color: colors.primary, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'Projet de démonstration Flutter',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chapitres 10, 11 & 12\nWidgets • Animations • State Management',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: colors.primary.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Logo animé (rotation + pulsation) ───────────────────────────────────────
class _AnimatedLogo extends StatelessWidget {
  final AnimationController rotateController;
  const _AnimatedLogo({required this.rotateController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Anneau extérieur qui tourne lentement.
        AnimatedBuilder(
          animation: rotateController,
          builder: (context, _) {
            return Transform.rotate(
              angle: rotateController.value * 2 * math.pi,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1A3C34).withValues(alpha: 0.15),
                    width: 2,
                  ),
                ),
                child: CustomPaint(painter: _DashedCirclePainter()),
              ),
            );
          },
        ),
        // Anneau intérieur en sens inverse.
        AnimatedBuilder(
          animation: rotateController,
          builder: (context, _) {
            return Transform.rotate(
              angle: -rotateController.value * 2 * math.pi * 0.6,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC8973A).withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
        // Centre : icône + pulsation TweenAnimationBuilder.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.0),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutSine,
          onEnd: () {}, // Flutter relance automatiquement l'animation
          builder: (context, scale, child) {
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A3C34), Color(0xFF2D6A4F)],
              ),
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 32),
          ),
        ),
      ],
    );
  }
}

// ─── Peintre pour le cercle en pointillés ────────────────────────────────────
class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A3C34).withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const dashCount = 20;
    const dashAngle = (2 * math.pi) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle * 0.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Tuile de fonctionnalité avec animation stagger ──────────────────────────
// Concept : CurvedAnimation avec Interval(begin, end) pour décaler l'apparition.
class _StaggeredFeatureTile extends StatelessWidget {
  final _Feature feature;
  final int index;

  const _StaggeredFeatureTile({required this.feature, required this.index});

  @override
  Widget build(BuildContext context) {
    // Décalage : chaque item commence 100 ms plus tard que le précédent.
    final delay = index * 0.08;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + index * 80),
      curve: Interval(delay.clamp(0.0, 0.9), 1.0, curve: Curves.easeOut),
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(30 * (1 - v), 0), child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: feature.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(feature.icon, color: feature.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    feature.title,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    feature.subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Palette de couleurs avec animation ──────────────────────────────────────
class _ColorPalette extends StatelessWidget {
  const _ColorPalette();

  static const _colors = [
    (color: Color(0xFF007A5E), label: 'Vert'),
    (color: Color(0xFFCE1126), label: 'Rouge'),
    (color: Color(0xFFFCD116), label: 'Jaune'),
    (color: Color(0xFF1A3C34), label: 'Forêt'),
    (color: Color(0xFFC8973A), label: 'Or'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _colors.asMap().entries.map((entry) {
        final i = entry.key;
        final c = entry.value;
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + i * 100),
          curve: Curves.elasticOut,
          builder: (context, v, child) =>
              Transform.scale(scale: v, child: child),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: c.color.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                c.label,
                style: GoogleFonts.lato(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Données des fonctionnalités ─────────────────────────────────────────────
class _Feature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _Feature(this.title, this.subtitle, this.icon, this.color);
}

const _features = [
  _Feature('Galerie d\'images réseau',
      'CachedNetworkImage + PageView + Hero',
      Icons.photo_library, Color(0xFF1A3C34)),
  _Feature('Navigation hors-ligne',
      'API → Cache SharedPreferences → Asset',
      Icons.wifi_off, Color(0xFF2D6A4F)),
  _Feature('Recherche intelligente',
      'Filtre temps réel + surbrillance RichText',
      Icons.search, Color(0xFFC8973A)),
  _Feature('Notation par étoiles',
      'TweenSequence + rebond cascade',
      Icons.star, Color(0xFFE5A020)),
  _Feature('Mode sombre',
      'ThemeMode persisté dans SharedPreferences',
      Icons.dark_mode, Color(0xFF4A4A8A)),
  _Feature('Compteur de vues',
      'StateNotifier<Map> + persistance',
      Icons.visibility, Color(0xFF2E86AB)),
  _Feature('Carte interactive',
      'OpenStreetMap + flutter_map',
      Icons.map, Color(0xFF388E3C)),
  _Feature('Notifications locales',
      'flutter_local_notifications',
      Icons.notifications, Color(0xFFE53935)),
  _Feature('Animations Lab',
      'ch.11 : Transform, AnimatedBuilder, AnimatedContainer…',
      Icons.science, Color(0xFF7B1FA2)),
  _Feature('State Management Riverpod',
      'FutureProvider, StateNotifier, Provider dérivé',
      Icons.hub, Color(0xFF0288D1)),
];
