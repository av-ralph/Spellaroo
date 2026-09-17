import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const orange = Color(0xFFFF8C00);
  static const gold = Color(0xFFFFD54F);
  static const paleGold = Color(0xFFFFE07A);
  static const red = Color(0xFFFF5252);
  static const green = Color(0xFF4CAF50);
  static const blue = Color(0xFF2196F3);
  static const purple = Color(0xFF7E57C2);
  static const coral = Color(0xFFFF6F61);
  static const brown = Color(0xFF8D6E63);
  static const cream = Color(0xFFFFF8E1);
  static const ink = Color(0xFF553522);
  static const primaryOrange = orange;
  static const primaryYellow = gold;
  static const bgOrange50 = cream;
  static const bgYellow50 = cream;
  static const textNeutral800 = ink;
  static const textNeutral700 = ink;
  static const textNeutral600 = brown;
  static const textNeutral500 = brown;
  static const textNeutral400 = brown;

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Nunito',
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: blue).copyWith(
        primary: const Color(0xFF238BCA),
        secondary: orange,
        surface: cream,
        onSurface: ink,
        error: const Color(0xFFBD3131),
      ),
    );
    final headings = const TextStyle(
      fontFamily: 'Baloo2',
      fontWeight: FontWeight.w800,
      color: ink,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineLarge: headings.copyWith(fontSize: 32),
        headlineMedium: headings.copyWith(fontSize: 28),
        headlineSmall: headings.copyWith(fontSize: 24),
        titleLarge: headings.copyWith(fontSize: 22),
        titleMedium: headings.copyWith(fontSize: 18),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF187EB2),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Baloo2',
          fontWeight: FontWeight.w800,
          fontSize: 23,
          color: Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF388E3C),
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          shape: shape,
          textStyle: const TextStyle(
            fontFamily: 'Baloo2',
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
          side: const BorderSide(color: Color(0xFF28682B), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF388E3C),
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          shape: shape,
          textStyle: const TextStyle(
            fontFamily: 'Baloo2',
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFDF3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFE7CD86), width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFDF3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE7CD86)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE7CD86), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: blue, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF187EB2),
        indicatorColor: gold,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? ink : Colors.white,
          ),
        ),
      ),
    );
  }
}
