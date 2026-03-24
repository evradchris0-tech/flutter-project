/// Point d'entrée rétrocompatible pour le modèle Destination.
///
/// Les screens existants importent `package:discover_cameroon/models/destination.dart`.
/// Désormais, ce fichier ré-exporte l'entité Clean Architecture qui contient
/// tous les champs (+ Equatable + copyWith + computed properties).
export '../features/destinations/domain/entities/destination.dart';
