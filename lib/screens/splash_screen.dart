// NOTE : Écran de démarrage affiché au lancement de l'application avant la page d'accueil.
// Concept mis en avant : AnimationController unique pilotant plusieurs animations via des Interval.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// SingleTickerProviderStateMixin fournit le "ticker" nécessaire à l'AnimationController.
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Chaque Interval définit la plage de temps pendant laquelle l'animation s'active.
    final logoInterval = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    final titleInterval = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.75, curve: Curves.easeOutCubic),
    );
    final taglineInterval = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(logoInterval);
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    // Offset(0, 0.4) = décalé de 40% vers le bas au départ.
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(titleInterval);
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(titleInterval);
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(taglineInterval);

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        context.go('/home');
      });
    });
  }

  @override
  void dispose() {
    // Toujours libérer l'AnimationController pour éviter les fuites mémoire.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3C34),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo : ScaleTransition + FadeTransition combinés.
            ScaleTransition(
              scale: _logoScale,
              child: FadeTransition(
                opacity: _logoFade,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: const Color(0xFFC8973A),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.explore,
                    color: Color(0xFFC8973A),
                    size: 50,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Titre sur une seule ligne : "Kmer" blanc + "Tour" doré
            SlideTransition(
              position: _titleSlide,
              child: FadeTransition(
                opacity: _titleFade,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Kmer',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      TextSpan(
                        text: 'Tour',
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xFFC8973A),
                          fontSize: 48,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            FadeTransition(
              opacity: _taglineFade,
              child: Text(
                'Explore · Rêve · Vis le Cameroun',
                style: GoogleFonts.lato(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            const SizedBox(height: 60),

            FadeTransition(
              opacity: _taglineFade,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: const Color(0xFFC8973A).withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
