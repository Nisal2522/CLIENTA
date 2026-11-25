import 'package:flutter/material.dart';

/// Brand colours inspired by the Control Union identity:
/// deep navy, professional blue, steel grey and clean whites.
class AppColors {
  AppColors._();

  static const navy950 = Color(0xFF080D19);
  static const navy900 = Color(0xFF0D1424);
  static const navy800 = Color(0xFF131C30);
  static const navy700 = Color(0xFF1A253D);
  static const navy600 = Color(0xFF24324F);

  static const blue = Color(0xFF29A9E1);
  static const blueDeep = Color(0xFF1A6FC4);
  static const blueSoft = Color(0xFFD9EFFA);
  static const steel = Color(0xFF5E7A86);
  static const mist = Color(0xFFA9C4CC);

  static const green = Color(0xFF22B573);
  static const orange = Color(0xFFFF8A3D);
  static const red = Color(0xFFEF4444);
  static const purple = Color(0xFF8B5CF6);
  static const pink = Color(0xFFDB2FA0);
  static const yellow = Color(0xFFF5B400);
  static const indigo = Color(0xFF3B48D8);
  static const lime = Color(0xFF7CB342);
  static const teal = Color(0xFF14B8A6);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF38B6EA), blueDeep],
  );

  static const navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy700, navy950],
  );
}

/// Semantic surface colours that change between light and dark mode.
class Palette {
  const Palette({
    required this.dark,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.textFaint,
    required this.glass,
    required this.glassBorder,
    required this.skeleton,
    required this.shadow,
  });

  final bool dark;
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color border;
  final Color text;
  final Color textMuted;
  final Color textFaint;
  final Color glass;
  final Color glassBorder;
  final Color skeleton;
  final Color shadow;

  static const light = Palette(
    dark: false,
    bg: Colors.white,
    surface: Colors.white,
    surfaceAlt: Color(0xFFF2F5F9),
    border: Color(0xFFE6EBF1),
    text: Color(0xFF0F1A2C),
    textMuted: Color(0xFF5B6B7F),
    textFaint: Color(0xFF94A3B5),
    glass: Color(0xB3FFFFFF),
    glassBorder: Color(0x33FFFFFF),
    skeleton: Color(0xFFE3E9F0),
    shadow: Color(0x141A2B4A),
  );

  static const darkPalette = Palette(
    dark: true,
    bg: AppColors.navy950,
    surface: AppColors.navy800,
    surfaceAlt: AppColors.navy700,
    border: Color(0xFF26324A),
    text: Color(0xFFF1F5FB),
    textMuted: Color(0xFFA3B1C6),
    textFaint: Color(0xFF66758C),
    glass: Color(0x99131C30),
    glassBorder: Color(0x1FFFFFFF),
    skeleton: Color(0xFF1C2740),
    shadow: Color(0x66000000),
  );

  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPalette : light;
}

extension ThemeX on BuildContext {
  Palette get pal => Palette.of(this);
  TextTheme get tt => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

class AppTheme {
  AppTheme._();

  static final ThemeData _lightCache = _build(Brightness.light);

  static ThemeData light() => _lightCache;
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final p = b == Brightness.dark ? Palette.darkPalette : Palette.light;
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.blue, brightness: b).copyWith(
      primary: AppColors.blue,
      onPrimary: Colors.white,
      secondary: AppColors.blueDeep,
      surface: p.surface,
      onSurface: p.text,
      error: AppColors.red,
      outline: p.border,
    );

    final base = b == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final text = base
        .copyWith(
          displaySmall: base.displaySmall?.copyWith(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.8, height: 1.1),
          headlineMedium: base.headlineMedium?.copyWith(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -0.6),
          headlineSmall: base.headlineSmall?.copyWith(fontSize: 23, fontWeight: FontWeight.w800, letterSpacing: -0.4),
          titleLarge: base.titleLarge?.copyWith(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.2),
          titleMedium: base.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
          titleSmall: base.titleSmall?.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
          bodyLarge: base.bodyLarge?.copyWith(fontSize: 15.5, height: 1.6),
          bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
          bodySmall: base.bodySmall?.copyWith(fontSize: 12.5, color: p.textMuted),
          labelLarge: base.labelLarge?.copyWith(fontSize: 14.5, fontWeight: FontWeight.w700),
          labelMedium: base.labelMedium?.copyWith(fontSize: 12.5, fontWeight: FontWeight.w600),
          labelSmall: base.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.3),
        )
        .apply(bodyColor: p.text, displayColor: p.text);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.bg,
      textTheme: text,
      dividerColor: p.border,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: p.text,
        titleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: p.text, letterSpacing: -0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceAlt,
        hintStyle: TextStyle(color: p.textFaint, fontSize: 14.5),
        labelStyle: TextStyle(color: p.textMuted),
        prefixIconColor: p.textMuted,
        suffixIconColor: p.textMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(AppColors.blue, 1.6),
        errorBorder: border(AppColors.red.withValues(alpha: 0.7)),
        focusedErrorBorder: border(AppColors.red, 1.6),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: p.surface,
        showDragHandle: true,
        dragHandleColor: p.textFaint,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: b == Brightness.dark ? const Color(0xFF26324A) : AppColors.navy800,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: p.textMuted,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        indicator: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.blue),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: p.textFaint, width: 1.5),
      ),
    );
  }
}

/// Forces the light (white) theme for brand screens such as onboarding and
/// sign-in, regardless of the user's theme preference.
class ForceLight extends StatelessWidget {
  const ForceLight({super.key, required this.builder});
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => Theme(data: AppTheme.light(), child: Builder(builder: builder));
}
