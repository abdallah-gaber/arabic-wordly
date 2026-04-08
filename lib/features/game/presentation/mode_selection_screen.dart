import 'package:arabic_wordly/app/app_branding.dart';
import 'package:arabic_wordly/features/game/application/game_controller.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';
import 'package:arabic_wordly/features/game/domain/player_stats.dart';
import 'package:arabic_wordly/features/game/presentation/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModeSelectionScreen extends ConsumerWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final playerStats = ref.watch(playerStatsProvider).asData?.value;

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _ModeSelectionBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 780),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ModeSelectionHero(
                                textTheme: textTheme,
                                stats: playerStats ?? const PlayerStats(),
                              ),
                              const SizedBox(height: 26),
                              LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final crossAxisCount =
                                      innerConstraints.maxWidth >= 640 ? 2 : 1;
                                  final compactCard =
                                      crossAxisCount == 1 &&
                                      innerConstraints.maxWidth < 420;
                                  return GridView.builder(
                                    shrinkWrap: true,
                                    itemCount: GameMode.values.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          childAspectRatio: crossAxisCount == 2
                                              ? 1.22
                                              : compactCard
                                              ? 1.36
                                              : 1.52,
                                          mainAxisSpacing: 14,
                                          crossAxisSpacing: 14,
                                        ),
                                    itemBuilder: (context, index) {
                                      final mode = GameMode.values[index];
                                      return _ModeCard(
                                        compact: compactCard,
                                        mode: mode,
                                        stats:
                                            playerStats?.statsForMode(mode) ??
                                            ModeStats(mode: mode),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute<void>(
                                              builder: (_) =>
                                                  GameScreen(mode: mode),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 22),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F3E7),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFE3D3AA),
                                  ),
                                ),
                                child: Text(
                                  'ابدأ بـ 4 أو 5 أحرف إذا أردت أفضل توازن، ولكل وضع تقدم مستقل يمكنك الرجوع إليه في أي وقت.',
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF6E5A1E),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSelectionHero extends StatelessWidget {
  const _ModeSelectionHero({required this.textTheme, required this.stats});

  final TextTheme textTheme;
  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFDCE9E3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x16157A6E),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3F0),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFCAE0D7)),
              ),
              child: Text(
                'جاهز لجولة جديدة',
                style: textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF157A6E),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            appNameArabic,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            appNameEnglish,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF157A6E),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'اختر طول التحدي وابدأ فوراً',
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'كل وضع يحفظ تقدمه وإحصاءاته بشكل مستقل، لذلك يمكنك التنقل بين التحديات كما تشاء.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: const Color(0xFF5D635F),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'ملخص التقدم',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'نظرة سريعة قبل اختيار الوضع التالي.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5D635F),
            ),
          ),
          const SizedBox(height: 16),
          _SelectionSummaryCard(stats: stats),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.mode,
    required this.stats,
    required this.onTap,
    required this.compact,
  });

  final GameMode mode;
  final ModeStats stats;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('mode-card-${mode.cacheKey}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: const Color(0x14157A6E),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(compact ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  mode.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 24 : null,
                  ),
                ),
                SizedBox(height: compact ? 6 : 8),
                _ModeToneChip(mode: mode),
                SizedBox(height: compact ? 8 : 10),
                Text(
                  mode.description,
                  textAlign: TextAlign.center,
                  style:
                      (compact
                              ? Theme.of(context).textTheme.bodySmall
                              : Theme.of(context).textTheme.bodyMedium)
                          ?.copyWith(color: const Color(0xFF5D635F)),
                ),
                SizedBox(height: compact ? 8 : 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 0; index < mode.wordLength; index++) ...[
                      if (index > 0) SizedBox(width: compact ? 6 : 8),
                      Container(
                        width: compact ? 16 : 18,
                        height: compact ? 16 : 18,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFCF6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: compact ? 8 : 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ModeStatPill(label: 'النقاط ${stats.totalScore}'),
                    _ModeStatPill(label: 'تم الحل ${stats.solved}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionSummaryCard extends StatelessWidget {
  const _SelectionSummaryCard({required this.stats});

  final PlayerStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF7F4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFCAE0D7)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        spacing: 12,
        runSpacing: 12,
        children: [
          _SelectionMetric(
            label: 'إجمالي النقاط',
            value: '${stats.totalScore}',
          ),
          _SelectionMetric(
            label: 'السلسلة الحالية',
            value: '${stats.currentStreak}',
          ),
          _SelectionMetric(label: 'تم الحل', value: '${stats.totalSolved}'),
          _SelectionMetric(label: 'أفضل سلسلة', value: '${stats.bestStreak}'),
        ],
      ),
    );
  }
}

class _SelectionMetric extends StatelessWidget {
  const _SelectionMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 110),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF157A6E),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF5D635F),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeStatPill extends StatelessWidget {
  const _ModeStatPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFCAE0D7)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF157A6E),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ModeToneChip extends StatelessWidget {
  const _ModeToneChip({required this.mode});

  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = switch (mode) {
      GameMode.threeLetters => (
        const Color(0xFFEAF3F0),
        const Color(0xFF157A6E),
        'انطلاقة سريعة',
      ),
      GameMode.fourLetters => (
        const Color(0xFFF6F0E3),
        const Color(0xFF8A6D2D),
        'توازن مريح',
      ),
      GameMode.fiveLetters => (
        const Color(0xFFEFF1FA),
        const Color(0xFF4158A6),
        'الخيار الأساسي',
      ),
      GameMode.sixLetters => (
        const Color(0xFFFBEDED),
        const Color(0xFFB55555),
        'تركيز أعلى',
      ),
    };

    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
      ),
    );
  }
}

class _ModeSelectionBackground extends StatelessWidget {
  const _ModeSelectionBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF9F5EE), Color(0xFFF2F8F5), Color(0xFFF8F4EC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            top: -80,
            right: -40,
            child: _ModeSelectionOrb(
              size: 220,
              colors: [Color(0x3329A28E), Color(0x00FFFFFF)],
            ),
          ),
          Positioned(
            top: 260,
            left: -60,
            child: _ModeSelectionOrb(
              size: 180,
              colors: [Color(0x22E0A93B), Color(0x00FFFFFF)],
            ),
          ),
          Positioned(
            bottom: -50,
            right: 24,
            child: _ModeSelectionOrb(
              size: 200,
              colors: [Color(0x1F157A6E), Color(0x00FFFFFF)],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSelectionOrb extends StatelessWidget {
  const _ModeSelectionOrb({required this.size, required this.colors});

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
