part of 'package:arabic_wordly/features/game/presentation/game_screen.dart';

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
    final compactHeader = size.width < 430;
    final stateLabel = switch ((canUseHint, hasHintsRemaining)) {
      (true, _) => 'جاهز',
      (false, true) => 'مقفل',
      (false, false) => 'اكتمل',
    };
    final stateBackground = switch ((canUseHint, hasHintsRemaining)) {
      (true, _) => const Color(0xFFE4F2EF),
      (false, true) => const Color(0xFFF5F2E8),
      (false, false) => const Color(0xFFE9ECE8),
    };
    final stateForeground = switch ((canUseHint, hasHintsRemaining)) {
      (true, _) => const Color(0xFF157A6E),
      (false, true) => const Color(0xFF8A6D2D),
      (false, false) => const Color(0xFF5D635F),
    };
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
          if (compactHeader)
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 8,
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: canUseHint
                          ? const Color(0xFFE0A93B)
                          : const Color(0xFF8E9B95),
                      size: dense ? 18 : 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'التلميحات',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusChip(
                      label: stateLabel,
                      background: stateBackground,
                      foreground: stateForeground,
                    ),
                    const SizedBox(width: 8),
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
              ],
            )
          else
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
                _StatusChip(
                  label: stateLabel,
                  background: stateBackground,
                  foreground: stateForeground,
                ),
                const SizedBox(width: 8),
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
