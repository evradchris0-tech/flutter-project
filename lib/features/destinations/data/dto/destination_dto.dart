import '../../../../enums/destination_category.dart';
import '../../domain/entities/destination.dart';

/// DTO (Data Transfer Object) : représentation JSON d'une destination.
///
/// Responsabilités :
///   1. Désérialiser le JSON de l'API NestJS → [DestinationDto] ([fromJson]).
///   2. Sérialiser vers JSON pour le cache → [toJson].
///   3. Convertir vers l'entité du domaine → [toEntity].
///
/// La séparation DTO ↔ Entity garantit que l'entité du domaine ne connaît
/// pas le format de l'API (principe d'isolation des couches).
class DestinationDto {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;
  final String category;
  final String region;
  final double? altitude;
  final List<String> activities;
  final double latitude;
  final double longitude;
  final String titreAccroche;
  final String duree;
  final int prixAppel;

  const DestinationDto({
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

  // ── Désérialisation (API → DTO) ───────────────────────────────────────────

  factory DestinationDto.fromJson(Map<String, dynamic> json) {
    return DestinationDto(
      id:          json['id']          as String,
      name:        json['name']        as String,
      description: json['description'] as String,
      imageUrl:    json['imageUrl']    as String,
      imageUrls:   (json['imageUrls'] as List<dynamic>).cast<String>(),
      category:    json['category']   as String,
      region:      json['region']     as String,
      altitude:    (json['altitude']  as num?)?.toDouble(),
      activities:  (json['activities'] as List<dynamic>).cast<String>(),
      latitude:    (json['latitude']  as num).toDouble(),
      longitude:   (json['longitude'] as num).toDouble(),
      titreAccroche: json['titre_accroche'] as String? ?? 'Découvrez les merveilles authentiques',
      duree:       json['duree'] as String? ?? '3 jours / 2 nuits',
      prixAppel:   (json['prix_appel'] as num?)?.toInt() ?? 45000,
    );
  }

  // ── Sérialisation (DTO → cache JSON) ─────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id':          id,
        'name':        name,
        'description': description,
        'imageUrl':    imageUrl,
        'imageUrls':   imageUrls,
        'category':    category,
        'region':      region,
        'altitude':    altitude,
        'activities':  activities,
        'latitude':    latitude,
        'longitude':   longitude,
        'titre_accroche': titreAccroche,
        'duree':       duree,
        'prix_appel':  prixAppel,
      };

  // ── Conversion vers entité domaine (DTO → Entity) ─────────────────────────

  Destination toEntity() => Destination(
        id:          id,
        name:        name,
        description: description,
        imageUrl:    imageUrl,
        imageUrls:   imageUrls,
        category:    _categoryFromString(category),
        region:      region,
        altitude:    altitude,
        activities:  activities,
        latitude:    latitude,
        longitude:   longitude,
        titreAccroche: titreAccroche,
        duree:       duree,
        prixAppel:   prixAppel,
      );

  static DestinationCategory _categoryFromString(String value) {
    return switch (value) {
      'plage'    => DestinationCategory.plage,
      'montagne' => DestinationCategory.montagne,
      'ville'    => DestinationCategory.ville,
      'foret'    => DestinationCategory.foret,
      'parc'     => DestinationCategory.parc,
      _          => DestinationCategory.ville,
    };
  }
}
