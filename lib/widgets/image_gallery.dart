// NOTE : Galerie d'images défilable horizontalement pour la page de détail.
// Concepts mis en avant :
//   • PageView + PageController + indicateur de page animé (dots).
//   • CachedNetworkImage : télécharge l'image une seule fois puis la met en cache
//     sur le disque — fonctionne hors ligne après le premier chargement.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final String heroTag;

  const ImageGallery({
    super.key,
    required this.imageUrls,
    required this.heroTag,
  });

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              // CachedNetworkImage : affiche un placeholder pendant le chargement,
              // et garde l'image dans le cache disque pour les visites suivantes.
              final networkImage = CachedNetworkImage(
                imageUrl: widget.imageUrls[i],
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                // Placeholder animé pendant le téléchargement.
                placeholder: (context, url) => Container(
                  color: const Color(0xFFD0E8DC),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1A3C34),
                      strokeWidth: 2,
                    ),
                  ),
                ),
                // Erreur (pas de réseau et image absente du cache).
                errorWidget: (context, url, error) => Container(
                  color: const Color(0xFF1A3C34),
                  child: const Icon(
                      Icons.landscape, color: Colors.white54, size: 60),
                ),
              );

              // Le premier élément porte le Hero pour la transition depuis la liste.
              return i == 0
                  ? Hero(tag: widget.heroTag, child: networkImage)
                  : networkImage;
            },
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 8),
          _DotsIndicator(
              count: widget.imageUrls.length, current: _currentPage),
        ],
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotsIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == current ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: i == current
                ? const Color(0xFF1A3C34)
                : const Color(0xFFD0E8DC),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
