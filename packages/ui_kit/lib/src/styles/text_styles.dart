import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/src/colors/app_colors.dart';

/// Font family used across the app.
const _kFontFamily = 'Roboto';

/// Text color applied to all typography levels.
const Color _kTextColor = AppColors.textPrimary;

/// Creates the app's Material 3 [TextTheme] based on the lavender palette.
///
/// Apply this to [ThemeData.textTheme] for automatic propagation to all
/// Material widgets (AppBar, ListTile, ElevatedButton, etc.).
TextTheme get appTextTheme =>
    Typography.material2021(
      platform: defaultTargetPlatform,
    ).black.copyWith(
      // ——— Display (rarely used, large hero text) ———
      displayLarge: _base(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 64 / 57,
      ),
      displayMedium: _base(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 52 / 45,
      ),
      displaySmall: _base(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 44 / 36,
      ),

      // ——— Headline (page-level titles) ———
      headlineLarge: _base(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
      ),
      headlineMedium: _base(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
      ),
      headlineSmall: _base(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
      ),

      // ——— Title (section headers, AppBar) ———
      titleLarge: _base(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 28 / 22,
      ),
      titleMedium: _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 24 / 16,
      ),
      titleSmall: _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
      ),

      // ——— Body (primary reading content) ———
      bodyLarge: _base(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
      ),
      bodyMedium: _base(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 16 / 12,
        color: AppColors.textSecondary,
        fontFamily: _kFontFamily,
        letterSpacing: 0.4,
      ),

      // ——— Label (buttons, captions, tags) ———
      labelLarge: _base(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 20 / 14,
      ),
      labelMedium: _base(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
      ),
      labelSmall: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 16 / 11,
        color: AppColors.textHint,
        fontFamily: _kFontFamily,
        letterSpacing: 0.5,
      ),
    );

/// Helper that creates a [TextStyle] with the shared baseline settings.
TextStyle _base({
  required double fontSize,
  required FontWeight fontWeight,
  required double height,
}) => TextStyle(
  fontSize: fontSize,
  fontWeight: fontWeight,
  height: height,
  color: _kTextColor,
  fontFamily: _kFontFamily,
  letterSpacing: _letterTracking(fontSize),
);

/// Material 3 letter-spacing scale (negative tracking for larger sizes).
double _letterTracking(double fontSize) {
  if (fontSize >= 36) return -0.25;
  if (fontSize >= 24) return 0;
  if (fontSize >= 20) return 0.15;
  if (fontSize >= 16) return 0.5;
  if (fontSize >= 14) return 0.1;
  return 0.4;
}

// ——— Named aliases for ergonomic direct usage ———

/// App text style aliases mapped to Material 3 levels.
/// Useful when you want a named style without going through the theme.
abstract final class AppTextStyles {
  /// Display — large hero text (displayLarge)
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 64 / 57,
    color: _kTextColor,
    fontFamily: _kFontFamily,
    letterSpacing: -0.25,
  );

  /// Display medium (displayMedium)
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 52 / 45,
    color: _kTextColor,
    fontFamily: _kFontFamily,
    letterSpacing: -0.25,
  );

  /// Display small (displaySmall)
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 44 / 36,
    color: _kTextColor,
    fontFamily: _kFontFamily,
    letterSpacing: -0.25,
  );

  /// Headline large — page titles (headlineLarge)
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: _kTextColor,
    fontFamily: _kFontFamily,
    letterSpacing: 0,
  );

  /// Headline medium (headlineMedium)
  static const TextStyle headingMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    color: _kTextColor,
    fontFamily: _kFontFamily,
    letterSpacing: 0,
  );

  /// Headline small (headlineSmall)
  static const TextStyle headingSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    color: _kTextColor,
    fontFamily: _kFontFamily,
  );

  /// Title large — section headers (titleLarge)
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    color: _kTextColor,
    fontFamily: _kFontFamily,
  );

  /// Title medium — AppBar titles (titleMedium)
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    color: _kTextColor,
    fontFamily: _kFontFamily,
    letterSpacing: 0.15,
  );

  /// Title small (titleSmall)
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: _kTextColor,
    fontFamily: _kFontFamily,
    letterSpacing: 0.1,
  );

  /// Body large — primary reading (bodyLarge)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: _kTextColor,
    fontFamily: _kFontFamily,
    letterSpacing: 0.5,
  );

  /// Body medium — secondary reading (bodyMedium)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: _kTextColor,
    fontFamily: _kFontFamily,
    letterSpacing: 0.25,
  );

  /// Body small — footnotes, secondary info (bodySmall)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.textSecondary,
    fontFamily: _kFontFamily,
    letterSpacing: 0.4,
  );

  /// Label large — button text, chips (labelLarge)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    color: _kTextColor,
    fontFamily: _kFontFamily,
    letterSpacing: 0.1,
  );

  /// Label medium — captions, tags (labelMedium)
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    color: _kTextColor,
    fontFamily: _kFontFamily,
  );

  /// Label small — overlines, helper text (labelSmall)
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 16 / 11,
    color: AppColors.textHint,
    fontFamily: _kFontFamily,
    letterSpacing: 0.5,
  );
}
