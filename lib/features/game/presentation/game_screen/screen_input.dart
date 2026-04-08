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
              TextField(
                controller: widget.guessController,
                focusNode: widget.guessFocusNode,
                autofocus: kIsWeb,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                maxLength: widget.mode.wordLength,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[\u0600-\u06FF]+'),
                  ),
                ],
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  labelText: 'التخمين الحالي',
                  hintText: 'اكتب كلمة من ${widget.mode.wordLength} أحرف',
                  counterText: '',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => widget.onSubmitGuess(),
              ),
              Divider(
                height: widget.dense ? 16 : 18,
                color: widget.isGuessReady
                    ? const Color(0xFFCAE0D7)
                    : const Color(0xFFE3DDD1),
              ),
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
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: widget.onSkipPuzzle,
                  icon: const Icon(Icons.autorenew_rounded),
                  label: const Text('لغز جديد'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SecondaryPanelToggle(
                  title: 'التلميحات',
                  subtitle: hasHintsRemaining
                      ? canUseHint
                            ? 'جاهز'
                            : _formatHintWait(hintWait)
                      : 'اكتمل',
                  isExpanded: _showHints,
                  onToggle: () => setState(() => _showHints = !_showHints),
                  compact: true,
                ),
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
