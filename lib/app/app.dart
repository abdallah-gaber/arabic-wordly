import 'package:arabic_wordly/app/theme/app_theme.dart';
import 'package:arabic_wordly/features/game/presentation/game_screen.dart';
import 'package:flutter/material.dart';

class ArabicWordlyApp extends StatelessWidget {
  const ArabicWordlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arabic Wordly',
      theme: AppTheme.light(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const GameScreen(),
    );
  }
}
