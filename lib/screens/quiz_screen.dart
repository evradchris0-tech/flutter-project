// NOTE : Quiz "Devine la destination" — jeu ludique sur les destinations camerounaises.
// Concepts mis en avant :
//   • StatefulWidget pur (pas de Riverpod) : état local suffisant pour un mini-jeu.
//   • AnimatedSwitcher + SlideTransition : transition entre questions.
//   • TweenAnimationBuilder : barre de progression animée.
//   • AnimatedContainer : feedback couleur immédiat sur le bouton choisi.
//   • Résultat final avec score et encouragements — AnimationController scale.

import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/destination.dart';

// ─── Modèle d'une question quiz ───────────────────────────────────────────────
class _QuizQuestion {
  final Destination correct;
  final List<Destination> choices; // 4 choix dont le bon

  const _QuizQuestion({required this.correct, required this.choices});
}

// ─── Génération des questions à partir d'une liste ───────────────────────────
List<_QuizQuestion> _generateQuiz(List<Destination> dests) {
  if (dests.length < 4) return [];
  final rng = math.Random();
  final shuffled = List<Destination>.from(dests)..shuffle(rng);
  // On génère au plus min(dests.length, 6) questions.
  final count = math.min(shuffled.length, 6);
  return List.generate(count, (i) {
    final correct = shuffled[i];
    // 3 distracteurs différents de la bonne réponse
    final pool = shuffled.where((d) => d.id != correct.id).toList()..shuffle(rng);
    final choices = ([correct, ...pool.take(3)])..shuffle(rng);
    return _QuizQuestion(correct: correct, choices: choices);
  });
}

// ─── Écran principal ──────────────────────────────────────────────────────────
class QuizScreen extends StatefulWidget {
  final List<Destination> destinations;

  const QuizScreen({super.key, required this.destinations});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  late List<_QuizQuestion> _questions;
  int _current = 0;
  int _score   = 0;
  String? _selectedId;   // ID du choix tapé (null = pas encore répondu)
  bool   _answered = false;
  bool   _finished = false;

  // Pour l'animation de résultat final
  late final AnimationController _resultCtrl;

  @override
  void initState() {
    super.initState();
    _questions = _generateQuiz(widget.destinations);
    _resultCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _resultCtrl.dispose();
    super.dispose();
  }

  void _onAnswer(String id) {
    if (_answered) return;
    final isCorrect = id == _questions[_current].correct.id;
    setState(() {
      _selectedId = id;
      _answered   = true;
      if (isCorrect) _score++;
    });

    // Passe à la question suivante après 1,2 s
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_current + 1 >= _questions.length) {
        setState(() => _finished = true);
        _resultCtrl.forward(from: 0.0);
      } else {
        setState(() {
          _current++;
          _selectedId = null;
          _answered   = false;
        });
      }
    });
  }

  void _restart() {
    setState(() {
      _questions = _generateQuiz(widget.destinations);
      _current   = 0;
      _score     = 0;
      _selectedId = null;
      _answered   = false;
      _finished   = false;
    });
    _resultCtrl.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devine la Destination'),
        centerTitle: true,
      ),
      body: _questions.isEmpty
          ? Center(
              child: Text(
                'Pas assez de destinations pour le quiz.',
                style: GoogleFonts.lato(fontSize: 15),
              ),
            )
          : _finished
              ? _buildResult(context)
              : _buildQuestion(context),
    );
  }

  // ── Écran résultat ─────────────────────────────────────────────────────────
  Widget _buildResult(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percent = _score / _questions.length;
    final emoji = percent == 1.0
        ? '🏆'
        : percent >= 0.5
            ? '🌟'
            : '📚';
    final message = percent == 1.0
        ? 'Parfait ! Vous connaissez tout !'
        : percent >= 0.5
            ? 'Bravo ! Bon explorateur !'
            : 'Continuez à explorer le Cameroun !';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: _resultCtrl,
            curve: Curves.elasticOut,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(
                '$_score / ${_questions.length}',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 17,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.replay, size: 18),
                label: const Text('Rejouer'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour à la carte'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Écran question ─────────────────────────────────────────────────────────
  Widget _buildQuestion(BuildContext context) {
    final q = _questions[_current];
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (_current + 1) / _questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barre de progression animée
        TweenAnimationBuilder<double>(
          tween: Tween(begin: (_current) / _questions.length, end: progress),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (_, value, __) => LinearProgressIndicator(
            value: value,
            minHeight: 5,
            color: colorScheme.primary,
            backgroundColor: colorScheme.primaryContainer,
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_current + 1} / ${_questions.length}',
                style: GoogleFonts.lato(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5)),
              ),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFC8973A)),
                  const SizedBox(width: 4),
                  Text(
                    '$_score pt${_score > 1 ? 's' : ''}',
                    style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFC8973A)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Image de la destination — AnimatedSwitcher change à chaque question.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(
                  scale: Tween(begin: 0.92, end: 1.0).animate(anim),
                  child: child,
                ),
              ),
              child: CachedNetworkImage(
                key: ValueKey(q.correct.id),
                imageUrl: q.correct.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 200,
                  color: colorScheme.primaryContainer,
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 200,
                  color: colorScheme.primaryContainer,
                  child: Icon(Icons.landscape,
                      size: 60, color: colorScheme.primary),
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Quelle est cette destination ?',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Boutons réponse
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: q.choices.map((dest) {
              return _AnswerButton(
                label: dest.name,
                region: dest.region,
                isSelected: _selectedId == dest.id,
                isCorrect: dest.id == q.correct.id,
                answered: _answered,
                onTap: () => _onAnswer(dest.id),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Bouton de réponse animé ──────────────────────────────────────────────────
class _AnswerButton extends StatelessWidget {
  final String label;
  final String region;
  final bool isSelected;
  final bool isCorrect;
  final bool answered;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.label,
    required this.region,
    required this.isSelected,
    required this.isCorrect,
    required this.answered,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Couleur de fond selon l'état
    Color bgColor;
    Color borderColor;
    Color textColor = colorScheme.onSurface;

    if (!answered) {
      bgColor     = colorScheme.surface;
      borderColor = colorScheme.outline.withValues(alpha: 0.3);
    } else if (isCorrect) {
      bgColor     = const Color(0xFF4CAF50).withValues(alpha: 0.15);
      borderColor = const Color(0xFF4CAF50);
      textColor   = const Color(0xFF2E7D32);
    } else if (isSelected) {
      bgColor     = Colors.red.withValues(alpha: 0.12);
      borderColor = Colors.red.shade400;
      textColor   = Colors.red.shade700;
    } else {
      bgColor     = colorScheme.surface;
      borderColor = colorScheme.outline.withValues(alpha: 0.15);
      textColor   = colorScheme.onSurface.withValues(alpha: 0.4);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: answered ? null : onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Icône de statut si répondu
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: answered
                        ? Icon(
                            isCorrect
                                ? Icons.check_circle
                                : isSelected
                                    ? Icons.cancel
                                    : Icons.radio_button_unchecked,
                            key: ValueKey('$isCorrect-$isSelected'),
                            size: 20,
                            color: isCorrect
                                ? const Color(0xFF4CAF50)
                                : isSelected
                                    ? Colors.red.shade400
                                    : colorScheme.onSurface.withValues(alpha: 0.2),
                          )
                        : Icon(
                            Icons.radio_button_unchecked,
                            key: const ValueKey('unchecked'),
                            size: 20,
                            color: colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        if (answered && isCorrect)
                          Text(
                            region,
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: const Color(0xFF4CAF50),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
