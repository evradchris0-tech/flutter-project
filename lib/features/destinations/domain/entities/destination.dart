import 'package:equatable/equatable.dart';
import '../../../../enums/destination_category.dart';

/// Entité du domaine : représente une destination touristique camerounaise.
///
/// Règles Clean Architecture :
///   - Aucune dépendance vers les couches data ou présentation.
///   - Immuable : tous les champs sont [final].
///   - [Equatable] : égalité structurelle → Riverpod détecte les vrais changements
///     et évite les rebuilds superflus.
///   - [copyWith] : crée une nouvelle instance modifiée sans mutation.
class Destination extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;
  final DestinationCategory category;
  final String region;
  final double? altitude;
  final List<String> activities;
  final double latitude;
  final double longitude;
  final String titreAccroche;
  final String duree;
  final int prixAppel;

  const Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
    required this.category,
    required this.region,
    this.altitude,
    required this.activities,
    required this.latitude,
    required this.longitude,
    required this.titreAccroche,
    required this.duree,
    required this.prixAppel,
  });

  // ── Equatable ─────────────────────────────────────────────────────────────

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        imageUrls,
        category,
        region,
        altitude,
        activities,
        latitude,
        longitude,
        titreAccroche,
        duree,
        prixAppel,
      ];

  // ── copyWith ──────────────────────────────────────────────────────────────

  Destination copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    DestinationCategory? category,
    String? region,
    double? altitude,
    List<String>? activities,
    double? latitude,
    double? longitude,
    String? titreAccroche,
    String? duree,
    int? prixAppel,
  }) {
    return Destination(
      id:          id          ?? this.id,
      name:        name        ?? this.name,
      description: description ?? this.description,
      imageUrl:    imageUrl    ?? this.imageUrl,
      imageUrls:   imageUrls   ?? this.imageUrls,
      category:    category    ?? this.category,
      region:      region      ?? this.region,
      altitude:    altitude    ?? this.altitude,
      activities:  activities  ?? this.activities,
      latitude:    latitude    ?? this.latitude,
      longitude:   longitude   ?? this.longitude,
      titreAccroche: titreAccroche ?? this.titreAccroche,
      duree:       duree       ?? this.duree,
      prixAppel:   prixAppel   ?? this.prixAppel,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String get shortSummary => '${category.label} — $region';

  bool get hasAltitude => altitude != null;

  String get formattedAltitude =>
      altitude != null ? '${altitude!.toStringAsFixed(0)} m' : '';

  @override
  String toString() => 'Destination(id: $id, name: $name, region: $region)';
}
