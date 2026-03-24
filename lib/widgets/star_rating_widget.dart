// NOTE : Widget de notation interactive 1-5 étoiles avec animation en cascade sur chaque étoile.
// Concept mis en avant :
//   • TickerProviderStateMixin (≠ Single) pour gérer plusieurs AnimationController à la fois.
//   • TweenSequence : enchaîne grossissement (1.0→1.4) puis rebond (1.4→1.0).
//   • ScaleTransition sur chaque étoile indépendamment.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main.dart';
import '../providers/ratings_provider.dart';

class StarRatingWidget extends ConsumerStatefulWidget {
  final String destinationId;

  /// readOnly = true pour afficher la note sans interaction (ex : dans la carte).
  final bool readOnly;

  /// Taille des étoiles en pixels logiques.
  final double size;

  const StarRatingWidget({
    super.key,
    required this.destinationId,
    this.readOnly = false,
    this.size = 28,
  });

  @override
  ConsumerState<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends ConsumerState<StarRatingWidget>
    with TickerProviderStateMixin {
  // TickerProviderStateMixin (pas "Single") car on a 5 contrôleurs distincts.
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _scaleAnims;

  @override
  void initState() {
    super.initState();

    // Un AnimationController par étoile.
    _controllers = List.generate(
      5,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );

    // Chaque animation : grossit jusqu'à 1.4x puis rebondit à 1.0x.
    _scaleAnims = _controllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.4)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.4, end: 1.0)
              .chain(CurveTween(curve: Curves.bounceOut)),
          weight: 50,
        ),
      ]).animate(c);
    }).toList();
  }

  @override
  void dispose() {
    // Libérer tous les contrôleurs pour éviter les fuites mémoire.
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onStarTap(int index) {
    if (widget.readOnly) return;
    final current =
        ref.read(ratingsProvider.notifier).getRating(widget.destinationId);
    // Taper sur la note actuelle remet à 0 (désélectionne).
    final newRating = (index + 1 == current) ? 0 : index + 1;
    ref
        .read(ratingsProvider.notifier)
        .setRating(widget.destinationId, newRating);

    // Animation en cascade : chaque étoile démarre 60ms après la précédente.
    for (int i = 0; i < newRating; i++) {
      Future.delayed(Duration(milliseconds: i * 60), () {
        if (mounted) _controllers[i].forward(from: 0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch relit la note à chaque changement du provider.
    final rating = ref.watch(ratingsProvider)[widget.destinationId] ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: () => _onStarTap(i),
          child: ScaleTransition(
            scale: _scaleAnims[i],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                color: filled ? AppColors.gold : Colors.grey.shade300,
                size: widget.size,
              ),
            ),
          ),
        );
      }),
    );
  }
}
