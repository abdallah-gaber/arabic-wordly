part of 'package:arabic_wordly/features/game/presentation/game_screen.dart';

class _RoundResultDialog extends StatelessWidget {
  const _RoundResultDialog({required this.result});

  final RoundResult result;

  @override
  Widget build(BuildContext context) {
    final isWin = result.type == RoundResultType.won;
    final color = isWin ? const Color(0xFF157A6E) : const Color(0xFFC84F4F);
    final accent = isWin ? const Color(0xFFE0A93B) : const Color(0xFFF2B3B3);
    final surfaceTint = isWin
        ? const Color(0xFFF4FBF8)
        : const Color(0xFFFFF7F7);
    final attemptsLabel = isWin
        ? '${result.attemptsUsed} / ${ArabicWordRules.maxAttempts} محاولات'
        : 'استخدمت ${result.attemptsUsed} / ${ArabicWordRules.maxAttempts}';
    final scoreLabel = isWin ? '+${result.pointsEarned} نقطة' : '0 نقطة';
    final eyebrow = isWin ? 'جولة ناجحة' : 'الجولة انتهت';
    final summaryTitle = isWin
        ? 'السلسلة الحالية: ${result.currentStreak}'
        : 'اقتربت من الإجابة هذه المرة';
    final summaryBody = isWin
        ? 'حافظ على الإيقاع، فالجولة التالية فرصة لرفع السلسلة أكثر.'
        : 'ارجع مباشرة إلى تحد جديد، وخذ الجولة القادمة كفرصة أسرع للعودة.';
    final actionHint = isWin
        ? 'استمر الآن قبل أن يبرد الإيقاع.'
        : 'جرّب جولة جديدة فوراً ولا تكسر الحماس.';

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
                color: surfaceTint,
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _DialogHero(
                        isWin: isWin,
                        color: color,
                        accent: accent,
                        eyebrow: eyebrow,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isWin ? 'أحسنت!' : 'انتهت المحاولات',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isWin
                                  ? 'تم حل الجولة ${result.round} خلال ${result.attemptsUsed} محاولة.'
                                  : 'اقتربت من الحل، لكن الجولة ${result.round} انتهت هذه المرة.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: const Color(0xFF5D635F)),
                            ),
                            const SizedBox(height: 14),
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
                            const SizedBox(height: 14),
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
                            const SizedBox(height: 12),
                            _DialogSummaryCard(
                              color: color,
                              background: isWin
                                  ? const Color(0xFFEAF6F2)
                                  : const Color(0xFFFDEEEE),
                              icon: isWin
                                  ? Icons.local_fire_department_rounded
                                  : Icons.refresh_rounded,
                              title: summaryTitle,
                              body: summaryBody,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                icon: Icon(
                                  isWin
                                      ? Icons.arrow_forward_rounded
                                      : Icons.refresh_rounded,
                                ),
                                label: Text(
                                  isWin ? 'التالي' : 'جرب لغزاً جديداً',
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              actionHint,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: const Color(0xFF5D635F),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHero extends StatelessWidget {
  const _DialogHero({
    required this.isWin,
    required this.color,
    required this.accent,
    required this.eyebrow,
  });

  final bool isWin;
  final Color color;
  final Color accent;
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: isWin ? 0.34 : 0.24),
            color.withValues(alpha: isWin ? 0.14 : 0.10),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accent.withValues(alpha: 0.65)),
            ),
            child: Text(
              eyebrow,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _DialogBadge(isWin: isWin, color: color, accent: accent),
        ],
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
        return Transform.scale(
          scale: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.88, end: 1.06),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: 134,
              height: 134,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accent.withValues(alpha: 0.32),
                  width: 2,
                ),
              ),
            ),
          ),
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

class _DialogSummaryCard extends StatelessWidget {
  const _DialogSummaryCard({
    required this.color,
    required this.background,
    required this.icon,
    required this.title,
    required this.body,
  });

  final Color color;
  final Color background;
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF5D635F),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
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
