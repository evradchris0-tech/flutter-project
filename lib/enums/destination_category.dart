// NOTE : Ce fichier liste les catégories possibles d'une destination sous forme d'enum.
// Concept mis en avant : enum typé + extension pour ajouter une méthode sans modifier le type d'origine.
import 'package:flutter/material.dart';

enum DestinationCategory {
  plage,
  montagne,
  ville,
  foret,
  parc,
}

// L'extension permet d'ajouter des propriétés à un enum existant.
extension DestinationCategoryLabel on DestinationCategory {
  String get label {
    // Le switch sur un enum est exhaustif : Dart signale si j'oublie un cas.
    switch (this) {
      case DestinationCategory.plage:
        return 'Plage';
      case DestinationCategory.montagne:
        return 'Montagne';
      case DestinationCategory.ville:
        return 'Ville';
      case DestinationCategory.foret:
        return 'Forêt';
      case DestinationCategory.parc:
        return 'Parc naturel';
    }
  }

  IconData get icon {
    switch (this) {
      case DestinationCategory.plage:
        return Icons.beach_access_rounded;
      case DestinationCategory.montagne:
        return Icons.landscape_rounded;
      case DestinationCategory.ville:
        return Icons.location_city_rounded;
      case DestinationCategory.foret:
        return Icons.park_rounded;
      case DestinationCategory.parc:
        return Icons.eco_rounded;
    }
  }
}
