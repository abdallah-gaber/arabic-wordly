import 'package:arabic_wordly/features/game/application/game_controller.dart';
import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/guess_evaluator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  late final TextEditingController _guessController;

  @override
  void initState() {
    super.initState();
    _guessController = TextEditingController();
  }

  @override
  void dispose() {
    _guessController.dispose();
    super.dispose();
  }

  Future<void> _submitGuess() async {
    final accepted = await ref
        .read(gameControllerProvider.notifier)
        .submitGuess(_guessController.text);

    if (!mounted) {
      return;
    }

    FocusScope.of(context).unfocus();
    if (accepted) {
      _guessController.clear();
    }
  }

  Future<void> _skipPuzzle() async {
    FocusScope.of(context).unfocus();
    _guessController.clear();
    await ref.read(gameControllerProvider.notifier).skipPuzzle();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: gameState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'حدث خطأ أثناء تحميل اللعبة.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          data: (viewState) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(session: viewState.session),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _GuessGrid(session: viewState.session),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _guessController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              maxLength: ArabicWordRules.wordLength,
                              maxLengthEnforcement:
                                  MaxLengthEnforcement.enforced,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[\u0600-\u06FF\s]+'),
                                ),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'التخمين الحالي',
                                hintText: 'اكتب كلمة من 5 أحرف',
                                counterText: '',
                              ),
                              onSubmitted: (_) => _submitGuess(),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _submitGuess,
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('تحقق'),
                                ),
                                TextButton.icon(
                                  onPressed: _skipPuzzle,
                                  icon: const Icon(Icons.autorenew_rounded),
                                  label: const Text('لغز جديد'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FeedbackBanner(
                      feedback:
                          viewState.feedback ??
                          'استمر حتى تصل إلى الإجابة الصحيحة.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Arabic Wordly',
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'لعبة كلمات عربية بسيطة تبدأ مباشرة من اللغز الحالي.',
          textAlign: TextAlign.center,
          style: textTheme.bodyLarge?.copyWith(color: const Color(0xFF5D635F)),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            _StatCard(label: 'الجولة', value: session.round.toString()),
            _StatCard(
              label: 'المحاولات المتبقية',
              value: session.attemptsRemaining.toString(),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 170,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5D635F)),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.feedback});

  final String feedback;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3F0),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCAE0D7)),
      ),
      child: Text(
        feedback,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _GuessGrid extends StatelessWidget {
  const _GuessGrid({required this.session});

  final GameSession session;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var index = 0; index < session.maxAttempts; index++) {
      rows.add(
        Padding(
          padding: EdgeInsets.only(
            bottom: index == session.maxAttempts - 1 ? 0 : 10,
          ),
          child: _GuessRow(
            letters: index < session.guesses.length
                ? GuessEvaluator.evaluate(
                    guess: session.guesses[index],
                    answer: session.answer,
                  ).letters
                : null,
          ),
        ),
      );
    }

    return Column(children: rows);
  }
}

class _GuessRow extends StatelessWidget {
  const _GuessRow({this.letters});

  final List<LetterEvaluation>? letters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List<Widget>.generate(
        ArabicWordRules.wordLength,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == ArabicWordRules.wordLength - 1 ? 0 : 8,
            ),
            child: _GuessTile(
              letter: letters == null ? '' : letters![index].letter,
              match: letters == null ? null : letters![index].match,
            ),
          ),
        ),
        growable: false,
      ),
    );
  }
}

class _GuessTile extends StatelessWidget {
  const _GuessTile({required this.letter, required this.match});

  final String letter;
  final LetterMatch? match;

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, borderColor, textColor) = switch (match) {
      LetterMatch.correct => (
        const Color(0xFF157A6E),
        const Color(0xFF157A6E),
        Colors.white,
      ),
      LetterMatch.present => (
        const Color(0xFFE0A93B),
        const Color(0xFFE0A93B),
        const Color(0xFF1F2A2E),
      ),
      LetterMatch.absent => (
        const Color(0xFFD8DDD7),
        const Color(0xFFD8DDD7),
        const Color(0xFF415055),
      ),
      null => (Colors.white, const Color(0xFFD9D2C6), const Color(0xFF1F2A2E)),
    };

    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Center(
          child: Text(
            letter,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
