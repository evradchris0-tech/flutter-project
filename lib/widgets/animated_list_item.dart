// NOTE : Widget ajoutant une animation d'entrée en cascade à chaque élément de liste.
// Concept mis en avant : AnimatedBuilder (ch.11) — sépare la logique d'animation du widget enfant.
//
// ── Différence avec l'approche addListener + setState (section A du Lab) ──
//   • child est un paramètre statique d'AnimatedBuilder → instancié UNE SEULE FOIS
//   • builder() est le seul code réexécuté à chaque frame → plus efficace
//   • Le widget parent n'appelle jamais setState() lui-même

import 'package:flutter/material.dart';

class AnimatedListItem extends StatefulWidget {
  final Widget child;

  /// Position dans la liste — détermine le délai de départ de l'animation.
  final int index;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  /// Opacité : 0.0 → 1.0
  late Animation<double> _fadeAnim;

  /// Translation verticale en pixels : 30px (bas) → 0px (position finale).
  /// On utilise un double (pixels) plutôt qu'un Offset pour plus de clarté.
  late Animation<double> _translateAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _translateAnim = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    // Effet cascade : chaque carte attend 70ms de plus que la précédente.
    // clamp(0, 5) plafonne le délai à 5 × 70 = 350ms maximum.
    final delay = Duration(milliseconds: 70 * widget.index.clamp(0, 5));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder : seul builder() est réexécuté à chaque frame d'animation.
    // child (widget.child) est instancié UNE SEULE FOIS avant le premier frame.
    return AnimatedBuilder(
      animation: _controller,
      // child est pré-construit et transmis au builder sans être reconstruit.
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            // La carte remonte de 30px vers sa position finale (Offset.zero).
            offset: Offset(0, _translateAnim.value),
            child: child, // widget enfant réutilisé tel quel
          ),
        );
      },
    );
  }
}
