// Carte interactive des destinations — tuiles claires par défaut, sombres si thème sombre.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../enums/destination_category.dart';
import '../models/destination.dart';
import '../navigation/app_page_route.dart';
import '../providers/destinations_provider.dart';
import '../providers/theme_provider.dart';
import 'detail_screen.dart';

// couleur et icône selon la catégorie
extension _CategoryStyle on DestinationCategory {
  Color get markerColor {
    switch (this) {
      case DestinationCategory.plage:    return const Color(0xFF29B6F6);
      case DestinationCategory.montagne: return const Color(0xFF78909C);
      case DestinationCategory.ville:    return const Color(0xFFAB47BC);
      case DestinationCategory.foret:    return const Color(0xFF4CAF50);
      case DestinationCategory.parc:     return const Color(0xFFFF7043);
    }
  }

  IconData get markerIcon {
    switch (this) {
      case DestinationCategory.plage:    return Icons.beach_access;
      case DestinationCategory.montagne: return Icons.terrain;
      case DestinationCategory.ville:    return Icons.location_city;
      case DestinationCategory.foret:    return Icons.forest;
      case DestinationCategory.parc:     return Icons.park;
    }
  }

  String get shortLabel {
    switch (this) {
      case DestinationCategory.plage:    return 'Plages';
      case DestinationCategory.montagne: return 'Montagnes';
      case DestinationCategory.ville:    return 'Villes';
      case DestinationCategory.foret:    return 'Forêts';
      case DestinationCategory.parc:     return 'Parcs';
    }
  }
}

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  DestinationCategory? _filterCat;
  final _mapController = MapController();
  bool _locating = false;
  LatLng? _userPosition; // position GPS réelle de l'utilisateur

  // demande la permission et déplace la carte sur la position réelle
  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission de localisation refusée.')),
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final latLng = LatLng(pos.latitude, pos.longitude);
      // met à jour le point et déplace la carte
      setState(() => _userPosition = latLng);
      _mapController.move(latLng, 13.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'obtenir la position : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final destinationsAsync = ref.watch(destinationsProvider);
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    // tuiles claires en mode normal, CartoDB dark en mode sombre
    final tileUrl = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

    final bgColor = isDark ? const Color(0xFF1A1F2E) : Colors.white;
    final chipBg  = isDark ? const Color(0xFF2A2F42) : Colors.white;
    final chipText = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: bgColor,
      body: destinationsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: isDark ? Colors.white : const Color(0xFF1A3C34)),
        ),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (destinations) {
          final filtered = _filterCat == null
              ? destinations
              : destinations.where((d) => d.category == _filterCat).toList();

          return Stack(
            children: [
              // carte principale
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(4.5, 11.5),
                  initialZoom: 5.5,
                ),
                children: [
                  TileLayer(
                    urlTemplate: tileUrl,
                    subdomains: isDark ? const ['a', 'b', 'c', 'd'] : const [],
                    userAgentPackageName: 'com.example.discover_cameroon',
                    retinaMode: isDark,
                  ),
                  MarkerLayer(
                    markers: filtered.asMap().entries.map((entry) {
                      final dest = entry.value;
                      return Marker(
                        point: LatLng(dest.latitude, dest.longitude),
                        width: 130,
                        height: 72,
                        child: _BubbleMarker(
                          destination: dest,
                          delay: Duration(milliseconds: entry.key * 80),
                          onTap: () => _showDestinationSheet(context, dest, isDark),
                        ),
                      );
                    }).toList(),
                  ),
                  // cercle de précision + point bleu pour la position de l'utilisateur
                  if (_userPosition != null) ..._buildLocationLayers(_userPosition!),
                ],
              ),

              // barre de recherche en haut
              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 12,
                right: 12,
                child: _SearchBar(
                  isDark: isDark,
                  chipBg: chipBg,
                  onSearch: () => context.push('/search'),
                ),
              ),

              // filtres horizontaux juste en dessous
              Positioned(
                top: MediaQuery.of(context).padding.top + 72,
                left: 0,
                right: 0,
                child: _HorizontalFilters(
                  selected: _filterCat,
                  destinations: destinations,
                  isDark: isDark,
                  chipBg: chipBg,
                  chipText: chipText,
                  onSelected: (cat) => setState(() => _filterCat = cat),
                ),
              ),

              // bouton layers
              Positioned(
                top: MediaQuery.of(context).padding.top + 168,
                right: 12,
                child: _MapActionButton(
                  icon: Icons.layers_rounded,
                  isDark: isDark,
                  onTap: () => _mapController.move(const LatLng(4.5, 11.5), 5.5),
                ),
              ),

              // bouton ma position (GPS réel)
              Positioned(
                top: MediaQuery.of(context).padding.top + 220,
                right: 12,
                child: _locating
                    ? Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2F42) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _MapActionButton(
                        icon: Icons.my_location,
                        isDark: isDark,
                        onTap: _goToMyLocation,
                      ),
              ),

              // compteur destinations filtré
              Positioned(
                bottom: 16 + MediaQuery.of(context).padding.bottom,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2F42) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  ),
                  child: Text(
                    '${filtered.length} destination${filtered.length > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1A3C34),
                    ),
                  ),
                ),
              ),

              // FAB navigation
              Positioned(
                bottom: 16 + MediaQuery.of(context).padding.bottom,
                right: 16,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3C34),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDestinationSheet(BuildContext context, Destination dest, bool isDark) {
    final sheetBg = isDark ? const Color(0xFF1E2235) : Colors.white;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, 24 + MediaQuery.of(context).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: dest.category.markerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(dest.category.markerIcon,
                      color: dest.category.markerColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dest.name,
                          style: GoogleFonts.montserrat(
                              fontSize: 18, fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 12, color: dest.category.markerColor),
                          const SizedBox(width: 3),
                          Text(dest.region,
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isDark ? Colors.white54 : Colors.grey[600])),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                            decoration: BoxDecoration(
                              color: dest.category.markerColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(dest.category.label,
                                style: GoogleFonts.inter(
                                    fontSize: 10, fontWeight: FontWeight.w700,
                                    color: dest.category.markerColor)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(dest.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    height: 1.5)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      SlideUpRoute(page: DetailScreen(destination: dest)));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3C34),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: Text('Voir la destination',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // cercle de précision bleu clair + point bleu centré sur la position GPS
  List<Widget> _buildLocationLayers(LatLng position) {
    return [
      CircleLayer(
        circles: [
          // halo de précision (bleu transparent)
          CircleMarker(
            point: position,
            radius: 60,
            color: const Color(0x301A7EFF),
            borderColor: const Color(0x661A7EFF),
            borderStrokeWidth: 1.5,
            useRadiusInMeter: true,
          ),
        ],
      ),
      MarkerLayer(
        markers: [
          Marker(
            point: position,
            width: 20,
            height: 20,
            child: _LocationDot(),
          ),
        ],
      ),
    ];
  }
}

// point bleu animé (pulse) pour la position de l'utilisateur
class _LocationDot extends StatefulWidget {
  const _LocationDot();

  @override
  State<_LocationDot> createState() => _LocationDotState();
}

class _LocationDotState extends State<_LocationDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulse,
      child: Container(
        width: 16, height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF1A7EFF),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: const [
            BoxShadow(color: Color(0x881A7EFF), blurRadius: 8, spreadRadius: 2),
          ],
        ),
      ),
    );
  }
}

// barre de recherche sans bouton micro
class _SearchBar extends StatelessWidget {
  final bool isDark;
  final Color chipBg;
  final VoidCallback onSearch;
  const _SearchBar({required this.isDark, required this.chipBg, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSearch,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 3)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.search,
                color: isDark ? const Color(0xFF29B6F6) : const Color(0xFF1A3C34), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rechercher une destination…',
                style: GoogleFonts.inter(
                  color: isDark ? Colors.white54 : Colors.black38, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// filtres horizontaux scrollables
class _HorizontalFilters extends StatelessWidget {
  final DestinationCategory? selected;
  final List<Destination> destinations;
  final bool isDark;
  final Color chipBg;
  final Color chipText;
  final void Function(DestinationCategory?) onSelected;

  const _HorizontalFilters({
    required this.selected,
    required this.destinations,
    required this.isDark,
    required this.chipBg,
    required this.chipText,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _chip('Tout', Icons.explore, const Color(0xFF1A3C34), selected == null,
              () => onSelected(null)),
          ...DestinationCategory.values.map((cat) {
            final count = destinations.where((d) => d.category == cat).length;
            return _chip('${cat.shortLabel} ($count)', cat.markerIcon, cat.markerColor,
                selected == cat, () => onSelected(selected == cat ? null : cat));
          }),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color color, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : chipBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? Colors.white : color),
            const SizedBox(width: 5),
            Text(label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : chipText,
                )),
          ],
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  const _MapActionButton({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2F42) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Icon(icon, color: isDark ? Colors.white : Colors.black87, size: 20),
      ),
    );
  }
}

// marqueur bulle avec icône + nom de la destination
class _BubbleMarker extends StatefulWidget {
  final Destination destination;
  final Duration delay;
  final VoidCallback onTap;

  const _BubbleMarker({
    required this.destination,
    required this.delay,
    required this.onTap,
  });

  @override
  State<_BubbleMarker> createState() => _BubbleMarkerState();
}

class _BubbleMarkerState extends State<_BubbleMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    // délai en cascade pour l'effet pop
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.destination.category.markerColor;
    final icon  = widget.destination.category.markerIcon;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // bulle avec icône + nom
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 12, color: Colors.white),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      widget.destination.name,
                      style: GoogleFonts.lato(
                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // tige + point
            Container(width: 2, height: 6, color: color),
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
