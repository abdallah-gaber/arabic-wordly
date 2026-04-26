part of 'package:arabic_wordly/features/game/presentation/game_screen.dart';

class _GameLayout extends StatelessWidget {
  const _GameLayout({
    required this.session,
    required this.track,
    required this.playerStats,
    required this.feedback,
    required this.guessController,
    required this.guessFocusNode,
    required this.currentGuess,
    required this.currentLetterCount,
    required this.isGuessReady,
    required this.invalidGuessFeedbackTick,
    required this.mode,
    required this.now,
    required this.onSubmitGuess,
    required this.onSkipPuzzle,
    required this.onUseHint,
    required this.onShareHelp,
    required this.onTapLetter,
    required this.onBackspace,
    required this.typingMode,
    required this.showPinnedVerifyBar,
  });

  final GameSession session;
  final GameTrack track;
  final PlayerStats playerStats;
  final String feedback;
  final TextEditingController guessController;
  final FocusNode guessFocusNode;
  final String currentGuess;
  final int currentLetterCount;
  final bool isGuessReady;
  final int invalidGuessFeedbackTick;
  final GameMode mode;
  final DateTime now;
  final Future<void> Function() onSubmitGuess;
  final Future<void> Function() onSkipPuzzle;
  final Future<void> Function() onUseHint;
  final Future<void> Function() onShareHelp;
  final ValueChanged<String> onTapLetter;
  final VoidCallback onBackspace;
  final bool typingMode;
  final bool showPinnedVerifyBar;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.height < 700 || size.width < 640 || typingMode;
    final dense = size.width < 430 || size.height < 820 || typingMode;
    final trackPalette = _TrackPalette.resolve(track);
    final layoutProfile = _ModeLayoutProfile.resolve(
      mode: session.mode,
      size: size,
      compact: compact,
      dense: dense,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _EntranceMotion(
          delayFactor: 0,
          child: _Header(
            session: session,
            track: track,
            playerStats: playerStats,
            compact: compact,
            dense: dense,
            typingMode: typingMode,
          ),
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
          child: Container(
            decoration: BoxDecoration(
              color: trackPalette.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: trackPalette.cardBorderColor),
              boxShadow: [
                BoxShadow(
                  color: trackPalette.shadowColor,
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(layoutProfile.cardPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GuessGrid(
                    session: session,
                    currentGuess: currentGuess,
                    compact: compact,
                    dense: dense,
                    invalidGuessFeedbackTick: invalidGuessFeedbackTick,
                    layoutProfile: layoutProfile,
                  ),
                  SizedBox(height: layoutProfile.sectionSpacing),
                  _InputSection(
                    guessController: guessController,
                    guessFocusNode: guessFocusNode,
                    currentLetterCount: currentLetterCount,
                    isGuessReady: isGuessReady,
                    dense: dense,
                    session: session,
                    mode: session.mode,
                    now: now,
                    onSubmitGuess: onSubmitGuess,
                    onSkipPuzzle: onSkipPuzzle,
                    onUseHint: onUseHint,
                    onShareHelp: onShareHelp,
                    onTapLetter: onTapLetter,
                    onBackspace: onBackspace,
                    layoutProfile: layoutProfile,
                    typingMode: typingMode,
                    showPinnedVerifyBar: showPinnedVerifyBar,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!typingMode) ...[
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
      ],
    );
  }
}

class _TrackPalette {
  const _TrackPalette({
    required this.backgroundGradient,
    required this.orbTopColors,
    required this.orbLeftColors,
    required this.orbBottomColors,
    required this.headerChipBackground,
    required this.headerChipForeground,
    required this.headerChipBorder,
    required this.cardColor,
    required this.cardBorderColor,
    required this.shadowColor,
    required this.bannerTitle,
    required this.bannerSubtitle,
    required this.bannerIcon,
  });

  final List<Color> backgroundGradient;
  final List<Color> orbTopColors;
  final List<Color> orbLeftColors;
  final List<Color> orbBottomColors;
  final Color headerChipBackground;
  final Color headerChipForeground;
  final Color headerChipBorder;
  final Color cardColor;
  final Color cardBorderColor;
  final Color shadowColor;
  final String bannerTitle;
  final String bannerSubtitle;
  final IconData bannerIcon;

  static _TrackPalette resolve(GameTrack track) {
    return switch (track) {
      GameTrack.daily => const _TrackPalette(
        backgroundGradient: [
          Color(0xFFFFF7E8),
          Color(0xFFF5FBF6),
          Color(0xFFFFF1D6),
        ],
        orbTopColors: [Color(0x55E0A93B), Color(0x00FFFFFF)],
        orbLeftColors: [Color(0x3329A28E), Color(0x00FFFFFF)],
        orbBottomColors: [Color(0x33C98B2E), Color(0x00FFFFFF)],
        headerChipBackground: Color(0xFFFFF2CC),
        headerChipForeground: Color(0xFF8A6410),
        headerChipBorder: Color(0xFFE5C06A),
        cardColor: Color(0xFFFFF9EE),
        cardBorderColor: Color(0xFFE8D49A),
        shadowColor: Color(0x1FBE922A),
        bannerTitle: 'التحدي اليومي',
        bannerSubtitle: 'كلمة واحدة مشتركة للجميع اليوم.',
        bannerIcon: Icons.wb_sunny_rounded,
      ),
      _ => const _TrackPalette(
        backgroundGradient: [
          Color(0xFFF9F5EE),
          Color(0xFFF2F8F5),
          Color(0xFFF8F4EC),
        ],
        orbTopColors: [Color(0x3329A28E), Color(0x00FFFFFF)],
        orbLeftColors: [Color(0x22E0A93B), Color(0x00FFFFFF)],
        orbBottomColors: [Color(0x1F157A6E), Color(0x00FFFFFF)],
        headerChipBackground: Color(0xFFEAF3F0),
        headerChipForeground: Color(0xFF157A6E),
        headerChipBorder: Color(0xFFB9D7CF),
        cardColor: Color(0xFFFFFCF6),
        cardBorderColor: Color(0xFFD9D2C6),
        shadowColor: Color(0x14157A6E),
        bannerTitle: 'اللعب المفتوح',
        bannerSubtitle: 'تقدر تكمل وتبدّل بين الجولات بحرية.',
        bannerIcon: Icons.all_inclusive_rounded,
      ),
    };
  }
}

class _ModeLayoutProfile {
  const _ModeLayoutProfile({
    required this.tileSize,
    required this.horizontalGap,
    required this.verticalGap,
    required this.boardSectionHeightFactor,
    required this.boardSectionExtraHeight,
    required this.boardSectionPadding,
    required this.sectionSpacing,
    required this.cardPadding,
    required this.inputPanelPadding,
  });

  final double tileSize;
  final double horizontalGap;
  final double verticalGap;
  final double boardSectionHeightFactor;
  final double boardSectionExtraHeight;
  final double boardSectionPadding;
  final double sectionSpacing;
  final double cardPadding;
  final double inputPanelPadding;

  static _ModeLayoutProfile resolve({
    required GameMode mode,
    required Size size,
    required bool compact,
    required bool dense,
  }) {
    final baseCardPadding = dense
        ? 10.0
        : compact
        ? 14.0
        : 18.0;
    final baseSectionSpacing = dense
        ? 8.0
        : compact
        ? 12.0
        : 16.0;
    return switch (mode) {
      GameMode.threeLetters => _ModeLayoutProfile(
        tileSize: dense
            ? 56
            : compact
            ? 64
            : 76,
        horizontalGap: dense ? 8 : 10,
        verticalGap: dense ? 7 : 9,
        boardSectionHeightFactor: dense ? 0.18 : 0.22,
        boardSectionExtraHeight: dense ? 18 : 24,
        boardSectionPadding: dense ? 10 : 14,
        sectionSpacing: baseSectionSpacing - 2,
        cardPadding: baseCardPadding,
        inputPanelPadding: dense ? 12 : 16,
      ),
      GameMode.fourLetters => _ModeLayoutProfile(
        tileSize: dense
            ? 52
            : compact
            ? 60
            : 70,
        horizontalGap: dense ? 7 : 9,
        verticalGap: dense ? 7 : 9,
        boardSectionHeightFactor: dense ? 0.20 : 0.24,
        boardSectionExtraHeight: dense ? 16 : 22,
        boardSectionPadding: dense ? 10 : 14,
        sectionSpacing: baseSectionSpacing,
        cardPadding: baseCardPadding,
        inputPanelPadding: dense ? 12 : 16,
      ),
      GameMode.fiveLetters => _ModeLayoutProfile(
        tileSize: dense
            ? 48
            : compact
            ? 58
            : 68,
        horizontalGap: dense
            ? 6
            : compact
            ? 8
            : 10,
        verticalGap: dense
            ? 6
            : compact
            ? 8
            : 10,
        boardSectionHeightFactor: dense ? 0.22 : 0.28,
        boardSectionExtraHeight: dense ? 14 : 20,
        boardSectionPadding: dense ? 10 : 14,
        sectionSpacing: baseSectionSpacing,
        cardPadding: baseCardPadding,
        inputPanelPadding: dense ? 12 : 16,
      ),
      GameMode.sixLetters => _ModeLayoutProfile(
        tileSize: dense
            ? 44
            : compact
            ? 52
            : 60,
        horizontalGap: dense
            ? 5
            : compact
            ? 6
            : 8,
        verticalGap: dense
            ? 5
            : compact
            ? 7
            : 8,
        boardSectionHeightFactor: dense ? 0.24 : 0.29,
        boardSectionExtraHeight: dense ? 12 : 18,
        boardSectionPadding: dense ? 8 : 12,
        sectionSpacing: dense ? 10 : 14,
        cardPadding: dense ? baseCardPadding - 1 : baseCardPadding,
        inputPanelPadding: dense ? 10 : 14,
      ),
    };
  }
}

class _GameBackground extends StatelessWidget {
  const _GameBackground({required this.track});

  final GameTrack track;

  @override
  Widget build(BuildContext context) {
    final palette = _TrackPalette.resolve(track);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: palette.backgroundGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -50,
            child: _BackgroundOrb(size: 220, colors: palette.orbTopColors),
          ),
          Positioned(
            top: 260,
            left: -70,
            child: _BackgroundOrb(size: 180, colors: palette.orbLeftColors),
          ),
          Positioned(
            bottom: -40,
            right: 30,
            child: _BackgroundOrb(size: 200, colors: palette.orbBottomColors),
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
