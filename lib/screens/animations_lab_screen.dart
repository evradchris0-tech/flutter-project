// NOTE : Écran de démonstration interactive de tous les concepts d'animations du chapitre 11.
// Chaque section A→G illustre un concept différent avec un exemple interactif.
// Concepts mis en avant :
//   A - Transform.rotate  (+ addListener / setState)
//   B - Transform.scale   (+ Tween.chain + drive())
//   C - Transform.translate (+ Tween<Offset>)
//   D - AnimatedBuilder   (séparation animation / widget)
//   E - AnimatedContainer (widget implicitement animé)
//   F - AnimatedOpacity   (fondu sans AnimationController)
//   G - AnimatedAlign     (déplacement d'alignement animé)

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class AnimationsLabScreen extends StatelessWidget {
  const AnimationsLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animations Lab')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: const [
          _SectionHeader(
            letter: 'A',
            title: 'Transform.rotate',
            subtitle: 'addListener + setState — approche directe',
          ),
          _RotateDemo(),
          SizedBox(height: 20),
          _SectionHeader(
            letter: 'B',
            title: 'Transform.scale',
            subtitle: 'Tween.chain() + controller.drive()',
          ),
          _ScaleDemo(),
          SizedBox(height: 20),
          _SectionHeader(
            letter: 'C',
            title: 'Transform.translate',
            subtitle: 'Tween<Offset> — Offset supporte l\'interpolation',
          ),
          _TranslateDemo(),
          SizedBox(height: 20),
          _SectionHeader(
            letter: 'D',
            title: 'AnimatedBuilder',
            subtitle: 'child construit 1 fois — builder rappelé à chaque frame',
          ),
          _AnimatedBuilderDemo(),
          SizedBox(height: 20),
          _SectionHeader(
            letter: 'E',
            title: 'AnimatedContainer',
            subtitle: 'Aucun controller — setState suffit',
          ),
          _AnimatedContainerDemo(),
          SizedBox(height: 20),
          _SectionHeader(
            letter: 'F',
            title: 'AnimatedOpacity',
            subtitle: 'Fondu automatique quand opacity change',
          ),
          _AnimatedOpacityDemo(),
          SizedBox(height: 20),
          _SectionHeader(
            letter: 'G',
            title: 'AnimatedAlign',
            subtitle: 'Déplacement fluide entre alignements',
          ),
          _AnimatedAlignDemo(),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Header de section ──────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String letter;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.letter,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              letter,
              style: GoogleFonts.lato(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: AppColors.textMedium,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Conteneur de démo ──────────────────────────────────────────────────────
class _DemoCard extends StatelessWidget {
  final Widget child;

  const _DemoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0EDE6)),
      ),
      child: Center(child: child),
    );
  }
}

// ─── A : Transform.rotate ───────────────────────────────────────────────────
// Approche classique : addListener() appelle setState à chaque frame.
// ⚠️ Le widget ENTIER est reconstruit — voir section D pour la version optimisée.
class _RotateDemo extends StatefulWidget {
  const _RotateDemo();

  @override
  State<_RotateDemo> createState() => _RotateDemoState();
}

class _RotateDemoState extends State<_RotateDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _angle = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    // addListener déclenche setState à chaque valeur — reconstruit tout le widget.
    _controller.addListener(() {
      setState(() => _angle = _controller.value * 2 * math.pi);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        children: [
          // Transform.rotate applique la rotation sans déplacer le widget.
          Transform.rotate(
            angle: _angle,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.explore, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _controller.forward(from: 0),
            child: const Text('Faire tourner'),
          ),
        ],
      ),
    );
  }
}

// ─── B : Transform.scale ────────────────────────────────────────────────────
// drive() crée une Animation dérivée avec une plage de valeurs personnalisée.
// chain() compose un Tween et un CurveTween en une seule opération.
class _ScaleDemo extends StatefulWidget {
  const _ScaleDemo();

  @override
  State<_ScaleDemo> createState() => _ScaleDemoState();
}

class _ScaleDemoState extends State<_ScaleDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // chain() compose le Tween de valeur (1.0→1.6) et le Tween de courbe.
    // drive() attache ce Tween au controller pour produire une Animation<double>.
    _scaleAnim = _controller.drive(
      Tween<double>(begin: 1.0, end: 1.6)
          .chain(CurveTween(curve: Curves.elasticOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        children: [
          // AnimatedBuilder + Transform.scale : seul le subtree animé est reconstruit.
          AnimatedBuilder(
            animation: _scaleAnim,
            // child est instancié UNE SEULE FOIS et passé au builder.
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🇨🇲  Cameroun',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            builder: (context, child) => Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _controller.forward(from: 0),
                child: const Text('Agrandir'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _controller.reverse(),
                child: const Text('Réduire'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── C : Transform.translate ────────────────────────────────────────────────
// Tween<Offset> interpole entre deux positions en pixels.
// Offset surcharge les opérateurs + et - ce qui permet l'interpolation.
class _TranslateDemo extends StatefulWidget {
  const _TranslateDemo();

  @override
  State<_TranslateDemo> createState() => _TranslateDemoState();
}

class _TranslateDemoState extends State<_TranslateDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnim;
  bool _movedRight = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    // Tween<Offset> fonctionne parce qu'Offset surcharge + et - (voir dart:ui).
    _offsetAnim = _controller.drive(
      Tween<Offset>(
        begin: const Offset(-90, 0),
        end: const Offset(90, 0),
      ).chain(CurveTween(curve: Curves.easeInOutCubic)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: AnimatedBuilder(
              animation: _offsetAnim,
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.place, color: Colors.white, size: 28),
              ),
              builder: (context, child) => Transform.translate(
                offset: _offsetAnim.value,
                child: child,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              setState(() => _movedRight = !_movedRight);
              _movedRight ? _controller.forward() : _controller.reverse();
            },
            child: Text(_movedRight ? '← Gauche' : 'Droite →'),
          ),
        ],
      ),
    );
  }
}

// ─── D : AnimatedBuilder ────────────────────────────────────────────────────
// Même effet de rotation qu'en A mais SANS setState dans le parent.
// Avantage : seul le subtree de builder() est reconstruit, pas le widget entier.
// child est construit UNE SEULE FOIS et réutilisé à chaque frame.
class _AnimatedBuilderDemo extends StatefulWidget {
  const _AnimatedBuilderDemo();

  @override
  State<_AnimatedBuilderDemo> createState() => _AnimatedBuilderDemoState();
}

class _AnimatedBuilderDemoState extends State<_AnimatedBuilderDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // rotation continue en boucle
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _controller,
            // child : construit UNE SEULE FOIS, transmis au builder sans rebuild.
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.flight, color: Colors.white, size: 36),
            ),
            // builder : rappelé à chaque frame, mais child arrive pré-construit.
            builder: (context, child) {
              return Transform.rotate(
                // _controller.value : 0.0 → 1.0, multiplié par 2π = tour complet.
                angle: _controller.value * 2 * math.pi,
                child: child, // child réutilisé directement
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            'Rotation continue sans setState',
            style: GoogleFonts.lato(
              fontSize: 12,
              color: AppColors.textMedium,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── E : AnimatedContainer ──────────────────────────────────────────────────
// Widget implicitement animé : aucun AnimationController nécessaire.
// Un simple setState déclenche l'interpolation automatique de toutes les propriétés.
class _AnimatedContainerDemo extends StatefulWidget {
  const _AnimatedContainerDemo();

  @override
  State<_AnimatedContainerDemo> createState() =>
      _AnimatedContainerDemoState();
}

class _AnimatedContainerDemoState extends State<_AnimatedContainerDemo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        children: [
          // Toutes les propriétés (width, height, color, borderRadius) sont
          // interpolées automatiquement lors du changement d'état.
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            width: _expanded ? 240 : 110,
            height: _expanded ? 110 : 56,
            decoration: BoxDecoration(
              color: _expanded ? AppColors.primary : AppColors.gold,
              borderRadius: BorderRadius.circular(_expanded ? 24 : 8),
              boxShadow: [
                BoxShadow(
                  color: (_expanded ? AppColors.primary : AppColors.gold)
                      .withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _expanded ? '🇨🇲  Cameroun' : 'CM',
                style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: _expanded ? 20 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Un seul setState — AnimatedContainer fait toute l'interpolation.
          ElevatedButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'Réduire' : 'Agrandir'),
          ),
        ],
      ),
    );
  }
}

// ─── F : AnimatedOpacity ────────────────────────────────────────────────────
// Anime le fondu quand la propriété opacity change.
// Pas d'AnimationController — setState + durée suffisent.
class _AnimatedOpacityDemo extends StatefulWidget {
  const _AnimatedOpacityDemo();

  @override
  State<_AnimatedOpacityDemo> createState() => _AnimatedOpacityDemoState();
}

class _AnimatedOpacityDemoState extends State<_AnimatedOpacityDemo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        children: [
          // opacity passe de 1.0 → 0.0 en 600ms de manière fluide.
          AnimatedOpacity(
            opacity: _visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.landscape, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Mont Cameroun — 4 095 m',
                    style: GoogleFonts.lato(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() => _visible = !_visible),
            child: Text(_visible ? 'Masquer' : 'Afficher'),
          ),
        ],
      ),
    );
  }
}

// ─── G : AnimatedAlign ──────────────────────────────────────────────────────
// Anime le déplacement d'un widget entre différents alignements dans son parent.
// Utilise curve: Curves.easeInOutBack pour un effet de rebond subtil.
class _AnimatedAlignDemo extends StatefulWidget {
  const _AnimatedAlignDemo();

  @override
  State<_AnimatedAlignDemo> createState() => _AnimatedAlignDemoState();
}

class _AnimatedAlignDemoState extends State<_AnimatedAlignDemo> {
  // Les 4 coins parcourus en cycle à chaque tap.
  static const _corners = [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomRight,
    Alignment.bottomLeft,
  ];
  int _cornerIndex = 0;

  @override
  Widget build(BuildContext context) {
    return _DemoCard(
      child: Column(
        children: [
          SizedBox(
            height: 130,
            child: AnimatedAlign(
              alignment: _corners[_cornerIndex],
              duration: const Duration(milliseconds: 600),
              // easeInOutBack : dépasse légèrement la cible puis revient (effet élastique).
              curve: Curves.easeInOutBack,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => setState(
              () => _cornerIndex = (_cornerIndex + 1) % _corners.length,
            ),
            child: const Text('Déplacer'),
          ),
        ],
      ),
    );
  }
}
