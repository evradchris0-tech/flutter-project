import 'package:flutter/material.dart';

/// Bouton de connexion sociale (Google, Apple, Facebook…).
/// Affiche une icône SVG à gauche et un label centré.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.iconPath,
    required this.onTap,
  });

  final String    label;
  final String    iconPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Placeholder icône (remplacer par flutter_svg quand ajouté)
          Container(
            width:  24,
            height: 24,
            decoration: BoxDecoration(
              color:        colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.g_mobiledata_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color:       colorScheme.onSurface,
              fontSize:    15,
              fontWeight:  FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
