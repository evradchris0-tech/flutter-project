// NOTE : Écran principal avec navigation par onglets — 4 onglets.
// UX : label affiché sous chaque icône en permanence, accent doré sur l'actif.
// AnimatedContainer pour la pill active, ScaleTransition sur l'icône sélectionnée.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import 'profile_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    FavoritesScreen(),
    MapScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─── Barre de navigation ──────────────────────────────────────────────────────
class _CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _CustomBottomNav(
      {required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItemData(
      icon:       Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label:      'Accueil',
    ),
    _NavItemData(
      icon:       Icons.bookmark_border_rounded,
      activeIcon: Icons.bookmark_rounded,
      label:      'Favoris',
    ),
    _NavItemData(
      icon:       Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label:      'Carte',
    ),
    _NavItemData(
      icon:       Icons.person_outline,
      activeIcon: Icons.person_rounded,
      label:      'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (i) => _NavItem(
                data:         _items[i],
                index:        i,
                currentIndex: currentIndex,
                onTap:        onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─── Élément individuel ───────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final _NavItemData data;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.data,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleCtrl;
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    // Micro-bounce à chaque activation
    if (widget.currentIndex == widget.index &&
        old.currentIndex != widget.index) {
      _scaleCtrl.forward(from: 0.85);
    }
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.currentIndex == widget.index;
    final colorScheme = Theme.of(context).colorScheme;

    // Couleurs
    final Color activeColor = AppColors.gold;
    final Color inactiveColor =
        _isHovered ? colorScheme.onSurface : colorScheme.onSurfaceVariant;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit:  (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Icône avec pill active ────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOutCubic,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.gold.withValues(alpha: 0.12)
                      : _isHovered
                          ? colorScheme.onSurface.withValues(alpha: 0.06)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: isSelected
                      ? Border.all(
                          color: AppColors.gold.withValues(alpha: 0.35),
                          width: 1,
                        )
                      : null,
                ),
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: child,
                    ),
                    child: Icon(
                      isSelected
                          ? widget.data.activeIcon
                          : widget.data.icon,
                      key: ValueKey(isSelected),
                      color: isSelected ? activeColor : inactiveColor,
                      size: 24,
                    ),
                  ),
                ),
              ),

              // ── Gapier entre icône et label ───────────────────────────────
              const SizedBox(height: 4),

              // ── Label toujours affiché ────────────────────────────────────
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.lato(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: isSelected ? 0.3 : 0,
                ),
                child: Text(widget.data.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
