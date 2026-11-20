import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Thèmes Material 3 clair / sombre d'EmbedForge.
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: Brightness.light,
        surface: AppColors.surfaceLight,
      ),
      fontFamily: 'Static',
      scaffoldBackgroundColor: AppColors.surfaceLight,
    );
    return _decorate(base, dark: false);
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.blue,
        brightness: Brightness.dark,
        surface: AppColors.surfaceDark,
      ),
      fontFamily: 'Static',
      scaffoldBackgroundColor: AppColors.anthracite,
    );
    return _decorate(base, dark: true);
  }

  static ThemeData _decorate(ThemeData t, {required bool dark}) {
    final scheme = t.colorScheme;
    final card = dark ? AppColors.cardDark : AppColors.cardLight;
    final ink = dark ? AppColors.offWhite : AppColors.inkLight;

    final border = Color(0xFF2A3646);
    const textSelection = Color(0x332EBEFF);

    final base = t.copyWith(
      cardColor: card,
      dividerColor: dark
          ? border.withValues(alpha: 0.5)
          : const Color(0xFFE3E8EF),
      textTheme: t.textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppColors.anthracite : AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Static',
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        iconTheme: IconThemeData(color: ink),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? AppColors.anthraciteLight : Colors.white,
        indicatorColor: AppColors.blue.withValues(alpha: dark ? 0.28 : 0.16),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ink),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? AppColors.blue
                : (dark
                      ? AppColors.offWhite.withValues(alpha: 0.7)
                      : AppColors.inkSoft),
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadius),
          side: BorderSide(
            color: dark
                ? border.withValues(alpha: 0.6)
                : const Color(0xFFE7ECF3),
          ),
        ),
      ),
      chipTheme: t.chipTheme.copyWith(
        backgroundColor: dark ? AppColors.cardDark : AppColors.offWhite,
        labelStyle: TextStyle(
          color: dark ? AppColors.offWhite : AppColors.inkLight,
          fontSize: 12.5,
        ),
        side: BorderSide(color: border.withValues(alpha: 0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? AppColors.anthraciteLight : AppColors.inkLight,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 13.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.surfaceDark : Colors.white,
        hintStyle: TextStyle(color: AppColors.inkSoft.withValues(alpha: 0.8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border.withValues(alpha: 0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.blue, width: 1.6),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.blue,
        linearTrackColor: Color(0x22000000),
      ),
      colorScheme: scheme.copyWith(
        primary: AppColors.blue,
        secondary: AppColors.green,
        tertiary: AppColors.orange,
        error: AppColors.red,
        surface: dark ? AppColors.surfaceDark : AppColors.surfaceLight,
        onSurface: ink,
      ),
    );

    return base.copyWith(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.blue,
        selectionColor: textSelection,
        selectionHandleColor: AppColors.blue,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.blue,
        unselectedLabelColor: AppColors.inkSoft,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorColor: AppColors.blue,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      extensions: [
        AppSurfaceStyle(
          cardPill: card,
          codeBackground: dark
              ? const Color(0xFF0D1117)
              : const Color(0xFF10151C),
        ),
      ],
    );
  }

  /// Typographies monospace réutilisables.
  static const String codeFont = 'MonoTech';
}

@immutable
class AppSurfaceStyle extends ThemeExtension<AppSurfaceStyle> {
  final Color cardPill;
  final Color codeBackground;

  const AppSurfaceStyle({required this.cardPill, required this.codeBackground});

  @override
  AppSurfaceStyle copyWith({Color? cardPill, Color? codeBackground}) {
    return AppSurfaceStyle(
      cardPill: cardPill ?? this.cardPill,
      codeBackground: codeBackground ?? this.codeBackground,
    );
  }

  @override
  AppSurfaceStyle lerp(AppSurfaceStyle? other, double t) {
    if (other == null) return this;
    return AppSurfaceStyle(
      cardPill: Color.lerp(cardPill, other.cardPill, t)!,
      codeBackground: Color.lerp(codeBackground, other.codeBackground, t)!,
    );
  }
}
