import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'typography.dart';

class ComponentThemes {
  static ButtonThemeData get buttonTheme => ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
    ),
  );

  static ElevatedButtonThemeData get elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primary,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: AppTypography.buttonLabel,
    ),
  );

  static OutlinedButtonThemeData get outlinedButtonTheme => OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary),
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: AppTypography.buttonLabel,
    ),
  );

  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      textStyle: AppTypography.buttonLabel,
    ),
  );

  static InputDecorationTheme get inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.1),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    hintStyle: AppTypography.inputHint,
  errorStyle: AppTypography.textTheme.bodySmall!.copyWith(color: AppColors.error),
  );

  static CardThemeData get cardTheme => CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.1),
      ),
    ),
    clipBehavior: Clip.antiAlias,
  );

  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
    centerTitle: false,
  titleTextStyle: AppTypography.textTheme.titleLarge!,
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
  );

  static BottomNavigationBarThemeData get bottomNavigationBarTheme =>
      const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      );

  static ListTileThemeData get listTileTheme => ListTileThemeData(
    tileColor: Colors.transparent,
    selectedTileColor: AppColors.statePressed,
    iconColor: AppColors.textPrimary,
    textColor: AppColors.textPrimary,
    titleTextStyle: AppTypography.textTheme.bodyLarge!,
    subtitleTextStyle: AppTypography.textTheme.bodyMedium!.copyWith(
      color: AppColors.textSecondary,
    ),
  );

  static SnackBarThemeData get snackBarTheme => SnackBarThemeData(
    backgroundColor: AppColors.surface,
  contentTextStyle: AppTypography.textTheme.bodyMedium!,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    behavior: SnackBarBehavior.floating,
  );

  static DialogThemeData get dialogTheme => DialogThemeData(
    backgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  titleTextStyle: AppTypography.textTheme.titleLarge!,
  contentTextStyle: AppTypography.textTheme.bodyMedium!,
  );

  static BottomSheetThemeData get bottomSheetTheme => BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    modalBackgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
  );

  static ChipThemeData get chipTheme => ChipThemeData(
    backgroundColor: AppColors.surface,
    selectedColor: AppColors.primary,
    disabledColor: AppColors.stateDisabled,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  labelStyle: AppTypography.textTheme.bodySmall!,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
      side: BorderSide(
        color: Colors.white.withValues(alpha: 0.1),
      ),
    ),
  );
}