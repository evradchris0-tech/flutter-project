// NOTE : Provider de tri dynamique des destinations.
// Concepts mis en avant :
//   • Enum SortOrder comme état simple du StateProvider.
//   • Provider dérivé sortedDestinationsProvider : compose filteredDestinationsProvider + tri.
//   • Tris disponibles : par nom A→Z, Z→A, par région, par vues décroissantes.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/destination.dart';
import '../providers/destinations_provider.dart';
import '../providers/view_counter_provider.dart';

enum SortOrder {
  nameAsc,   // A → Z
  nameDesc,  // Z → A
  region,    // Région A → Z
  mostViewed // Plus consultés en premier
}

extension SortOrderLabel on SortOrder {
  String get label {
    switch (this) {
      case SortOrder.nameAsc:   return 'Nom A→Z';
      case SortOrder.nameDesc:  return 'Nom Z→A';
      case SortOrder.region:    return 'Région';
      case SortOrder.mostViewed: return 'Plus vus';
    }
  }
}

final sortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.nameAsc);

/// Provider dérivé : filtre + tri combinés.
final sortedDestinationsProvider =
    Provider<AsyncValue<List<Destination>>>((ref) {
  final filteredAsync = ref.watch(filteredDestinationsProvider);
  final sortOrder     = ref.watch(sortOrderProvider);
  final viewCounts    = ref.watch(viewCounterProvider);

  return filteredAsync.whenData((filtered) {
    final list = List<Destination>.from(filtered);
    switch (sortOrder) {
      case SortOrder.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
      case SortOrder.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
      case SortOrder.region:
        list.sort((a, b) => a.region.compareTo(b.region));
      case SortOrder.mostViewed:
        list.sort((a, b) {
          final va = viewCounts[a.id] ?? 0;
          final vb = viewCounts[b.id] ?? 0;
          return vb.compareTo(va);
        });
    }
    return list;
  });
});
