import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: MindfulQuestApp()));
}

class MindfulQuestApp extends StatelessWidget {
  const MindfulQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindful Quest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF080818),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A90D9),
          secondary: Color(0xFFD4A017),
          surface: Color(0xFF0E0E24),
        ),
        textTheme: GoogleFonts.dotGothic16TextTheme(
          ThemeData.dark().textTheme,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
