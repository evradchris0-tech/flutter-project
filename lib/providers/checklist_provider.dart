// NOTE : Provider de checklist de voyage — liste d'articles à emporter par destination.
// Concepts mis en avant :
//   • StateNotifier<Map<String, List<ChecklistItem>>> : clé = destinationId.
//   • SharedPreferences JSON : persistance légère sans base de données.
//   • copyWith pattern : chaque mutation crée un nouveau Map (immutabilité Riverpod).

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChecklistItem {
  final String id;
  final String label;
  final bool checked;

  const ChecklistItem({
    required this.id,
    required this.label,
    this.checked = false,
  });

  ChecklistItem copyWith({bool? checked}) =>
      ChecklistItem(id: id, label: label, checked: checked ?? this.checked);

  Map<String, dynamic> toJson() => {'id': id, 'label': label, 'checked': checked};

  factory ChecklistItem.fromJson(Map<String, dynamic> j) => ChecklistItem(
        id: j['id'] as String,
        label: j['label'] as String,
        checked: j['checked'] as bool,
      );
}

// Articles prédéfinis pour chaque voyage (point de départ)
const List<String> _defaultItems = [
  'Passeport / CNI',
  'Argent liquide',
  'Crème solaire',
  'Appareil photo',
  'Bouteille d\'eau',
  'Chaussures de marche',
  'Vêtements légers',
  'Trousse de premiers secours',
  'Chargeur téléphone',
  'Plan de la ville',
];

class ChecklistNotifier
    extends StateNotifier<Map<String, List<ChecklistItem>>> {
  static const _kPrefix = 'checklist_';

  ChecklistNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_kPrefix));
    final map = <String, List<ChecklistItem>>{};
    for (final key in keys) {
      final destId = key.substring(_kPrefix.length);
      final raw = prefs.getString(key);
      if (raw != null) {
        final list = (jsonDecode(raw) as List)
            .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
            .toList();
        map[destId] = list;
      }
    }
    if (mounted) state = map;
  }

  Future<void> _save(String destId) async {
    final prefs = await SharedPreferences.getInstance();
    final items = state[destId] ?? [];
    await prefs.setString(
      '$_kPrefix$destId',
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  /// Initialise la checklist d'une destination si elle n'existe pas encore.
  Future<void> initForDestination(String destId) async {
    if (state.containsKey(destId)) return;
    final items = _defaultItems
        .asMap()
        .entries
        .map((e) => ChecklistItem(
              id: '${destId}_${e.key}',
              label: e.value,
            ))
        .toList();
    state = {...state, destId: items};
    await _save(destId);
  }

  /// Coche / décoche un item.
  Future<void> toggle(String destId, String itemId) async {
    final items = List<ChecklistItem>.from(state[destId] ?? []);
    final idx = items.indexWhere((i) => i.id == itemId);
    if (idx < 0) return;
    items[idx] = items[idx].copyWith(checked: !items[idx].checked);
    state = {...state, destId: items};
    await _save(destId);
  }

  /// Ajoute un item personnalisé.
  Future<void> addItem(String destId, String label) async {
    final items = List<ChecklistItem>.from(state[destId] ?? []);
    items.add(ChecklistItem(
      id: '${destId}_custom_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
    ));
    state = {...state, destId: items};
    await _save(destId);
  }

  /// Supprime un item.
  Future<void> removeItem(String destId, String itemId) async {
    final items = (state[destId] ?? [])
        .where((i) => i.id != itemId)
        .toList();
    state = {...state, destId: items};
    await _save(destId);
  }

  /// Remet tous les items à non-cochés.
  Future<void> resetChecks(String destId) async {
    final items = (state[destId] ?? [])
        .map((i) => i.copyWith(checked: false))
        .toList();
    state = {...state, destId: items};
    await _save(destId);
  }
}

final checklistProvider =
    StateNotifierProvider<ChecklistNotifier, Map<String, List<ChecklistItem>>>(
  (ref) => ChecklistNotifier(),
);
