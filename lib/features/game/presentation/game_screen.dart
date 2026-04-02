import 'dart:math';

import 'package:arabic_wordly/features/game/application/game_controller.dart';
import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/guess_evaluator.dart';
import 'package:flutter/foundation.dart';
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

  void _handleGuessChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _guessController = TextEditingController();
    _guessController.addListener(_handleGuessChanged);
  }

  @override
  void dispose() {
    _guessController.removeListener(_handleGuessChanged);
    _guessController.dispose();
    super.dispose();
  }

  Future<void> _submitGuess() async {
    if (!_isGuessReady) {
      return;
    }

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

  int get _currentLetterCount =>
      ArabicWordRules.split(_guessController.text).length;

  bool get _isGuessReady =>
      ArabicWordRules.isValidGuessFormat(_guessController.text);

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
          data: (viewState) => LayoutBuilder(
            builder: (context, constraints) {
              final shouldScroll =
                  constraints.maxHeight < 720 || constraints.maxWidth < 560;
              final layoutHeight = shouldScroll
                  ? max(constraints.maxHeight - 36, 760.0)
                  : constraints.maxHeight - 36;
              final content = Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    child: SizedBox(
                      height: layoutHeight,
                      child: _GameLayout(
                        session: viewState.session,
                        feedback:
                            viewState.feedback ??
                            'استمر حتى تصل إلى الإجابة الصحيحة.',
                        guessController: _guessController,
                        currentLetterCount: _currentLetterCount,
                        isGuessReady: _isGuessReady,
                        onSubmitGuess: _submitGuess,
                        onSkipPuzzle: _skipPuzzle,
                      ),
                    ),
                  ),
                ),
              );

              if (!shouldScroll) {
                return content;
              }

              return SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: content,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GameLayout extends StatelessWidget {
  const _GameLayout({
    required this.session,
    required this.feedback,
    required this.guessController,
    required this.currentLetterCount,
    required this.isGuessReady,
    required this.onSubmitGuess,
    required this.onSkipPuzzle,
  });

  final GameSession session;
  final String feedback;
  final TextEditingController guessController;
  final int currentLetterCount;
  final bool isGuessReady;
  final Future<void> Function() onSubmitGuess;
  final Future<void> Function() onSkipPuzzle;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700;
    final dense = size.width < 400 || size.height < 760;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(session: session, compact: compact, dense: dense),
        SizedBox(
          height: dense
              ? 10
              : compact
              ? 12
              : 18,
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(
                dense
                    ? 10
                    : compact
                    ? 14
                    : 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _GuessGrid(
                      session: session,
                      compact: compact,
                      dense: dense,
                    ),
                  ),
                  SizedBox(
                    height: dense
                        ? 8
                        : compact
                        ? 12
                        : 16,
                  ),
                  _InputSection(
                    guessController: guessController,
                    currentLetterCount: currentLetterCount,
                    isGuessReady: isGuessReady,
                    dense: dense,
                    onSubmitGuess: onSubmitGuess,
                    onSkipPuzzle: onSkipPuzzle,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: dense
              ? 8
              : compact
              ? 10
              : 14,
        ),
        _FeedbackBanner(feedback: feedback, compact: compact),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.session,
    required this.compact,
    required this.dense,
  });

  final GameSession session;
  final bool compact;
  final bool dense;

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
            fontSize: dense
                ? 24
                : compact
                ? 28
                : 34,
          ),
        ),
        SizedBox(
          height: dense
              ? 2
              : compact
              ? 4
              : 8,
        ),
        Text(
          'لعبة كلمات عربية بسيطة تبدأ مباشرة من اللغز الحالي.',
          textAlign: TextAlign.center,
          style: (dense ? textTheme.bodySmall : textTheme.bodyMedium)?.copyWith(
            color: const Color(0xFF5D635F),
          ),
        ),
        SizedBox(
          height: dense
              ? 10
              : compact
              ? 12
              : 16,
        ),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'المحاولات المتبقية',
                value: session.attemptsRemaining.toString(),
                dense: dense,
              ),
            ),
            SizedBox(width: dense ? 8 : 12),
            Expanded(
              child: _StatCard(
                label: 'الجولة',
                value: session.round.toString(),
                dense: dense,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InputSection extends StatelessWidget {
  const _InputSection({
    required this.guessController,
    required this.currentLetterCount,
    required this.isGuessReady,
    required this.dense,
    required this.onSubmitGuess,
    required this.onSkipPuzzle,
  });

  final TextEditingController guessController;
  final int currentLetterCount;
  final bool isGuessReady;
  final bool dense;
  final Future<void> Function() onSubmitGuess;
  final Future<void> Function() onSkipPuzzle;

  @override
  Widget build(BuildContext context) {
    final progressColor = isGuessReady
        ? const Color(0xFF157A6E)
        : const Color(0xFFC84F4F);
    final progressBackground = isGuessReady
        ? const Color(0xFFE4F2EF)
        : const Color(0xFFFCEAEA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: guessController,
          autofocus: kIsWeb,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          maxLength: ArabicWordRules.wordLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF]+')),
          ],
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            labelText: 'التخمين الحالي',
            hintText: 'اكتب كلمة من ${ArabicWordRules.wordLength} أحرف',
            counterText: '',
            suffixIcon: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: progressBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                widthFactor: 1,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '$currentLetterCount / ${ArabicWordRules.wordLength}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          onSubmitted: (_) => onSubmitGuess(),
        ),
        SizedBox(height: dense ? 6 : 10),
        Text(
          isGuessReady
              ? 'الطول صحيح. يمكنك التحقق الآن.'
              : 'اكتب ${ArabicWordRules.wordLength} أحرف كاملة لتفعيل التحقق.',
          textAlign: TextAlign.center,
          style:
              (dense
                      ? Theme.of(context).textTheme.bodySmall
                      : Theme.of(context).textTheme.bodyMedium)
                  ?.copyWith(color: progressColor, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: dense ? 8 : 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isGuessReady ? onSubmitGuess : null,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('تحقق'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextButton.icon(
                onPressed: onSkipPuzzle,
                icon: const Icon(Icons.autorenew_rounded),
                label: const Text('لغز جديد'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.dense,
  });

  final String label;
  final String value;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 12 : 16,
        vertical: dense ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: dense ? 26 : null,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style:
                (dense
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.bodyMedium)
                    ?.copyWith(color: const Color(0xFF5D635F)),
          ),
        ],
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.feedback, required this.compact});

  final String feedback;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: compact ? 12 : 16,
      ),
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
  const _GuessGrid({
    required this.session,
    required this.compact,
    required this.dense,
  });

  final GameSession session;
  final bool compact;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final horizontalGap = dense
        ? 4.0
        : compact
        ? 6.0
        : 8.0;
    final verticalGap = dense
        ? 4.0
        : compact
        ? 6.0
        : 10.0;
    final tileSize = dense
        ? 46.0
        : compact
        ? 54.0
        : 62.0;
    final boardWidth =
        (tileSize * ArabicWordRules.wordLength) +
        (horizontalGap * (ArabicWordRules.wordLength - 1));
    final boardHeight =
        (tileSize * session.maxAttempts) +
        (verticalGap * (session.maxAttempts - 1));

    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: boardWidth,
          height: boardHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < session.maxAttempts; index++) ...[
                if (index > 0) SizedBox(height: verticalGap),
                _GuessRow(
                  tileSize: tileSize,
                  gap: horizontalGap,
                  letters: index < session.guesses.length
                      ? GuessEvaluator.evaluate(
                          guess: session.guesses[index],
                          answer: session.answer,
                        ).letters
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GuessRow extends StatelessWidget {
  const _GuessRow({required this.tileSize, required this.gap, this.letters});

  final List<LetterEvaluation>? letters;
  final double tileSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        ArabicWordRules.wordLength,
        (index) => Padding(
          padding: EdgeInsetsDirectional.only(start: index == 0 ? 0 : gap),
          child: _GuessTile(
            size: tileSize,
            isFinalTile: index == ArabicWordRules.wordLength - 1,
            letter: letters == null ? '' : letters![index].letter,
            match: letters == null ? null : letters![index].match,
          ),
        ),
        growable: false,
      ),
    );
  }
}

class _GuessTile extends StatelessWidget {
  const _GuessTile({
    required this.size,
    required this.isFinalTile,
    required this.letter,
    required this.match,
  });

  final double size;
  final bool isFinalTile;
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

    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                  bottomLeft: const Radius.circular(16),
                  topLeft: Radius.circular(isFinalTile ? 24 : 16),
                ),
                border: Border.all(
                  color: isFinalTile && match == null
                      ? const Color(0xFFE0A93B)
                      : borderColor,
                  width: isFinalTile && match == null ? 1.6 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    fontSize: size * 0.38,
                  ),
                ),
              ),
            ),
          ),
          if (isFinalTile)
            PositionedDirectional(
              top: 6,
              start: 6,
              child: Container(
                width: size * 0.18,
                height: 4,
                decoration: BoxDecoration(
                  color: match == null
                      ? const Color(0xFFE0A93B)
                      : textColor.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
