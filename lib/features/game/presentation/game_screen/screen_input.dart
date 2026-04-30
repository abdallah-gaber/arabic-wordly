part of 'package:arabic_wordly/features/game/presentation/game_screen.dart';

class _InputSection extends StatefulWidget {
  const _InputSection({
    required this.guessController,
    required this.guessFocusNode,
    required this.currentLetterCount,
    required this.isGuessReady,
    required this.dense,
    required this.session,
    required this.mode,
    required this.now,
    required this.onSubmitGuess,
    required this.onSkipPuzzle,
    required this.onUseHint,
    required this.onShareHelp,
    required this.onTapLetter,
    required this.onBackspace,
    required this.layoutProfile,
    required this.typingMode,
    required this.showPinnedVerifyBar,
  });

  final TextEditingController guessController;
  final FocusNode guessFocusNode;
  final int currentLetterCount;
  final bool isGuessReady;
  final bool dense;
  final GameSession session;
  final GameMode mode;
  final DateTime now;
  final Future<void> Function() onSubmitGuess;
  final Future<void> Function() onSkipPuzzle;
  final Future<void> Function() onUseHint;
  final Future<void> Function() onShareHelp;
  final ValueChanged<String> onTapLetter;
  final VoidCallback onBackspace;
  final _ModeLayoutProfile layoutProfile;
  final bool typingMode;
  final bool showPinnedVerifyBar;

  @override
  State<_InputSection> createState() => _InputSectionState();
}

class _InputSectionState extends State<_InputSection> {
  late bool _showHints;

  @override
  void initState() {
    super.initState();
    _showHints = !widget.dense && !widget.typingMode;
  }

  @override
  void didUpdateWidget(covariant _InputSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.typingMode && !oldWidget.typingMode && _showHints) {
      setState(() {
        _showHints = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compactLayout = width < 430;
    final progressColor = widget.isGuessReady
        ? const Color(0xFF157A6E)
        : const Color(0xFFC84F4F);
    final progressBackground = widget.isGuessReady
        ? const Color(0xFFE4F2EF)
        : const Color(0xFFFCEAEA);
    final hasHintsRemaining = HintSelector.hasUsefulHints(widget.session);
    final canUseHint = HintSelector.canUseHint(widget.session, widget.now);
    final hintWait = hasHintsRemaining
        ? widget.session.remainingHintWait(widget.now)
        : Duration.zero;
    final hintLetters = widget.session.revealedHintLetters;
    final lettersRemaining = max(
      0,
      widget.mode.wordLength - widget.currentLetterCount,
    );
    final statusLabel = widget.isGuessReady
        ? 'جاهز للتحقق'
        : lettersRemaining == widget.mode.wordLength
        ? 'ابدأ التخمين'
        : 'متبقي $lettersRemaining';
    final statusBackground = widget.isGuessReady
        ? const Color(0xFF157A6E)
        : const Color(0xFFF4E8C8);
    final statusForeground = widget.isGuessReady
        ? Colors.white
        : const Color(0xFF805B16);
    final inputPanelColor = widget.isGuessReady
        ? const Color(0xFFF2FBF7)
        : const Color(0xFFFFFCF6);
    final countChip = Container(
      key: const ValueKey('letter-count-chip'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: progressBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(
          '${widget.currentLetterCount} / ${widget.mode.wordLength}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: progressColor,
            fontWeight: FontWeight.w800,
            fontSize: widget.dense ? 13 : null,
          ),
        ),
      ),
    );
    final progressDots = Row(
      key: const ValueKey('guess-progress-dots'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(widget.mode.wordLength, (index) {
        final isFilled = index < widget.currentLetterCount;
        return Container(
          key: ValueKey('guess-progress-dot-$index'),
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled ? progressColor : const Color(0xFFD8D1C5),
          ),
        );
      }),
    );
    final keyboardKeys = GameKeyboard.buildKeys(
      guesses: widget.session.guesses,
      answer: widget.session.answer,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(widget.layoutProfile.inputPanelPadding),
          decoration: BoxDecoration(
            color: inputPanelColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.isGuessReady
                  ? const Color(0xFF90CBBB)
                  : const Color(0xFFD9D2C6),
              width: widget.isGuessReady ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isGuessReady
                    ? const Color(0x22157A6E)
                    : const Color(0x0F1F2A2E),
                blurRadius: widget.isGuessReady ? 18 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 8,
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'المحاولة الحالية',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF5D635F),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  _StatusChip(
                    label: statusLabel,
                    background: statusBackground,
                    foreground: statusForeground,
                  ),
                ],
              ),
              SizedBox(height: widget.dense ? 10 : 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: widget.isGuessReady
                        ? const Color(0xFF90CBBB)
                        : const Color(0xFFD9D2C6),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'التخمين الحالي',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF5D635F),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.guessController.text.isEmpty
                          ? 'ابدأ من لوحة الحروف العربية'
                          : widget.guessController.text,
                      key: const ValueKey('active-guess-display'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: widget.guessController.text.isEmpty
                            ? const Color(0xFF8C877E)
                            : const Color(0xFF1F2A2E),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: widget.dense ? 16 : 18,
                color: widget.isGuessReady
                    ? const Color(0xFFCAE0D7)
                    : const Color(0xFFE3DDD1),
              ),
              progressDots,
              SizedBox(height: widget.dense ? 8 : 10),
              if (compactLayout)
                Column(
                  children: [
                    countChip,
                    SizedBox(height: widget.dense ? 8 : 10),
                    Text(
                      widget.isGuessReady
                          ? 'الطول صحيح. يمكنك التحقق الآن.'
                          : 'اكتب ${widget.mode.wordLength} أحرف كاملة لتفعيل التحقق.',
                      textAlign: TextAlign.center,
                      style:
                          (widget.dense
                                  ? Theme.of(context).textTheme.bodySmall
                                  : Theme.of(context).textTheme.bodyMedium)
                              ?.copyWith(
                                color: progressColor,
                                fontWeight: FontWeight.w700,
                                fontSize: widget.dense ? 11 : 13,
                              ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    countChip,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.isGuessReady
                            ? 'الطول صحيح. يمكنك التحقق الآن.'
                            : 'اكتب ${widget.mode.wordLength} أحرف كاملة لتفعيل التحقق.',
                        textAlign: TextAlign.center,
                        style:
                            (widget.dense
                                    ? Theme.of(context).textTheme.bodySmall
                                    : Theme.of(context).textTheme.bodyMedium)
                                ?.copyWith(
                                  color: progressColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: widget.dense ? 11 : 13,
                                ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: widget.dense ? 12 : 14),
              _GameKeyboardPanel(
                keys: keyboardKeys,
                canSubmit: widget.isGuessReady,
                canBackspace: widget.currentLetterCount > 0,
                onTapLetter: widget.onTapLetter,
                onBackspace: widget.onBackspace,
                onSubmit: widget.onSubmitGuess,
              ),
              if (!widget.showPinnedVerifyBar) ...[
                SizedBox(height: widget.dense ? 10 : 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.isGuessReady
                        ? widget.onSubmitGuess
                        : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(
                      widget.isGuessReady ? 'تحقق الآن' : 'أكمل الكلمة أولاً',
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size.fromHeight(widget.dense ? 50 : 56),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: widget.dense ? 8 : 12),
        if (widget.typingMode)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TypingActionButton(
                      onPressed: widget.onSkipPuzzle,
                      icon: Icons.autorenew_rounded,
                      title: 'لغز جديد',
                      subtitle: 'بدّل الجولة',
                      accent: const Color(0xFF157A6E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TypingActionButton(
                      onPressed: widget.session.guesses.isEmpty
                          ? null
                          : widget.onShareHelp,
                      icon: Icons.ios_share_rounded,
                      title: 'شارك للمساعدة',
                      subtitle: widget.session.guesses.isEmpty
                          ? 'بعد أول محاولة'
                          : 'صورة سريعة',
                      accent: const Color(0xFF8A6410),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _SecondaryPanelToggle(
                title: 'التلميحات',
                subtitle: hasHintsRemaining
                    ? canUseHint
                          ? 'جاهز الآن'
                          : 'التالي ${_formatHintWait(hintWait)}'
                    : 'اكتمل',
                isExpanded: _showHints,
                onToggle: () => setState(() => _showHints = !_showHints),
                compact: true,
              ),
            ],
          )
        else ...[
          TextButton.icon(
            onPressed: widget.onSkipPuzzle,
            icon: const Icon(Icons.autorenew_rounded),
            label: const Text('لغز جديد'),
          ),
          SizedBox(height: widget.dense ? 8 : 12),
          OutlinedButton.icon(
            onPressed: widget.session.guesses.isEmpty
                ? null
                : widget.onShareHelp,
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('شارك للمساعدة بصورة'),
          ),
          SizedBox(height: widget.dense ? 8 : 12),
          _SecondaryPanelToggle(
            title: 'التلميحات',
            subtitle: hasHintsRemaining
                ? canUseHint
                      ? 'جاهز الآن، وقد يقلل نقاط الجولة.'
                      : 'مقفلة مؤقتاً حتى ${_formatHintWait(hintWait)}.'
                : 'لا توجد تلميحات إضافية لهذا اللغز.',
            isExpanded: _showHints,
            onToggle: () => setState(() => _showHints = !_showHints),
          ),
        ],
        if (_showHints) ...[
          SizedBox(height: widget.dense ? 8 : 10),
          _HintPanel(
            dense: widget.dense,
            canUseHint: canUseHint,
            hasHintsRemaining: hasHintsRemaining,
            hintLetters: hintLetters,
            maxHints: widget.session.maxHints,
            mode: widget.mode,
            nextHintWait: hintWait,
            revealedHintCount: widget.session.revealedHintIndexes.length,
            onUseHint: widget.onUseHint,
          ),
        ],
      ],
    );
  }

  String _formatHintWait(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class _GameKeyboardPanel extends StatelessWidget {
  const _GameKeyboardPanel({
    required this.keys,
    required this.canSubmit,
    required this.canBackspace,
    required this.onTapLetter,
    required this.onBackspace,
    required this.onSubmit,
  });

  final List<GameKeyboardKey> keys;
  final bool canSubmit;
  final bool canBackspace;
  final ValueChanged<String> onTapLetter;
  final VoidCallback onBackspace;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust these to control how many keys per line
        final availableWidth = constraints.maxWidth;
        final keyWidth = ((availableWidth - (10 * 8)) / 10).clamp(24.0, 36.0);

        return Column(
          key: const ValueKey('game-arabic-keyboard'),
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 8,
              children: [
                for (final key in keys)
                  _KeyboardLetterKey(
                    width: keyWidth,
                    keyModel: key,
                    onPressed: key.isEnabled
                        ? () => onTapLetter(key.letter)
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('game-keyboard-backspace'),
                    onPressed: canBackspace ? onBackspace : null,
                    icon: const Icon(Icons.backspace_outlined),
                    label: const Text('حذف'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    key: const ValueKey('game-keyboard-submit'),
                    onPressed: canSubmit ? onSubmit : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('تحقق'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _KeyboardLetterKey extends StatelessWidget {
  const _KeyboardLetterKey({
    required this.width,
    required this.keyModel,
    this.onPressed,
  });

  final double width;
  final GameKeyboardKey keyModel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = switch (keyModel.state) {
      GameKeyboardKeyState.correct => (
          background: const Color(0xFF157A6E),
          foreground: Colors.white,
          border: const Color(0xFF157A6E),
        ),
      GameKeyboardKeyState.present => (
          background: const Color(0xFFF4E8C8),
          foreground: const Color(0xFF805B16),
          border: const Color(0xFFE1C477),
        ),
      GameKeyboardKeyState.absent => (
          background: const Color(0xFFE5E1DA),
          foreground: const Color(0xFF8B847B),
          border: const Color(0xFFD5CEC4),
        ),
      GameKeyboardKeyState.unused => (
          background: Colors.white,
          foreground: const Color(0xFF1F2A2E),
          border: const Color(0xFFD9D2C6),
        ),
    };

    return SizedBox(
      width: width,
      height: 42,
      child: Material(
        color: scheme.background,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          key: ValueKey('game-key-${keyModel.letter}'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: scheme.border),
            ),
            child: Center(
              child: Text(
                keyModel.letter,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.foreground,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingActionButton extends StatelessWidget {
  const _TypingActionButton({
    required this.onPressed,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFFFFCF6) : const Color(0xFFF2EFE8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: enabled
                  ? const Color(0xFFD9D2C6)
                  : const Color(0xFFE6E0D5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: enabled ? accent : const Color(0xFFAAA39A),
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: enabled
                      ? const Color(0xFF1F2A2E)
                      : const Color(0xFFAAA39A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: enabled
                      ? const Color(0xFF6A706C)
                      : const Color(0xFFB7B1A8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryPanelToggle extends StatelessWidget {
  const _SecondaryPanelToggle({
    required this.title,
    required this.subtitle,
    required this.isExpanded,
    required this.onToggle,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final bool isExpanded;
  final VoidCallback onToggle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('hint-panel-toggle'),
        onTap: onToggle,
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF6),
            borderRadius: BorderRadius.circular(compact ? 16 : 18),
            border: Border.all(color: const Color(0xFFD9D2C6)),
          ),
          child: Row(
            children: [
              Icon(
                isExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: const Color(0xFF5D635F),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: compact
                    ? Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF5D635F),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF5D635F),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
