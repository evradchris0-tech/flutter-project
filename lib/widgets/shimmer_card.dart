// NOTE : Skeleton shimmer — placeholder animé pendant le chargement des destinations.
// Concept mis en avant : AnimatedBuilder + LinearGradient avec translate pour créer
// l'effet de lumière balayant les formes sans aucun package externe.

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Widget public : liste de N cartes shimmer ────────────────────────────────
class ShimmerList extends StatelessWidget {
  final int count;
  const ShimmerList({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemBuilder: (_, i) => _ShimmerCard(delay: i * 80),
    );
  }
}

// ─── Carte shimmer individuelle ───────────────────────────────────────────────
class _ShimmerCard extends StatefulWidget {
  final int delay; // ms de délai pour décaler les cartes
  const _ShimmerCard({required this.delay});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    // Démarre avec un délai pour que les cartes ne soient pas en phase.
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat();
    });
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
    final highlightColor =
        isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              // Le gradient se déplace de gauche à droite (shimmer sweep).
              final sweepX = _anim.value * 2 - 0.5;
              return ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment(sweepX - 1, 0),
                    end: Alignment(sweepX + 1, 0),
                    colors: [baseColor, highlightColor, baseColor],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds);
                },
                child: Row(
                  children: [
                    // Placeholder image
                    Container(
                        width: 110,
                        height: 100,
                        color: baseColor),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre
                          Container(
                            height: 14,
                            width: double.infinity,
                            margin: const EdgeInsets.only(right: 40),
                            decoration: BoxDecoration(
                              color: highlightColor,
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Badge catégorie
                          Container(
                            height: 10,
                            width: 70,
                            decoration: BoxDecoration(
                              color: highlightColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Ligne description 1
                          Container(
                            height: 10,
                            width: double.infinity,
                            margin: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: highlightColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Ligne description 2
                          Container(
                            height: 10,
                            width: 120,
                            decoration: BoxDecoration(
                              color: highlightColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Utilitaire pour un bloc shimmer rectangulaire quelconque.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const ShimmerBox(
      {super.key,
      required this.width,
      required this.height,
      this.radius = 8});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E8E8);
    final hi = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final x = _ctrl.value * 2 - 0.5;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(x - 1, 0),
              end: Alignment(x + 1, 0),
              colors: [base, hi, base],
            ),
          ),
        );
      },
    );
  }
}

// ignore: unused_element
double _unused = math.pi; // évite l'import inutilisé
