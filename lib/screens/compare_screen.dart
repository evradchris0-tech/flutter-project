// NOTE : Écran de comparaison de deux destinations côte à côte.
// Concepts mis en avant :
//   • StatefulWidget local : pas besoin de Riverpod pour l'état de sélection.
//   • AnimatedSwitcher : transition fluide quand l'utilisateur change une destination.
//   • TweenAnimationBuilder : les barres de comparaison s'animent en glissant.
//   • Row + Expanded : mise en page 50/50 responsive.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../enums/destination_category.dart';
import '../models/destination.dart';

class CompareScreen extends StatefulWidget {
  final List<Destination> destinations;
  // Si on arrive depuis un détail, une destination est pré-sélectionnée.
  final Destination? preselected;

  const CompareScreen({
    super.key,
    required this.destinations,
    this.preselected,
  });

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Destination? _left;
  Destination? _right;

  @override
  void initState() {
    super.initState();
    _left = widget.preselected ?? (widget.destinations.isNotEmpty ? widget.destinations.first : null);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparer'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Sélecteurs ────────────────────────────────────────────────────
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: _DestinationPicker(
                    label: 'Destination 1',
                    selected: _left,
                    all: widget.destinations,
                    onPicked: (d) => setState(() => _left = d),
                    exclude: _right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.compare_arrows,
                      color: colorScheme.primary, size: 28),
                ),
                Expanded(
                  child: _DestinationPicker(
                    label: 'Destination 2',
                    selected: _right,
                    all: widget.destinations,
                    onPicked: (d) => setState(() => _right = d),
                    exclude: _left,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Comparaison ───────────────────────────────────────────────────
          Expanded(
            child: _left == null || _right == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.compare,
                            size: 56, color: colorScheme.primaryContainer),
                        const SizedBox(height: 12),
                        Text(
                          'Choisissez deux destinations\npour les comparer',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                              fontSize: 15,
                              color: colorScheme.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _ComparisonTable(
                        key: ValueKey('${_left!.id}-${_right!.id}'),
                        left: _left!,
                        right: _right!,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Dropdown de sélection ────────────────────────────────────────────────────
class _DestinationPicker extends StatelessWidget {
  final String label;
  final Destination? selected;
  final List<Destination> all;
  final void Function(Destination) onPicked;
  final Destination? exclude;

  const _DestinationPicker({
    required this.label,
    required this.selected,
    required this.all,
    required this.onPicked,
    this.exclude,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final available = all.where((d) => d.id != exclude?.id).toList();

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await showDialog<Destination>(
          context: context,
          builder: (_) => _PickerDialog(destinations: available),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: selected!.imageUrl,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                      width: 36,
                      height: 36,
                      color: colorScheme.primaryContainer),
                  errorWidget: (_, __, ___) => Container(
                    width: 36,
                    height: 36,
                    color: colorScheme.primaryContainer,
                    child: Icon(Icons.landscape,
                        size: 18, color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selected!.name,
                  style: GoogleFonts.lato(
                      fontSize: 12, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else ...[
              Icon(Icons.add_circle_outline,
                  size: 20, color: colorScheme.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.lato(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Dialog de sélection ─────────────────────────────────────────────────────
class _PickerDialog extends StatelessWidget {
  final List<Destination> destinations;
  const _PickerDialog({required this.destinations});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choisir une destination'),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: destinations.length,
          itemBuilder: (_, i) {
            final d = destinations[i];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: d.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 40,
                    height: 40,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
              ),
              title: Text(d.name,
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600)),
              subtitle: Text(d.region, style: GoogleFonts.lato(fontSize: 12)),
              onTap: () => Navigator.pop(context, d),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}

// ─── Tableau comparatif ───────────────────────────────────────────────────────
class _ComparisonTable extends StatelessWidget {
  final Destination left;
  final Destination right;

  const _ComparisonTable({super.key, required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Images côte à côte
        Row(
          children: [
            Expanded(child: _DestImage(dest: left)),
            const SizedBox(width: 8),
            Expanded(child: _DestImage(dest: right)),
          ],
        ),
        const SizedBox(height: 16),

        // Critères de comparaison
        _CompareRow(
          label: 'Nom',
          leftText: left.name,
          rightText: right.name,
        ),
        _CompareRow(
          label: 'Région',
          leftText: left.region,
          rightText: right.region,
        ),
        _CompareRow(
          label: 'Catégorie',
          leftText: left.category.label,
          rightText: right.category.label,
        ),
        if (left.altitude != null || right.altitude != null)
          _CompareRow(
            label: 'Altitude',
            leftText: left.altitude != null
                ? '${left.altitude!.toInt()} m'
                : '—',
            rightText: right.altitude != null
                ? '${right.altitude!.toInt()} m'
                : '—',
          ),
        _CompareRow(
          label: 'Activités',
          leftText: '${left.activities.length}',
          rightText: '${right.activities.length}',
          isNumeric: true,
          leftValue: left.activities.length.toDouble(),
          rightValue: right.activities.length.toDouble(),
        ),

        // Activités en commun
        const SizedBox(height: 16),
        _CommonActivities(left: left, right: right),
      ],
    );
  }
}

class _DestImage extends StatelessWidget {
  final Destination dest;
  const _DestImage({required this.dest});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: CachedNetworkImage(
            imageUrl: dest.imageUrl,
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              height: 120,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            errorWidget: (_, __, ___) => Container(
              height: 120,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(Icons.landscape,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          dest.name,
          style: GoogleFonts.playfairDisplay(
              fontSize: 14, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String leftText;
  final String rightText;
  final bool isNumeric;
  final double? leftValue;
  final double? rightValue;

  const _CompareRow({
    required this.label,
    required this.leftText,
    required this.rightText,
    this.isNumeric = false,
    this.leftValue,
    this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final lWins = isNumeric && leftValue != null && rightValue != null && leftValue! > rightValue!;
    final rWins = isNumeric && leftValue != null && rightValue != null && rightValue! > leftValue!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              leftText,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: lWins ? FontWeight.w700 : FontWeight.w400,
                color: lWins ? colorScheme.primary : colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.lato(
                  fontSize: 11,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              rightText,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: rWins ? FontWeight.w700 : FontWeight.w400,
                color: rWins ? colorScheme.primary : colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommonActivities extends StatelessWidget {
  final Destination left;
  final Destination right;

  const _CommonActivities({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final leftSet = Set<String>.from(left.activities);
    final rightSet = Set<String>.from(right.activities);
    final common = leftSet.intersection(rightSet).toList();

    if (common.isEmpty) {
      return Text(
        'Aucune activité en commun',
        style: GoogleFonts.lato(
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.4)),
        textAlign: TextAlign.center,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${common.length} activité${common.length > 1 ? 's' : ''} en commun',
          style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: common.map((a) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(a,
                style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary)),
          )).toList(),
        ),
      ],
    );
  }
}
