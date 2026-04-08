part of 'package:arabic_wordly/features/game/presentation/game_screen.dart';

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
    required this.layoutProfile,
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
  final _ModeLayoutProfile layoutProfile;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compactLayout = width < 430;
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
    final lettersRemaining = max(0, mode.wordLength - currentLetterCount);
    final statusLabel = isGuessReady
        ? 'جاهز للتحقق'
        : lettersRemaining == mode.wordLength
        ? 'ابدأ التخمين'
        : 'متبقي $lettersRemaining';
    final statusBackground = isGuessReady
        ? const Color(0xFF157A6E)
        : const Color(0xFFF4E8C8);
    final statusForeground = isGuessReady
        ? Colors.white
        : const Color(0xFF805B16);
    final inputPanelColor = isGuessReady
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
          '$currentLetterCount / ${mode.wordLength}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: progressColor,
            fontWeight: FontWeight.w800,
            fontSize: dense ? 13 : null,
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
          padding: EdgeInsets.all(layoutProfile.inputPanelPadding),
          decoration: BoxDecoration(
            color: inputPanelColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isGuessReady
                  ? const Color(0xFF90CBBB)
                  : const Color(0xFFD9D2C6),
              width: isGuessReady ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isGuessReady
                    ? const Color(0x22157A6E)
                    : const Color(0x0F1F2A2E),
                blurRadius: isGuessReady ? 18 : 12,
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
              SizedBox(height: dense ? 10 : 12),
              TextField(
                controller: guessController,
                autofocus: kIsWeb,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                maxLength: mode.wordLength,
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
                  hintText: 'اكتب كلمة من ${mode.wordLength} أحرف',
                  counterText: '',
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (_) => onSubmitGuess(),
              ),
              Divider(
                height: dense ? 16 : 18,
                color: isGuessReady
                    ? const Color(0xFFCAE0D7)
                    : const Color(0xFFE3DDD1),
              ),
              if (compactLayout)
                Column(
                  children: [
                    countChip,
                    SizedBox(height: dense ? 8 : 10),
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
                  ],
                )
              else
                Row(
                  children: [
                    countChip,
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
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
                    ),
                  ],
                ),
            ],
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
        if (layoutProfile.stackActions) ...[
          ElevatedButton.icon(
            onPressed: isGuessReady ? onSubmitGuess : null,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('تحقق'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onSkipPuzzle,
            icon: const Icon(Icons.autorenew_rounded),
            label: const Text('لغز جديد'),
          ),
        ] else
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
