import 'package:flutter/material.dart';
import 'package:ui_kit/src/colors/app_colors.dart';
import 'package:ui_kit/src/styles/text_styles.dart';

/// Primary app button with support for variants and loading state.
class AppButton extends StatelessWidget {
  /// Creates an [AppButton].
  ///
  /// [text] is the button label.
  /// [onPressed] is the callback when the button is tapped.
  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
  });

  /// The button label.
  final String text;

  /// The callback when the button is tapped.
  /// If null, the button is disabled.
  final VoidCallback? onPressed;

  /// The button variant.
  final AppButtonVariant variant;

  /// Whether to show a loading indicator.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: variant.backgroundColor,
          foregroundColor: variant.foregroundColor,
          elevation: 0,
          side: variant.borderColor != null
              ? BorderSide(color: variant.borderColor!)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: variant.foregroundColor,
                ),
              )
            : Text(
                text,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: variant.foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// Button variant styles with built-in color configuration.
enum AppButtonVariant {
  /// Primary action button — lavender background, white text.
  primary(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
  ),

  /// Secondary/darker variant — deep purple background, white text.
  secondary(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: AppColors.onPrimaryDark,
  ),

  /// Outlined style — transparent background, lavender border.
  outlined(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.primary,
    borderColor: AppColors.primary,
  );

  const AppButtonVariant({
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  /// Button background color.
  final Color backgroundColor;

  /// Button text and icon color.
  final Color foregroundColor;

  /// Optional border color. If null, no border is drawn.
  final Color? borderColor;
}
