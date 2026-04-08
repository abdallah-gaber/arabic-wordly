part of 'package:arabic_wordly/features/game/presentation/game_screen.dart';

class _RoundResultDialog extends StatelessWidget {
  const _RoundResultDialog({required this.result});

  final RoundResult result;

  @override
  Widget build(BuildContext context) {
    final isWin = result.type == RoundResultType.won;
    final color = isWin ? const Color(0xFF157A6E) : const Color(0xFFC84F4F);
    final accent = isWin ? const Color(0xFFE0A93B) : const Color(0xFFF2B3B3);
    final attemptsLabel = isWin
        ? '${result.attemptsUsed} / ${ArabicWordRules.maxAttempts} محاولات'
        : 'استخدمت ${result.attemptsUsed} / ${ArabicWordRules.maxAttempts}';
    final scoreLabel = isWin ? '+${result.pointsEarned} نقطة' : '0 نقطة';

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.sizeOf(context).height - 48,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFCF6),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: accent),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _DialogBadge(isWin: isWin, color: color, accent: accent),
                    const SizedBox(height: 14),
                    Text(
                      isWin ? 'أحسنت!' : 'انتهت المحاولات',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800, color: color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isWin
                          ? 'تم حل الجولة ${result.round} خلال ${result.attemptsUsed} محاولة.'
                          : 'لم تنجح في الجولة ${result.round} هذه المرة.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF5D635F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ResultPill(
                          label: attemptsLabel,
                          background: const Color(0xFFF4F0E7),
                          foreground: const Color(0xFF5D635F),
                        ),
                        _ResultPill(
                          label: scoreLabel,
                          background: const Color(0xFFEAF3F0),
                          foreground: const Color(0xFF157A6E),
                        ),
                        _ResultPill(
                          label: 'المجموع ${result.totalScore}',
                          background: const Color(0xFFF4F0E7),
                          foreground: const Color(0xFF5D635F),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        'الكلمة الصحيحة: ${result.answer}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'السلسلة الحالية: ${result.currentStreak}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5D635F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(true),
                        icon: Icon(
                          isWin
                              ? Icons.arrow_forward_rounded
                              : Icons.refresh_rounded,
                        ),
                        label: Text(isWin ? 'التالي' : 'جرب لغزاً جديداً'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogBadge extends StatelessWidget {
  const _DialogBadge({
    required this.isWin,
    required this.color,
    required this.accent,
  });

  final bool isWin;
  final Color color;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.86, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.95),
                  color.withValues(alpha: 0.94),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Icon(
            isWin
                ? Icons.celebration_rounded
                : Icons.sentiment_dissatisfied_rounded,
            color: Colors.white,
            size: 48,
          ),
          if (isWin) ...[
            const Positioned(top: 8, right: 10, child: _Sparkle(size: 20)),
            const Positioned(bottom: 14, left: 8, child: _Sparkle(size: 16)),
            const Positioned(top: 18, left: 4, child: _Sparkle(size: 12)),
          ],
        ],
      ),
    );
  }
}

class _ResultPill extends StatelessWidget {
  const _ResultPill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome_rounded,
      size: size,
      color: const Color(0xFFFFF4CC),
    );
  }
}
