import 'package:arabic_wordly/features/game/data/puzzle_bank.dart';
import 'package:arabic_wordly/features/game/domain/game_models.dart';

/// Curated bank used by [game_screen] widget tests (deterministic words and categories).
final ArabicPuzzleBank widgetTestPuzzleBank = ArabicPuzzleBank({
  GameMode.threeLetters: [
    const ArabicPuzzle(word: 'بيت', category: 'المنزل'),
    const ArabicPuzzle(word: 'باب', category: 'المنزل'),
    const ArabicPuzzle(word: 'نور', category: 'الضوء'),
  ],
  GameMode.fourLetters: [
    const ArabicPuzzle(word: 'كتاب', category: 'القراءة'),
    const ArabicPuzzle(word: 'قهوة', category: 'المشروبات'),
    const ArabicPuzzle(word: 'وردة', category: 'النباتات'),
  ],
  GameMode.fiveLetters: [
    const ArabicPuzzle(
      word: 'حديقة',
      category: 'الطبيعة',
      definition: 'مساحة مزروعة تضم نباتات وأزهاراً وتُستخدم للراحة أو التنزه.',
    ),
    const ArabicPuzzle(
      word: 'مدرسة',
      category: 'التعليم',
      definition: 'مكان مخصص للتعلّم والدراسة يجتمع فيه الطلاب مع المعلمين.',
    ),
    const ArabicPuzzle(
      word: 'مكتبة',
      category: 'القراءة',
      definition: 'مكان تُجمع فيه الكتب والمراجع للقراءة أو الاستعارة.',
    ),
  ],
  GameMode.sixLetters: [
    const ArabicPuzzle(word: 'سيارات', category: 'المواصلات'),
    const ArabicPuzzle(word: 'مدارسك', category: 'التعليم'),
    const ArabicPuzzle(word: 'تفاحات', category: 'الفواكه'),
  ],
});
