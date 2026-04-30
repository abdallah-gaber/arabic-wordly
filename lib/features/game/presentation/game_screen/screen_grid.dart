part of 'package:arabic_wordly/features/game/presentation/game_screen.dart';

class _GuessGrid extends StatelessWidget {
  const _GuessGrid({
    required this.session,
    required this.currentGuess,
    required this.compact,
    required this.dense,
    required this.invalidGuessFeedbackTick,
    required this.layoutProfile,
  });

  final GameSession session;
  final String currentGuess;
  final bool compact;
  final bool dense;
  final int invalidGuessFeedbackTick;
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
    final previewLetters = ArabicWordRules.split(currentGuess);

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
                    rowIndex: index,
                    tileSize: tileSize,
                    gap: horizontalGap,
                    wordLength: session.wordLength,
                    isActive: index == activeRowIndex,
                    previewLetters: index == activeRowIndex
                        ? previewLetters
                        : const [],
                    shakeTrigger: index == activeRowIndex
                        ? invalidGuessFeedbackTick
                        : 0,
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

class _GuessRow extends StatefulWidget {
  const _GuessRow({
    required this.rowIndex,
    required this.tileSize,
    required this.gap,
    required this.wordLength,
    required this.isActive,
    required this.previewLetters,
    required this.shakeTrigger,
    this.letters,
  });

  final int rowIndex;
  final List<LetterEvaluation>? letters;
  final double tileSize;
  final double gap;
  final int wordLength;
  final bool isActive;
  final List<String> previewLetters;
  final int shakeTrigger;

  @override
  State<_GuessRow> createState() => _GuessRowState();
}

class _GuessRowState extends State<_GuessRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    _shakeOffset = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 10, end: -8), weight: 2),
        TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
        TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 1),
        TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(covariant _GuessRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && widget.shakeTrigger != oldWidget.shakeTrigger) {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeOffset.value, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(
          widget.wordLength,
          (index) => Padding(
            padding: EdgeInsetsDirectional.only(
              start: index == 0 ? 0 : widget.gap,
            ),
            child: _GuessTile(
              key: ValueKey('guess-tile-${widget.rowIndex}-$index'),
              faceKey: ValueKey('guess-tile-face-${widget.rowIndex}-$index'),
              size: widget.tileSize,
              tileIndex: index,
              isActive: widget.isActive,
              letter: widget.letters == null
                  ? (index < widget.previewLetters.length
                        ? widget.previewLetters[index]
                        : '')
                  : widget.letters![index].letter,
              match: widget.letters == null
                  ? null
                  : widget.letters![index].match,
            ),
          ),
          growable: false,
        ),
      ),
    );
  }
}

class _GuessTile extends StatefulWidget {
  const _GuessTile({
    super.key,
    required this.faceKey,
    required this.size,
    required this.tileIndex,
    required this.isActive,
    required this.letter,
    required this.match,
  });

  final Key faceKey;
  final double size;
  final int tileIndex;
  final bool isActive;
  final String letter;
  final LetterMatch? match;

  @override
  State<_GuessTile> createState() => _GuessTileState();
}

class _GuessTileState extends State<_GuessTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flipTurns;
  int _animationToken = 0;
  LetterMatch? _displayedMatch;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _flipTurns = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
    _displayedMatch = widget.match;
    if (widget.match != null) {
      _controller.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant _GuessTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.match == null && widget.match != null) {
      _displayedMatch = null;
      _playAnimation(delay: Duration(milliseconds: widget.tileIndex * 55));
    } else if (oldWidget.letter != widget.letter &&
        widget.match == null &&
        widget.letter.isNotEmpty) {
      _playAnimation();
    } else if (oldWidget.letter.isNotEmpty &&
        widget.letter.isEmpty &&
        widget.match == null) {
      _animationToken++;
      _displayedMatch = null;
      _controller.reverse(from: _controller.value == 0 ? 1 : _controller.value);
    } else if (oldWidget.match != widget.match && widget.match == null) {
      _displayedMatch = null;
    }
  }

  void _playAnimation({Duration delay = Duration.zero}) {
    _animationToken++;
    final token = _animationToken;
    _controller.reset();
    if (delay == Duration.zero) {
      setState(() {
        _displayedMatch = widget.match;
      });
      _controller.forward();
      return;
    }

    Future<void>.delayed(delay, () {
      if (!mounted || token != _animationToken) {
        return;
      }
      setState(() {
        _displayedMatch = widget.match;
      });
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleMatch = _displayedMatch;
    final (backgroundColor, borderColor, textColor) = switch (visibleMatch) {
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
        final angle = _flipTurns.value * pi;
        final effectiveAngle = angle > (pi / 2) ? angle - pi : angle;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0014)
            ..rotateY(effectiveAngle),
          child: child,
        );
      },
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedContainer(
          key: widget.faceKey,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: visibleMatch != null
                    ? backgroundColor.withValues(alpha: 0.22)
                    : widget.isActive
                        ? const Color(0x1F157A6E)
                        : Colors.black.withValues(alpha: 0.05),
                blurRadius: visibleMatch != null ? 14 : (widget.isActive ? 12 : 6),
                offset: Offset(0, visibleMatch != null ? 6 : (widget.isActive ? 6 : 2)),
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
                key: ValueKey('${widget.letter}-$visibleMatch'),
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
