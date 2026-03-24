// NOTE : Provider Riverpod qui expose l'état de la connectivité réseau en temps réel.
// Concept mis en avant : StreamProvider — écoute un flux continu d'événements
// (changements de réseau) et reconstruit automatiquement les widgets abonnés.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// true  = au moins une interface réseau active (WiFi, mobile…)
// false = aucune connexion (mode avion, hors couverture)
final connectivityProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
    // onConnectivityChanged émet une List<ConnectivityResult> — vrai si
    // au moins un résultat n'est pas "none".
    (results) => results.any((r) => r != ConnectivityResult.none),
  );
});
