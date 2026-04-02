import 'dart:async';
import 'dart:math';

import 'package:arabic_wordly/app/app_branding.dart';
import 'package:arabic_wordly/app/services/haptics_service.dart';
import 'package:arabic_wordly/features/game/application/game_controller.dart';
import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/guess_evaluator.dart';
import 'package:arabic_wordly/features/game/domain/hint_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.mode});

  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    return _GameScreenView(mode: mode);
  }
}

class _GameScreenView extends ConsumerStatefulWidget {
  const _GameScreenView({required this.mode});

  final GameMode mode;

  @override
  ConsumerState<_GameScreenView> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<_GameScreenView> {
  late final TextEditingController _guessController;
  late final Timer _hintTimer;
  bool _isResultDialogOpen = false;
  bool _wasGuessReady = false;

  void _handleGuessChanged() {
    final isReady = _isGuessReady;
    if (isReady && !_wasGuessReady) {
      unawaited(HapticsService.selection());
    }

    if (mounted) {
      setState(() {
        _wasGuessReady = isReady;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _guessController = TextEditingController();
    _guessController.addListener(_handleGuessChanged);
    _hintTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _guessController.removeListener(_handleGuessChanged);
    _guessController.dispose();
    _hintTimer.cancel();
    super.dispose();
  }

  Future<void> _submitGuess() async {
    if (!_isGuessReady) {
      unawaited(HapticsService.warning());
      return;
    }

    final accepted = await ref
        .read(gameControllerProvider(widget.mode).notifier)
        .submitGuess(_guessController.text);

    if (!mounted) {
      return;
    }

    FocusScope.of(context).unfocus();
    if (accepted) {
      final nextState = ref
          .read(gameControllerProvider(widget.mode))
          .asData
          ?.value;
      if (nextState?.pendingResult == null) {
        unawaited(HapticsService.lightImpact());
      }
      _guessController.clear();
    } else {
      unawaited(HapticsService.warning());
    }
  }

  Future<void> _skipPuzzle() async {
    FocusScope.of(context).unfocus();
    _guessController.clear();
    await ref.read(gameControllerProvider(widget.mode).notifier).skipPuzzle();
    unawaited(HapticsService.mediumImpact());
  }

  Future<void> _useHint() async {
    FocusScope.of(context).unfocus();
    final currentState = ref
        .read(gameControllerProvider(widget.mode))
        .asData
        ?.value;
    final previousRevealedCount =
        currentState?.session.revealedHintIndexes.length ?? 0;
    final used = await ref
        .read(gameControllerProvider(widget.mode).notifier)
        .useHint();
    final nextState = ref
        .read(gameControllerProvider(widget.mode))
        .asData
        ?.value;
    final nextRevealedCount =
        nextState?.session.revealedHintIndexes.length ?? 0;
    if (used && nextRevealedCount > previousRevealedCount) {
      unawaited(HapticsService.selection());
    } else {
      unawaited(HapticsService.warning());
    }
  }

  Future<void> _showRoundResultDialog(RoundResult result) async {
    if (_isResultDialogOpen || !mounted) {
      return;
    }

    _isResultDialogOpen = true;

    final shouldAdvance = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'round-result',
      barrierColor: Colors.black.withValues(alpha: 0.28),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _RoundResultDialog(result: result);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(curve),
            child: child,
          ),
        );
      },
    );

    _isResultDialogOpen = false;

    if (!mounted || shouldAdvance != true) {
      return;
    }

    await ref
        .read(gameControllerProvider(widget.mode).notifier)
        .continueToNextPuzzle();
  }

  int get _currentLetterCount =>
      ArabicWordRules.split(_guessController.text).length;

  bool get _isGuessReady => ArabicWordRules.isValidGuessFormat(
    _guessController.text,
    wordLength: widget.mode.wordLength,
  );

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider(widget.mode));
    final now = ref.read(clockProvider)();
    ref.listen(gameControllerProvider(widget.mode), (previous, next) {
      final previousResult = previous?.asData?.value.pendingResult;
      final nextResult = next.asData?.value.pendingResult;
      if (nextResult != null && !identical(previousResult, nextResult)) {
        unawaited(
          nextResult.type == RoundResultType.won
              ? HapticsService.success()
              : HapticsService.failure(),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showRoundResultDialog(nextResult);
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _GameBackground()),
          SafeArea(
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
                  return SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                            child: _GameLayout(
                              session: viewState.session,
                              feedback:
                                  viewState.feedback ??
                                  'استمر حتى تصل إلى الإجابة الصحيحة.',
                              guessController: _guessController,
                              currentLetterCount: _currentLetterCount,
                              isGuessReady: _isGuessReady,
                              mode: widget.mode,
                              now: now,
                              onSubmitGuess: _submitGuess,
                              onSkipPuzzle: _skipPuzzle,
                              onUseHint: _useHint,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
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
    required this.mode,
    required this.now,
    required this.onSubmitGuess,
    required this.onSkipPuzzle,
    required this.onUseHint,
  });

  final GameSession session;
  final String feedback;
  final TextEditingController guessController;
  final int currentLetterCount;
  final bool isGuessReady;
  final GameMode mode;
  final DateTime now;
  final Future<void> Function() onSubmitGuess;
  final Future<void> Function() onSkipPuzzle;
  final Future<void> Function() onUseHint;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700 || size.width < 640;
    final dense = size.width < 430 || size.height < 820;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EntranceMotion(
          delayFactor: 0,
          child: _Header(session: session, compact: compact, dense: dense),
        ),
        SizedBox(
          height: dense
              ? 10
              : compact
              ? 12
              : 18,
        ),
        _EntranceMotion(
          delayFactor: 1,
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GuessGrid(session: session, compact: compact, dense: dense),
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
                    session: session,
                    mode: session.mode,
                    now: now,
                    onSubmitGuess: onSubmitGuess,
                    onSkipPuzzle: onSkipPuzzle,
                    onUseHint: onUseHint,
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
        _EntranceMotion(
          delayFactor: 2,
          child: _FeedbackBanner(feedback: feedback, compact: compact),
        ),
      ],
    );
  }
}

class _GameBackground extends StatelessWidget {
  const _GameBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF9F5EE), Color(0xFFF2F8F5), Color(0xFFF8F4EC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -90,
            right: -50,
            child: _BackgroundOrb(
              size: 220,
              colors: [Color(0x3329A28E), Color(0x00FFFFFF)],
            ),
          ),
          Positioned(
            top: 260,
            left: -70,
            child: _BackgroundOrb(
              size: 180,
              colors: [Color(0x22E0A93B), Color(0x00FFFFFF)],
            ),
          ),
          Positioned(
            bottom: -40,
            right: 30,
            child: _BackgroundOrb(
              size: 200,
              colors: [Color(0x1F157A6E), Color(0x00FFFFFF)],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundOrb extends StatelessWidget {
  const _BackgroundOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _EntranceMotion extends StatelessWidget {
  const _EntranceMotion({required this.child, required this.delayFactor});

  final Widget child;
  final int delayFactor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (delayFactor * 120)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: child,
          ),
        );
      },
      child: child,
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
          appNameArabic,
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
          appNameEnglish,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFF157A6E),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        SizedBox(height: dense ? 4 : 6),
        Text(
          appTaglineArabic,
          textAlign: TextAlign.center,
          style: (dense ? textTheme.bodySmall : textTheme.bodyMedium)?.copyWith(
            color: const Color(0xFF5D635F),
            fontSize: dense ? 11 : null,
          ),
        ),
        SizedBox(height: dense ? 8 : 10),
        Text(
          'الوضع الحالي: ${session.mode.label}',
          textAlign: TextAlign.center,
          style: textTheme.labelLarge?.copyWith(
            color: const Color(0xFF157A6E),
            fontWeight: FontWeight.w800,
          ),
        ),
        if (session.category.isNotEmpty) ...[
          SizedBox(height: dense ? 8 : 10),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: dense ? 12 : 14,
                vertical: dense ? 6 : 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3F0),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFB9D7CF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: dense ? 16 : 18,
                    color: const Color(0xFF157A6E),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'الفئة: ${session.category}',
                    style: textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF157A6E),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: const Text('تغيير الوضع'),
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
    required this.session,
    required this.mode,
    required this.now,
    required this.onSubmitGuess,
    required this.onSkipPuzzle,
    required this.onUseHint,
  });

  final TextEditingController guessController;
  final int currentLetterCount;
  final bool isGuessReady;
  final bool dense;
  final GameSession session;
  final GameMode mode;
  final DateTime now;
  final Future<void> Function() onSubmitGuess;
  final Future<void> Function() onSkipPuzzle;
  final Future<void> Function() onUseHint;

  @override
  Widget build(BuildContext context) {
    final progressColor = isGuessReady
        ? const Color(0xFF157A6E)
        : const Color(0xFFC84F4F);
    final progressBackground = isGuessReady
        ? const Color(0xFFE4F2EF)
        : const Color(0xFFFCEAEA);
    final hasHintsRemaining = HintSelector.hasUsefulHints(session);
    final canUseHint = HintSelector.canUseHint(session, now);
    final hintWait = hasHintsRemaining
        ? session.remainingHintWait(now)
        : Duration.zero;
    final hintLetters = session.revealedHintLetters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: guessController,
          autofocus: kIsWeb,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          maxLength: mode.wordLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF]+')),
          ],
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            labelText: 'التخمين الحالي',
            hintText: 'اكتب كلمة من ${mode.wordLength} أحرف',
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
                    '$currentLetterCount / ${mode.wordLength}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.w800,
                      fontSize: dense ? 13 : null,
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
              : 'اكتب ${mode.wordLength} أحرف كاملة لتفعيل التحقق.',
          textAlign: TextAlign.center,
          style:
              (dense
                      ? Theme.of(context).textTheme.bodySmall
                      : Theme.of(context).textTheme.bodyMedium)
                  ?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                    fontSize: dense ? 11 : 13,
                  ),
        ),
        SizedBox(height: dense ? 8 : 12),
        _HintPanel(
          dense: dense,
          canUseHint: canUseHint,
          hasHintsRemaining: hasHintsRemaining,
          hintLetters: hintLetters,
          maxHints: session.maxHints,
          mode: mode,
          nextHintWait: hintWait,
          revealedHintCount: session.revealedHintIndexes.length,
          onUseHint: onUseHint,
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

class _HintPanel extends StatelessWidget {
  const _HintPanel({
    required this.dense,
    required this.canUseHint,
    required this.hasHintsRemaining,
    required this.hintLetters,
    required this.maxHints,
    required this.mode,
    required this.nextHintWait,
    required this.revealedHintCount,
    required this.onUseHint,
  });

  final bool dense;
  final bool canUseHint;
  final bool hasHintsRemaining;
  final List<String?> hintLetters;
  final int maxHints;
  final GameMode mode;
  final Duration nextHintWait;
  final int revealedHintCount;
  final Future<void> Function() onUseHint;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final subtitle = switch ((canUseHint, hasHintsRemaining)) {
      (true, _) => 'التلميح التالي جاهز الآن.',
      (false, true) => 'التلميح التالي بعد ${_formatHintWait(nextHintWait)}.',
      (false, false) => 'اكتملت كل التلميحات المتاحة لهذا اللغز.',
    };
    final tileWidth = size.width < 500 ? 52.0 : 60.0;

    return Container(
      padding: EdgeInsets.all(dense ? 12 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: canUseHint ? const Color(0xFFB9D7CF) : const Color(0xFFD9D2C6),
        ),
        boxShadow: canUseHint
            ? [
                BoxShadow(
                  color: const Color(0x14157A6E),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: canUseHint
                    ? const Color(0xFFE0A93B)
                    : const Color(0xFF8E9B95),
                size: dense ? 18 : 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'التلميحات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '$revealedHintCount / $maxHints',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF5D635F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: dense ? 8 : 10),
          Wrap(
            spacing: dense ? 6 : 8,
            runSpacing: dense ? 6 : 8,
            children: List<Widget>.generate(
              mode.wordLength,
              (index) => _HintTile(
                dense: dense,
                index: index,
                letter: hintLetters[index],
                width: tileWidth,
              ),
              growable: false,
            ),
          ),
          SizedBox(height: dense ? 8 : 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              subtitle,
              key: ValueKey(subtitle),
              textAlign: TextAlign.center,
              style:
                  (dense
                          ? Theme.of(context).textTheme.bodySmall
                          : Theme.of(context).textTheme.bodyMedium)
                      ?.copyWith(
                        color: canUseHint
                            ? const Color(0xFF157A6E)
                            : const Color(0xFF5D635F),
                        fontWeight: FontWeight.w700,
                      ),
            ),
          ),
          SizedBox(height: dense ? 8 : 10),
          FilledButton.tonalIcon(
            onPressed: canUseHint ? onUseHint : null,
            icon: const Icon(Icons.tips_and_updates_outlined),
            label: Text(
              hasHintsRemaining ? 'استخدم تلميحاً' : 'لا توجد تلميحات إضافية',
            ),
          ),
        ],
      ),
    );
  }

  String _formatHintWait(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _HintTile extends StatelessWidget {
  const _HintTile({
    required this.dense,
    required this.index,
    required this.letter,
    required this.width,
  });

  final bool dense;
  final int index;
  final String? letter;
  final double width;

  @override
  Widget build(BuildContext context) {
    final revealed = letter != null;

    return SizedBox(
      width: width,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: dense ? 8 : 10),
        decoration: BoxDecoration(
          color: revealed ? const Color(0xFFEAF3F0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: revealed ? const Color(0xFF157A6E) : const Color(0xFFD9D2C6),
          ),
          boxShadow: revealed
              ? [
                  BoxShadow(
                    color: const Color(0x22157A6E),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${index + 1}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFF5D635F),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Text(
                letter ?? '؟',
                key: ValueKey(letter ?? 'empty-$index'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: revealed
                      ? const Color(0xFF157A6E)
                      : const Color(0xFF8E9B95),
                ),
              ),
            ),
          ],
        ),
      ),
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
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14157A6E),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey(feedback),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 16,
          vertical: compact ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3F0),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFCAE0D7)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x12157A6E),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          feedback,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
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
    final size = MediaQuery.sizeOf(context);
    final horizontalGap = dense
        ? 6.0
        : compact
        ? 8.0
        : 10.0;
    final verticalGap = dense
        ? 6.0
        : compact
        ? 8.0
        : 10.0;
    final tileSize = dense
        ? 48.0
        : compact
        ? 58.0
        : 68.0;
    final boardWidth =
        (tileSize * session.wordLength) +
        (horizontalGap * (session.wordLength - 1));
    final boardHeight =
        (tileSize * session.maxAttempts) +
        (verticalGap * (session.maxAttempts - 1));
    final sectionHeight = max(
      boardHeight + (dense ? 12.0 : 18.0),
      min(size.height * (dense ? 0.20 : 0.28), boardHeight + 24),
    );

    return Center(
      child: SizedBox(
        height: sectionHeight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
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
                    wordLength: session.wordLength,
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
      ),
    );
  }
}

class _GuessRow extends StatelessWidget {
  const _GuessRow({
    required this.tileSize,
    required this.gap,
    required this.wordLength,
    this.letters,
  });

  final List<LetterEvaluation>? letters;
  final double tileSize;
  final double gap;
  final int wordLength;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        wordLength,
        (index) => Padding(
          padding: EdgeInsetsDirectional.only(start: index == 0 ? 0 : gap),
          child: _GuessTile(
            size: tileSize,
            letter: letters == null ? '' : letters![index].letter,
            match: letters == null ? null : letters![index].match,
          ),
        ),
        growable: false,
      ),
    );
  }
}

class _GuessTile extends StatefulWidget {
  const _GuessTile({
    required this.size,
    required this.letter,
    required this.match,
  });

  final double size;
  final String letter;
  final LetterMatch? match;

  @override
  State<_GuessTile> createState() => _GuessTileState();
}

class _GuessTileState extends State<_GuessTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _offset = Tween<double>(
      begin: 10,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    if (widget.match != null) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _GuessTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match == null && widget.match != null) {
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (backgroundColor, borderColor, textColor) = switch (widget.match) {
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

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: Transform.scale(scale: _scale.value, child: child),
        );
      },
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: widget.match == null
                ? null
                : [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                widget.letter,
                key: ValueKey('${widget.letter}-${widget.match}'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: textColor,
                  fontSize: widget.size * 0.38,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundResultDialog extends StatelessWidget {
  const _RoundResultDialog({required this.result});

  final RoundResult result;

  @override
  Widget build(BuildContext context) {
    final isWin = result.type == RoundResultType.won;
    final color = isWin ? const Color(0xFF157A6E) : const Color(0xFFC84F4F);
    final accent = isWin ? const Color(0xFFE0A93B) : const Color(0xFFF2B3B3);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF6),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: accent),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _DialogBadge(isWin: isWin, color: color, accent: accent),
                  const SizedBox(height: 18),
                  Text(
                    isWin ? 'أحسنت!' : 'انتهت المحاولات',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isWin
                        ? 'تم حل الجولة ${result.round} خلال ${result.attemptsUsed} محاولة.'
                        : 'لم تنجح في الجولة ${result.round} هذه المرة.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF5D635F),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      'الكلمة الصحيحة: ${result.answer}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: Icon(
                      isWin
                          ? Icons.arrow_forward_rounded
                          : Icons.refresh_rounded,
                    ),
                    label: Text(isWin ? 'التالي' : 'جرب لغزاً جديداً'),
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

class _DialogBadge extends StatelessWidget {
  const _DialogBadge({
    required this.isWin,
    required this.color,
    required this.accent,
  });

  final bool isWin;
  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.86, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.95),
                  color.withValues(alpha: 0.94),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Icon(
            isWin
                ? Icons.celebration_rounded
                : Icons.sentiment_dissatisfied_rounded,
            color: Colors.white,
            size: 48,
          ),
          if (isWin) ...[
            const Positioned(top: 8, right: 10, child: _Sparkle(size: 20)),
            const Positioned(bottom: 14, left: 8, child: _Sparkle(size: 16)),
            const Positioned(top: 18, left: 4, child: _Sparkle(size: 12)),
          ],
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      size: size,
      color: const Color(0xFFFFF4CC),
    );
  }
}
