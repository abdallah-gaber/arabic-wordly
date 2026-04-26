import 'dart:async';
import 'dart:math';

import 'package:arabic_wordly/app/app_branding.dart';
import 'package:arabic_wordly/app/services/app_haptics.dart';
import 'package:arabic_wordly/app/services/share_image_service.dart';
import 'package:arabic_wordly/app/services/share_sheet_service.dart';
import 'package:arabic_wordly/features/game/application/game_controller.dart';
import 'package:arabic_wordly/features/game/domain/arabic_word_rules.dart';
import 'package:arabic_wordly/features/game/domain/game_keyboard.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/guess_evaluator.dart';
import 'package:arabic_wordly/features/game/domain/hint_selector.dart';
import 'package:arabic_wordly/features/game/domain/player_stats.dart';
import 'package:arabic_wordly/features/game/domain/share_result_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'game_screen/screen_layout.dart';
part 'game_screen/screen_header.dart';
part 'game_screen/screen_input.dart';
part 'game_screen/screen_hints.dart';
part 'game_screen/screen_chips.dart';
part 'game_screen/screen_grid.dart';
part 'game_screen/screen_dialogs.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.mode,
    this.track = GameTrack.endless,
  });

  final GameMode mode;
  final GameTrack track;

  @override
  Widget build(BuildContext context) {
    return _GameScreenView(mode: mode, track: track);
  }
}

class _GameScreenView extends ConsumerStatefulWidget {
  const _GameScreenView({required this.mode, required this.track});

  final GameMode mode;
  final GameTrack track;

  @override
  ConsumerState<_GameScreenView> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<_GameScreenView> {
  GameConfig get _config => GameConfig(mode: widget.mode, track: widget.track);
  static const Duration _autoSubmitDelay = Duration(milliseconds: 300);
  late final TextEditingController _guessController;
  late final FocusNode _guessFocusNode;
  late final Timer _hintTimer;
  Timer? _autoSubmitTimer;
  bool _isResultDialogOpen = false;
  bool _wasGuessReady = false;
  int _invalidGuessFeedbackTick = 0;

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

    _syncAutoSubmit();
  }

  @override
  void initState() {
    super.initState();
    _guessController = TextEditingController();
    _guessFocusNode = FocusNode();
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
    _autoSubmitTimer?.cancel();
    _guessController.dispose();
    _guessFocusNode.dispose();
    _hintTimer.cancel();
    super.dispose();
  }

  Future<void> _submitGuess() async {
    _autoSubmitTimer?.cancel();
    if (!_isGuessReady) {
      _triggerInvalidGuessFeedback();
      unawaited(AppHaptics.warning());
      return;
    }

    final accepted = await ref
        .read(gameControllerProvider(_config).notifier)
        .submitGuess(_guessController.text);

    if (!mounted) {
      return;
    }

    if (accepted) {
      final nextState = ref.read(gameControllerProvider(_config)).asData?.value;
      if (nextState?.pendingResult == null) {
        unawaited(AppHaptics.lightImpact());
      }
      _guessController.clear();
    } else {
      _triggerInvalidGuessFeedback();
      unawaited(AppHaptics.warning());
    }
  }

  void _triggerInvalidGuessFeedback() {
    if (!mounted) {
      return;
    }

    setState(() {
      _invalidGuessFeedbackTick++;
    });
  }

  Future<void> _skipPuzzle() async {
    _guessController.clear();
    await ref.read(gameControllerProvider(_config).notifier).skipPuzzle();
    unawaited(AppHaptics.mediumImpact());
  }

  Future<void> _useHint() async {
    final currentState = ref
        .read(gameControllerProvider(_config))
        .asData
        ?.value;
    final previousRevealedCount =
        currentState?.session.revealedHintIndexes.length ?? 0;
    final used = await ref
        .read(gameControllerProvider(_config).notifier)
        .useHint();
    final nextState = ref.read(gameControllerProvider(_config)).asData?.value;
    final nextRevealedCount =
        nextState?.session.revealedHintIndexes.length ?? 0;
    if (used && nextRevealedCount > previousRevealedCount) {
      unawaited(AppHaptics.selection());
    } else {
      unawaited(AppHaptics.warning());
    }
  }

  Future<void> _shareCurrentProgressForHelp() async {
    final current = ref.read(gameControllerProvider(_config)).asData?.value;
    if (current == null || !mounted) {
      return;
    }

    final imagePath = await ref
        .read(shareImageServiceProvider)
        .createShareImage(
          ShareImageCardData(
            variant: ShareImageVariant.help,
            track: _config.track,
            mode: current.session.mode,
            category: current.session.category,
            guesses: current.session.guesses,
            evaluationAnswer: current.session.answer,
            statusTitle: 'أحتاج مساعدة',
            statusSubtitle:
                '${current.session.guesses.length} من ${ArabicWordRules.maxAttempts} محاولات',
            footer: 'شاركني اقتراحك التالي في خمنها.',
          ),
        );

    if (!mounted) {
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    final rect = box != null ? box.localToGlobal(Offset.zero) & box.size : null;
    try {
      await ref
          .read(shareSheetServiceProvider)
          .shareFiles(
            [imagePath],
            text:
                'أنا عالق في ${_config.track.label} | ${current.session.mode.label}. من لديه اقتراح؟',
            sharePositionOrigin: rect,
          );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر مشاركة الصورة الآن.')),
      );
    }
  }

  Future<void> _showRoundResultDialog(
    RoundResult result,
    GameSession session,
  ) async {
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
        return _RoundResultDialog(
          result: result,
          session: session,
          track: _config.track,
        );
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

    if (result.type == RoundResultType.won) {
      await _maybePromptForNotifications();
    }

    if (!mounted || shouldAdvance != true) {
      return;
    }

    await ref
        .read(gameControllerProvider(_config).notifier)
        .continueToNextPuzzle();
  }

  Future<void> _maybePromptForNotifications() async {
    final notificationService = ref.read(notificationServiceProvider);
    final shouldPrompt = await notificationService.shouldPromptForPermission();
    if (!mounted || !shouldPrompt) {
      return;
    }

    await notificationService.markPermissionPromptSeen();
    final enableNotifications =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('ذكّرني بالمحافظة على السلسلة'),
              content: const Text(
                'بعد أول فوز، يمكننا إرسال تذكير هادئ بعد 24 ساعة حتى لا تنقطع السلسلة.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('لاحقاً'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('فعّل التذكير'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!mounted || !enableNotifications) {
      return;
    }

    final granted = await notificationService.requestPermission();
    if (!granted) {
      return;
    }

    await notificationService.scheduleDailyStreakReminder(
      lastActiveAt: ref.read(clockProvider)(),
    );
  }

  int get _currentLetterCount =>
      ArabicWordRules.split(_guessController.text).length;

  bool get _isGuessReady => ArabicWordRules.isValidGuessFormat(
    _guessController.text,
    wordLength: widget.mode.wordLength,
  );

  bool _typingModeFor(BuildContext context) => false;

  bool _shouldShowPinnedVerifyBar({required bool typingMode}) => false;

  void _syncAutoSubmit() {
    _autoSubmitTimer?.cancel();
    if (!_isGuessReady) {
      return;
    }

    final scheduledGuess = _guessController.text;
    _autoSubmitTimer = Timer(_autoSubmitDelay, () {
      if (!mounted) {
        return;
      }
      if (_guessController.text != scheduledGuess || !_isGuessReady) {
        return;
      }
      unawaited(_submitGuess());
    });
  }

  void _appendLetter(String letter) {
    if (_currentLetterCount >= widget.mode.wordLength) {
      return;
    }

    final nextValue = ArabicWordRules.sanitizeGuessInput(
      '${_guessController.text}$letter',
      maxLength: widget.mode.wordLength,
    );
    _guessController.value = TextEditingValue(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
  }

  void _removeLastLetter() {
    final letters = ArabicWordRules.split(_guessController.text);
    if (letters.isEmpty) {
      return;
    }

    final nextValue = letters.take(letters.length - 1).join();
    _guessController.value = TextEditingValue(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameControllerProvider(_config));
    final playerStats = ref.watch(playerStatsProvider).asData?.value;
    final now = ref.read(clockProvider)();
    final typingMode = _typingModeFor(context);
    final showPinnedVerifyBar = _shouldShowPinnedVerifyBar(
      typingMode: typingMode,
    );
    final bottomContentPadding =
        20.0 + (showPinnedVerifyBar ? _PinnedVerifyBar.barHeight + 16.0 : 0.0);
    ref.listen(gameControllerProvider(_config), (previous, next) {
      final previousResult = previous?.asData?.value.pendingResult;
      final nextResult = next.asData?.value.pendingResult;
      if (nextResult != null && !identical(previousResult, nextResult)) {
        unawaited(
          nextResult.type == RoundResultType.won
              ? AppHaptics.success()
              : AppHaptics.failure(),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final nextSession = next.asData?.value.session;
          if (nextSession != null) {
            _showRoundResultDialog(nextResult, nextSession);
          }
        });
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: _GameBackground(track: widget.track)),
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
                              padding: EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                bottomContentPadding,
                              ),
                              child: _GameLayout(
                                session: viewState.session,
                                track: widget.track,
                                playerStats: playerStats ?? const PlayerStats(),
                                feedback:
                                    viewState.feedback ??
                                    'استمر حتى تصل إلى الإجابة الصحيحة.',
                                guessController: _guessController,
                                guessFocusNode: _guessFocusNode,
                                currentGuess: _guessController.text,
                                currentLetterCount: _currentLetterCount,
                                isGuessReady: _isGuessReady,
                                invalidGuessFeedbackTick:
                                    _invalidGuessFeedbackTick,
                                mode: widget.mode,
                                now: now,
                                onSubmitGuess: _submitGuess,
                                onSkipPuzzle: _skipPuzzle,
                                onUseHint: _useHint,
                                onShareHelp: _shareCurrentProgressForHelp,
                                onTapLetter: _appendLetter,
                                onBackspace: _removeLastLetter,
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
