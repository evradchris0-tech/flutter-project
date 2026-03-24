// NOTE : Confetti animé sans package externe — déclenché lors d'un ajout en favoris.
// Concepts mis en avant :
//   • CustomPainter : dessine N particules rectangulaires à chaque frame.
//   • AnimationController : durée 2 s, valeur 0→1 pilote la physique des particules.
//   • OverflowBox + Stack : les particules débordent hors des limites du widget.
//   • GlobalKey<ConfettiOverlayState> : permet à un parent de déclencher burst().
//   • Particle physics légère : gravité + vitesse initiale aléatoire + rotation.

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Modèle d'une particule ──────────────────────────────────────────────────
class _Particle {
  final double x;       // position initiale X (0..1, fraction de width)
  final double vx;      // vitesse X initiale
  final double vy;      // vitesse Y initiale (négatif = vers le haut)
  final double size;    // taille du rectangle
  final double angle;   // angle initial de rotation (radians)
  final double spin;    // vitesse de rotation
  final Color color;

  const _Particle({
    required this.x,
    required this.vx,
    required this.vy,
    required this.size,
    required this.angle,
    required this.spin,
    required this.color,
  });
}

// ─── GlobalKey pour déclencher burst() depuis l'extérieur ────────────────────
class ConfettiOverlay extends StatefulWidget {
  final Widget child;
  const ConfettiOverlay({super.key, required this.child});

  @override
  State<ConfettiOverlay> createState() => ConfettiOverlayState();
}

class ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  List<_Particle> _particles = [];
  bool _active = false;

  // Palette Cameroun + joyeux
  static const List<Color> _palette = [
    Color(0xFF4CAF50),  // vert
    Color(0xFFFFBE55),  // or
    Color(0xFFE53935),  // rouge
    Color(0xFF29B6F6),  // ciel
    Color(0xFFAB47BC),  // violet
    Color(0xFFFF7043),  // orange
    Color(0xFF26C6DA),  // turquoise
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) setState(() => _active = false);
        }
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Déclenche un burst de confetti depuis le centre haut du widget.
  void burst() {
    final rng = math.Random();
    _particles = List.generate(60, (_) {
      return _Particle(
        x:     0.3 + rng.nextDouble() * 0.4,   // centré horizontalement
        vx:    (rng.nextDouble() - 0.5) * 0.8,
        vy:    -(0.6 + rng.nextDouble() * 1.0), // vers le haut
        size:  6 + rng.nextDouble() * 8,
        angle: rng.nextDouble() * math.pi * 2,
        spin:  (rng.nextDouble() - 0.5) * 8,
        color: _palette[rng.nextInt(_palette.length)],
      );
    });
    _ctrl.forward(from: 0.0);
    if (mounted) setState(() => _active = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_active)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ConfettiPainter(
                      particles: _particles,
                      progress: _ctrl.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Painter ─────────────────────────────────────────────────────────────────
class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;  // 0..1

  const _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;
    // Gravité simulée : accélération vers le bas
    const gravity = 2.0;
    // Opacité : disparaît dans la dernière moitié
    final opacity = progress < 0.5 ? 1.0 : (1.0 - (progress - 0.5) * 2.0);

    for (final p in particles) {
      // Physique simple : x(t) = x0 + vx*t, y(t) = vy*t + ½g*t²
      final t = progress;
      final px = p.x + p.vx * t;
      final py = 0.0 + p.vy * t + 0.5 * gravity * t * t;

      // Coordonnées pixels (y=0 en haut, vers le bas positif)
      final cx = px * size.width;
      final cy = py * size.height + size.height * 0.2; // centré vers le haut

      final currentAngle = p.angle + p.spin * t;

      paint.color = p.color.withValues(alpha: opacity.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(currentAngle);

      // Rectangle aplati (effet bandelette)
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.45,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress;
}
