part of 'package:arabic_wordly/features/game/presentation/game_screen.dart';

class _GuessGrid extends StatelessWidget {
  const _GuessGrid({
    required this.session,
    required this.compact,
    required this.dense,
    required this.layoutProfile,
  });

  final GameSession session;
  final bool compact;
  final bool dense;
  final _ModeLayoutProfile layoutProfile;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontalGap = layoutProfile.horizontalGap;
    final verticalGap = layoutProfile.verticalGap;
    final tileSize = layoutProfile.tileSize;
    final boardWidth =
        (tileSize * session.wordLength) +
        (horizontalGap * (session.wordLength - 1));
    final boardHeight =
        (tileSize * session.maxAttempts) +
        (verticalGap * (session.maxAttempts - 1));
    final sectionHeight = max(
      boardHeight + layoutProfile.boardSectionExtraHeight,
      min(
        size.height * layoutProfile.boardSectionHeightFactor,
        boardHeight + (layoutProfile.boardSectionPadding * 2),
      ),
    );
    final activeRowIndex = session.outcome == SessionOutcome.inProgress
        ? session.guesses.length.clamp(0, session.maxAttempts - 1)
        : -1;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: sectionHeight,
        padding: EdgeInsets.symmetric(
          vertical: layoutProfile.boardSectionPadding,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF8F4EC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5DED1)),
        ),
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
                    isActive: index == activeRowIndex,
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
    required this.isActive,
    this.letters,
  });

  final List<LetterEvaluation>? letters;
  final double tileSize;
  final double gap;
  final int wordLength;
  final bool isActive;

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
            isActive: isActive,
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
    required this.isActive,
    required this.letter,
    required this.match,
  });

  final double size;
  final bool isActive;
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
      null => (
        widget.isActive ? const Color(0xFFF4FBF8) : Colors.white,
        widget.isActive ? const Color(0xFF5FAE9E) : const Color(0xFFD9D2C6),
        const Color(0xFF1F2A2E),
      ),
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
                ? widget.isActive
                      ? [
                          BoxShadow(
                            color: const Color(0x1F157A6E),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null
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
