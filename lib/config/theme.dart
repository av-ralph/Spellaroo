import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const orange = Color(0xFFFF8C00);
  static const gold = Color(0xFFFFD54F);
  static const paleGold = Color(0xFFFFE07A);
  static const red = Color(0xFFFF5252);
  static const green = Color(0xFF19A56F);
  static const blue = Color(0xFF2196F3);
  static const purple = Color(0xFF7E57C2);
  static const coral = Color(0xFFFF6F61);
  static const brown = Color(0xFF60727A);
  static const cream = Color(0xFFFFFBEF);
  static const ink = Color(0xFF203F51);
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
      borderRadius: BorderRadius.circular(20),
    );
    return base.copyWith(
      splashFactory: InkSparkle.splashFactory,
      dividerTheme: const DividerThemeData(
        color: Color(0xFFDCE9E3),
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF20AE85),
        linearTrackColor: Color(0xFFDCECE3),
        linearMinHeight: 9,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFD5F1E6),
        side: const BorderSide(color: Color(0xFFCCE4DC)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        labelStyle: const TextStyle(
          color: ink,
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        iconColor: Color(0xFF109E84),
        textColor: Color(0xFF203F51),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF203F51),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFFFFFDF5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      textTheme: base.textTheme
          .apply(fontFamily: 'Nunito')
          .copyWith(
            bodyLarge: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              height: 1.5,
              color: ink,
            ),
            bodyMedium: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              height: 1.4,
              color: ink,
            ),
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
        toolbarHeight: 68,
        scrolledUnderElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
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
          backgroundColor: const Color(0xFF109E69),
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 52),
          shape: shape,
          textStyle: const TextStyle(
            fontFamily: 'Baloo2',
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
          side: const BorderSide(color: Color(0xFF00825A), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF109E69),
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
          side: const BorderSide(color: Color(0xFFD7E5DD), width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFDF3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD7E5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD7E5DD), width: 1.5),
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
