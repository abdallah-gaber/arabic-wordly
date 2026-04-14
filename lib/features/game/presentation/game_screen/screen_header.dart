part of 'package:arabic_wordly/features/game/presentation/game_screen.dart';

class _Header extends StatelessWidget {
  const _Header({
    required this.session,
    required this.playerStats,
    required this.compact,
    required this.dense,
    required this.typingMode,
  });

  final GameSession session;
  final PlayerStats playerStats;
  final bool compact;
  final bool dense;
  final bool typingMode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final compactHeader = width < 430;
    final stackStats = width < 360;
    final currentModeStats = playerStats.statsForMode(session.mode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          appNameArabic,
          textAlign: TextAlign.center,
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: typingMode
                ? 22
                : dense
                ? 24
                : compact
                ? 28
                : 34,
          ),
        ),
        if (!typingMode) ...[
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
            style: (dense ? textTheme.bodySmall : textTheme.bodyMedium)
                ?.copyWith(
                  color: const Color(0xFF5D635F),
                  fontSize: dense ? 11 : null,
                ),
          ),
        ],
        SizedBox(height: typingMode ? 6 : (dense ? 8 : 10)),
        if (typingMode) ...[
          Align(
            alignment: Alignment.center,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                _CompactHeaderChip(label: session.mode.label),
                if (session.category.isNotEmpty)
                  _CompactHeaderChip(label: session.category),
              ],
            ),
          ),
          SizedBox(height: dense ? 8 : 10),
        ] else ...[
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: width - (dense ? 24 : 32),
                ),
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
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: dense ? 16 : 18,
                        color: const Color(0xFF157A6E),
                      ),
                      Text(
                        'الفئة: ${session.category}',
                        textAlign: TextAlign.center,
                        style: textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF157A6E),
                          fontWeight: FontWeight.w800,
                          fontSize: compactHeader ? 13 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: dense ? 4 : 6),
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
        ],
        if (typingMode)
          _CompactHeaderStats(
            attemptsRemaining: session.attemptsRemaining.toString(),
            round: session.round.toString(),
            totalScore: playerStats.totalScore.toString(),
          )
        else if (stackStats)
          Column(
            children: [
              _StatCard(
                label: 'المحاولات المتبقية',
                value: session.attemptsRemaining.toString(),
                dense: dense,
              ),
              SizedBox(height: dense ? 8 : 10),
              _StatCard(
                label: 'الجولة',
                value: session.round.toString(),
                dense: dense,
              ),
              SizedBox(height: dense ? 8 : 10),
              _ProgressStatsCard(
                totalScore: playerStats.totalScore,
                currentStreak: playerStats.currentStreak,
                solvedForMode: currentModeStats.solved,
                dense: dense,
              ),
            ],
          )
        else
          Column(
            children: [
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
              SizedBox(height: dense ? 8 : 10),
              _ProgressStatsCard(
                totalScore: playerStats.totalScore,
                currentStreak: playerStats.currentStreak,
                solvedForMode: currentModeStats.solved,
                dense: dense,
              ),
            ],
          ),
      ],
    );
  }
}

class _CompactHeaderStats extends StatelessWidget {
  const _CompactHeaderStats({
    required this.attemptsRemaining,
    required this.round,
    required this.totalScore,
  });

  final String attemptsRemaining;
  final String round;
  final String totalScore;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _CompactHeaderChip(label: 'المتبقي $attemptsRemaining'),
        _CompactHeaderChip(label: 'الجولة $round'),
        _CompactHeaderChip(label: 'النقاط $totalScore'),
      ],
    );
  }
}

class _CompactHeaderChip extends StatelessWidget {
  const _CompactHeaderChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD9D2C6)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF415055),
        ),
      ),
    );
  }
}

class _ProgressStatsCard extends StatelessWidget {
  const _ProgressStatsCard({
    required this.totalScore,
    required this.currentStreak,
    required this.solvedForMode,
    required this.dense,
  });

  final int totalScore;
  final int currentStreak;
  final int solvedForMode;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 430;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(dense ? 12 : 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCAE0D7)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 10,
        runSpacing: 10,
        children: [
          _MiniMetric(label: 'النقاط', value: '$totalScore', dense: dense),
          _StreakFireBadge(streak: currentStreak, dense: dense),
          _MiniMetric(
            label: compact ? 'حل هذا الوضع' : 'تم حل هذا الوضع',
            value: '$solvedForMode',
            dense: dense,
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.dense,
  });

  final String label;
  final String value;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: dense ? 76 : 88),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF157A6E),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
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

class _StreakFireBadge extends StatelessWidget {
  const _StreakFireBadge({
    required this.streak,
    required this.dense,
  });

  final int streak;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) {
      return _MiniMetric(label: 'السلسلة', value: '0', dense: dense);
    }
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: dense ? 76 : 88),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 340),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            curve: Curves.elasticOut,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFE0B2)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A00).withValues(alpha: 0.16),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '🔥',
                  style: TextStyle(fontSize: dense ? 16 : 20),
                ),
                const SizedBox(width: 4),
                Text(
                  '$streak',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFE65100),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'السلسلة',
            textAlign: TextAlign.center,
            style: (dense
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.bodyMedium)
                ?.copyWith(
              color: const Color(0xFFE65100),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
