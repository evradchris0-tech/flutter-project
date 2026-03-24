// NOTE : Effet parallaxe sur l'image de la carte — l'image se déplace plus lentement
// que le scroll, créant une profondeur visuelle.
// Concepts mis en avant :
//   • FlowDelegate remplacé par la combinaison ScrollPosition + LayoutBuilder.
//   • GlobalKey + RenderBox.localToGlobal : connaître la position du widget à l'écran.
//   • Alignment dynamique : mappée depuis la position verticale dans la fenêtre.
//   • Listener sur ScrollNotification via NotificationListener (pas besoin de ScrollController).

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ParallaxImage extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BorderRadius borderRadius;
  // Facteur parallaxe : 0 = pas de parallaxe, 0.5 = demi-vitesse.
  final double factor;

  const ParallaxImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.width,
    this.borderRadius = BorderRadius.zero,
    this.factor = 0.35,
  });

  @override
  State<ParallaxImage> createState() => _ParallaxImageState();
}

class _ParallaxImageState extends State<ParallaxImage> {
  final _key = GlobalKey();
  double _alignment = 0.0; // -1 (haut) .. 0 (centre) .. 1 (bas)

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        _updateAlignment();
        return false; // Laisse remonter la notification aux ancêtres
      },
      child: ClipRRect(
        key: _key,
        borderRadius: widget.borderRadius,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            // L'image est plus haute que son conteneur pour pouvoir glisser.
            height: widget.height * (1 + widget.factor * 2),
            width: widget.width,
            fit: BoxFit.cover,
            alignment: Alignment(0, _alignment),
            placeholder: (_, __) => Container(
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            errorWidget: (_, __, ___) => Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.landscape,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateAlignment() {
    final ro = _key.currentContext?.findRenderObject();
    if (ro == null || !ro.attached) return;
    if (ro is! RenderBox) return;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final offset = ro.localToGlobal(Offset.zero);
    // Centre du widget par rapport au centre de l'écran.
    final center = offset.dy + widget.height / 2;
    // Normalise entre -1 et +1 selon la position verticale.
    final ratio = ((center - screenHeight / 2) / (screenHeight / 2)).clamp(-1.0, 1.0);
    final newAlignment = ratio * widget.factor * 2;

    if ((newAlignment - _alignment).abs() > 0.005) {
      setState(() => _alignment = newAlignment);
    }
  }
}
