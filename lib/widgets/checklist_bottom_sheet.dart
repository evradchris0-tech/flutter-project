// NOTE : Bottom sheet interactif de checklist de voyage.
// Concepts mis en avant :
//   • showModalBottomSheet avec DraggableScrollableSheet : s'étend et se referme.
//   • ConsumerStatefulWidget : accès au checklistProvider + TextField.
//   • AnimatedList n'est pas requis : ListView.builder avec les items du provider.
//   • AnimatedContainer : fond vert sur les items cochés.
//   • Dismissible dans le sheet pour supprimer un item.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/checklist_provider.dart';

/// Affiche le bottom sheet de checklist pour une destination.
Future<void> showChecklistSheet(
    BuildContext context, String destId, String destName) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChecklistBottomSheet(
      destId: destId,
      destName: destName,
    ),
  );
}

class ChecklistBottomSheet extends ConsumerStatefulWidget {
  final String destId;
  final String destName;

  const ChecklistBottomSheet(
      {super.key, required this.destId, required this.destName});

  @override
  ConsumerState<ChecklistBottomSheet> createState() =>
      _ChecklistBottomSheetState();
}

class _ChecklistBottomSheetState extends ConsumerState<ChecklistBottomSheet> {
  final _addCtrl = TextEditingController();
  bool _showAdd = false;

  @override
  void initState() {
    super.initState();
    // Initialise la checklist si elle n'existe pas encore pour cette destination.
    Future.microtask(() =>
        ref.read(checklistProvider.notifier).initForDestination(widget.destId));
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = ref.watch(checklistProvider)[widget.destId] ?? [];
    final checkedCount = items.where((i) => i.checked).length;
    final ratio = items.isEmpty ? 0.0 : checkedCount / items.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 20,
                  offset: Offset(0, -4)),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // En-tête
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.luggage_outlined,
                        size: 22, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checklist — ${widget.destName}',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            '$checkedCount / ${items.length} prêts',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Réinitialiser les coches
                    if (checkedCount > 0)
                      TextButton(
                        onPressed: () => ref
                            .read(checklistProvider.notifier)
                            .resetChecks(widget.destId),
                        child: Text(
                          'Reset',
                          style: GoogleFonts.lato(
                              fontSize: 12, color: colorScheme.primary),
                        ),
                      ),
                  ],
                ),
              ),

              // Barre de progression
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: ratio),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) {
                    return Stack(children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: v.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ]);
                  },
                ),
              ),

              const Divider(height: 1),

              // Liste des items
              Expanded(
                child: ListView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length + (_showAdd ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_showAdd && index == items.length) {
                      return _AddItemField(
                        controller: _addCtrl,
                        onAdd: (label) {
                          if (label.trim().isNotEmpty) {
                            ref
                                .read(checklistProvider.notifier)
                                .addItem(widget.destId, label.trim());
                          }
                          _addCtrl.clear();
                          setState(() => _showAdd = false);
                        },
                        onCancel: () {
                          _addCtrl.clear();
                          setState(() => _showAdd = false);
                        },
                      );
                    }
                    final item = items[index];
                    return Dismissible(
                      key: ValueKey(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red.shade50,
                        child: Icon(Icons.delete_outline,
                            color: Colors.red.shade400),
                      ),
                      onDismissed: (_) => ref
                          .read(checklistProvider.notifier)
                          .removeItem(widget.destId, item.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        color: item.checked
                            ? colorScheme.primary.withValues(alpha: 0.06)
                            : Colors.transparent,
                        child: CheckboxListTile(
                          value: item.checked,
                          onChanged: (_) => ref
                              .read(checklistProvider.notifier)
                              .toggle(widget.destId, item.id),
                          title: Text(
                            item.label,
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              decoration: item.checked
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: item.checked
                                  ? colorScheme.onSurface.withValues(alpha: 0.4)
                                  : colorScheme.onSurface,
                            ),
                          ),
                          activeColor: colorScheme.primary,
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bouton ajouter un item
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() => _showAdd = true),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Ajouter un article'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Champ de saisie inline pour l'ajout d'un item ───────────────────────────
class _AddItemField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onAdd;
  final VoidCallback onCancel;

  const _AddItemField({
    required this.controller,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              style: GoogleFonts.lato(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Nouvel article...',
                hintStyle: GoogleFonts.lato(fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onSubmitted: onAdd,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.check),
            color: Theme.of(context).colorScheme.primary,
            onPressed: () => onAdd(controller.text),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            color: Colors.grey,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}
