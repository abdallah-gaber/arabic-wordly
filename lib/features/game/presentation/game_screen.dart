import 'dart:async';
import 'dart:math';

import 'package:arabic_wordly/app/app_branding.dart';
import 'package:arabic_wordly/app/services/app_haptics.dart';
import 'package:arabic_wordly/features/game/application/game_controller.dart';
import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/guess_evaluator.dart';
import 'package:arabic_wordly/features/game/domain/hint_selector.dart';
import 'package:arabic_wordly/features/game/domain/player_stats.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'game_screen/screen_layout.dart';
part 'game_screen/screen_header.dart';
part 'game_screen/screen_input.dart';
part 'game_screen/screen_hints.dart';
part 'game_screen/screen_chips.dart';
part 'game_screen/screen_grid.dart';
part 'game_screen/screen_dialogs.dart';

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
  late final FocusNode _guessFocusNode;
  late final Timer _hintTimer;
  bool _isResultDialogOpen = false;
  bool _wasGuessReady = false;

  void _handleGuessChanged() {
    final sanitized = ArabicWordRules.sanitizeGuessInput(
      _guessController.text,
      maxLength: widget.mode.wordLength,
    );
    if (sanitized != _guessController.text) {
      _guessController.value = TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
      return;
    }

    final isReady = _isGuessReady;
    if (isReady && !_wasGuessReady) {
      unawaited(AppHaptics.selection());
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
    _guessFocusNode = FocusNode()
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });
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
    _guessFocusNode.dispose();
    _hintTimer.cancel();
    super.dispose();
  }

  Future<void> _submitGuess() async {
    if (!_isGuessReady) {
      unawaited(AppHaptics.warning());
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
        unawaited(AppHaptics.lightImpact());
      }
      _guessController.clear();
    } else {
      unawaited(AppHaptics.warning());
    }
  }

  Future<void> _skipPuzzle() async {
    FocusScope.of(context).unfocus();
    _guessController.clear();
    await ref.read(gameControllerProvider(widget.mode).notifier).skipPuzzle();
    unawaited(AppHaptics.mediumImpact());
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
      unawaited(AppHaptics.selection());
    } else {
      unawaited(AppHaptics.warning());
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

  bool _typingModeFor(BuildContext context) {
    return _guessFocusNode.hasFocus;
  }

  bool _shouldShowPinnedVerifyBar({required bool typingMode}) {
    return typingMode && !kIsWeb;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider(widget.mode));
    final playerStats = ref.watch(playerStatsProvider).asData?.value;
    final now = ref.read(clockProvider)();
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final typingMode = _typingModeFor(context);
    final showPinnedVerifyBar = _shouldShowPinnedVerifyBar(
      typingMode: typingMode,
    );
    ref.listen(gameControllerProvider(widget.mode), (previous, next) {
      final previousResult = previous?.asData?.value.pendingResult;
      final nextResult = next.asData?.value.pendingResult;
      if (nextResult != null && !identical(previousResult, nextResult)) {
        unawaited(
          nextResult.type == RoundResultType.won
              ? AppHaptics.success()
              : AppHaptics.failure(),
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
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: SafeArea(
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
                              padding: EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                20 +
                                    viewInsets.bottom +
                                    (showPinnedVerifyBar
                                        ? _PinnedVerifyBar.barHeight + 16
                                        : 0),
                              ),
                              child: _GameLayout(
                                session: viewState.session,
                                playerStats: playerStats ?? const PlayerStats(),
                                feedback:
                                    viewState.feedback ??
                                    'استمر حتى تصل إلى الإجابة الصحيحة.',
                                guessController: _guessController,
                                guessFocusNode: _guessFocusNode,
                                currentLetterCount: _currentLetterCount,
                                isGuessReady: _isGuessReady,
                                mode: widget.mode,
                                now: now,
                                onSubmitGuess: _submitGuess,
                                onSkipPuzzle: _skipPuzzle,
                                onUseHint: _useHint,
                                typingMode: typingMode,
                                showPinnedVerifyBar: showPinnedVerifyBar,
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
          ),
          if (showPinnedVerifyBar)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                top: false,
                child: _PinnedVerifyBar(
                  isGuessReady: _isGuessReady,
                  onSubmitGuess: _submitGuess,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PinnedVerifyBar extends StatelessWidget {
  const _PinnedVerifyBar({
    required this.isGuessReady,
    required this.onSubmitGuess,
  });

  static const double barHeight = 72;

  final bool isGuessReady;
  final Future<void> Function() onSubmitGuess;

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const ValueKey('pinned-verify-bar'),
      elevation: 10,
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD9D2C6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SizedBox(
          height: barHeight - 16,
          child: ElevatedButton.icon(
            onPressed: isGuessReady ? onSubmitGuess : null,
            icon: const Icon(Icons.check_circle_outline),
            label: Text(isGuessReady ? 'تحقق الآن' : 'أكمل الكلمة أولاً'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(barHeight - 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
